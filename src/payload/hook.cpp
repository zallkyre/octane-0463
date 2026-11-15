#include "hook.h"

#include "mem.h"
#include "prologue.h"

#include <windows.h>
#include <algorithm>
#include <atomic>
#include <cstring>
#include <vector>

namespace {

uintptr_t g_target = 0;
size_t g_patchLen = 0;
uint8_t* g_stub = nullptr;   // detour: saves state, calls HookThunk, continues
uint8_t* g_tramp = nullptr;  // copy of original prologue + jump back
std::vector<uint8_t> g_original;
std::atomic<uint64_t> g_hits{0};
std::atomic<uint64_t> g_firstHit{0};
HookCallback g_callback = nullptr;
HookPlanInfo g_plan;

#if defined(_WIN64)

void WriteAbsJmp(uint8_t* dst, uintptr_t to) {
    // FF 25 00 00 00 00 <abs64>  ->  jmp qword ptr [rip+0]
    dst[0] = 0xFF;
    dst[1] = 0x25;
    dst[2] = 0x00;
    dst[3] = 0x00;
    dst[4] = 0x00;
    dst[5] = 0x00;
    std::memcpy(dst + 6, &to, sizeof(to));
}

constexpr size_t kPatchSize = 14;

// pushfq; push rax/rcx/rdx/r8/r9/r10/r11; sub rsp,0x28; mov rcx,rsp;
// mov rax,handler; call rax; add rsp,0x28; pops; popfq; mov rax,cont; jmp rax
uint8_t* BuildStub(uintptr_t handler, uintptr_t continuation) {
    auto mem = static_cast<uint8_t*>(
        VirtualAlloc(nullptr, 256, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE));
    if (!mem) return nullptr;

    size_t i = 0;
    auto put = [&](std::initializer_list<uint8_t> bytes) {
        for (uint8_t b : bytes) mem[i++] = b;
    };

    put({0x9C});                    // pushfq
    put({0x50});                    // push rax
    put({0x51});                    // push rcx
    put({0x52});                    // push rdx
    put({0x41, 0x50});              // push r8
    put({0x41, 0x51});              // push r9
    put({0x41, 0x52});              // push r10
    put({0x41, 0x53});              // push r11
    put({0x48, 0x83, 0xEC, 0x28});  // sub rsp, 0x28 (shadow space + align)
    put({0x48, 0x89, 0xE1});        // mov rcx, rsp   ; &SavedRegs
    put({0x48, 0xB8});              // mov rax, imm64
    std::memcpy(mem + i, &handler, 8);
    i += 8;
    put({0xFF, 0xD0});              // call rax
    put({0x48, 0x83, 0xC4, 0x28});  // add rsp, 0x28
    put({0x41, 0x5B});              // pop r11
    put({0x41, 0x5A});              // pop r10
    put({0x41, 0x59});              // pop r9
    put({0x41, 0x58});              // pop r8
    put({0x5A});                    // pop rdx
    put({0x59});                    // pop rcx
    put({0x58});                    // pop rax
    put({0x9D});                    // popfq
    put({0x48, 0xB8});              // mov rax, imm64
    std::memcpy(mem + i, &continuation, 8);
    i += 8;
    put({0xFF, 0xE0});              // jmp rax

    FlushInstructionCache(GetCurrentProcess(), mem, i);
    return mem;
}

uintptr_t FirstArg(const SavedRegs* regs) { return regs->rcx; }

#else  // x86

void WriteAbsJmp(uint8_t* dst, uintptr_t to) {
    // 68 <imm32> C3  ->  push imm32 ; ret
    uint32_t addr = static_cast<uint32_t>(to);
    dst[0] = 0x68;
    std::memcpy(dst + 1, &addr, sizeof(addr));
    dst[5] = 0xC3;
}

constexpr size_t kPatchSize = 6;

// pushfd; pushad; push esp; mov eax,handler; call eax; add esp,4; popad; popfd;
// push cont; ret
uint8_t* BuildStub(uintptr_t handler, uintptr_t continuation) {
    auto mem = static_cast<uint8_t*>(
        VirtualAlloc(nullptr, 256, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE));
    if (!mem) return nullptr;

    size_t i = 0;
    auto put = [&](std::initializer_list<uint8_t> bytes) {
        for (uint8_t b : bytes) mem[i++] = b;
    };

    put({0x9C});              // pushfd
    put({0x60});              // pushad
    put({0x54});              // push esp      ; &SavedRegs
    put({0xB8});              // mov eax, imm32
    uint32_t h = static_cast<uint32_t>(handler);
    std::memcpy(mem + i, &h, 4);
    i += 4;
    put({0xFF, 0xD0});        // call eax
    put({0x83, 0xC4, 0x04});  // add esp, 4
    put({0x61});              // popad
    put({0x9D});              // popfd
    put({0x68});              // push imm32
    uint32_t c = static_cast<uint32_t>(continuation);
    std::memcpy(mem + i, &c, 4);
    i += 4;
    put({0xC3});              // ret

    FlushInstructionCache(GetCurrentProcess(), mem, i);
    return mem;
}

uintptr_t FirstArg(const SavedRegs* regs) {
    // pushfd runs before pushad, so the saved esp is entry-4:
    //   saved+0 -> flags slot? no: saved+4 -> return address, saved+8 -> first arg
    return *reinterpret_cast<const uint32_t*>(static_cast<uintptr_t>(regs->esp) + 8);
}

#endif

}  // namespace

HookPlanInfo PlanHook(uintptr_t target, size_t minLen) {
    HookPlanInfo plan;
#if defined(_WIN64)
    // x64 detour is a fixed 14-byte absolute jump; prologue decoding is x86-only.
    plan.patchLen = std::max(minLen, kPatchSize);
    plan.text = "x64: 14-byte jmp [rip+0] + abs64 (not decoded)";
    if (target == 0) {
        plan.reason = "null target";
        return plan;
    }
    plan.ok = true;
    return plan;
#else
    if (target == 0) {
        plan.reason = "null target";
        return plan;
    }
    PrologueInfo p = DecodePrologue(target, std::max(minLen, kPatchSize));
    plan.patchLen = p.length;
    plan.text = p.text;
    plan.relative = p.hasRelative;
    plan.terminal = p.hasTerminal;
    if (!p.decoded) {
        plan.reason = p.error.empty() ? "prologue decode failed" : p.error;
        return plan;
    }
    if (p.length < kPatchSize) {
        plan.reason = "prologue shorter than the detour";
        return plan;
    }
    if (p.hasRelative) {
        plan.reason = "relative branch/call inside the copied prologue";
        return plan;
    }
    plan.ok = true;
    return plan;
#endif
}

extern "C" void __cdecl HookThunk(SavedRegs* regs) {
    uint64_t n = g_hits.fetch_add(1) + 1;
    if (n == 1) g_firstHit.store(GetTickCount64());
    if (g_callback) g_callback(regs);
}

uintptr_t HookFirstArg(const SavedRegs* regs) { return FirstArg(regs); }

bool IsHooked() { return g_target != 0; }
uintptr_t HookTarget() { return g_target; }
size_t HookPatchLen() { return g_patchLen; }
const HookPlanInfo& LastHookPlan() { return g_plan; }
uint64_t HookHits() { return g_hits.load(); }
uint64_t HookFirstHitTick() { return g_firstHit.load(); }
void SetHookCallback(HookCallback cb) { g_callback = cb; }

bool InstallInlineHook(uintptr_t target, size_t patchLen) {
    if (IsHooked() || target == 0 || patchLen < kHookMinLen) return false;

    g_plan = PlanHook(target, patchLen);
    if (!g_plan.ok) return false;
    const size_t patch = g_plan.patchLen;
    if (patch < kPatchSize) return false;

    g_original.resize(patch);
    if (!SafeRead(target, g_original.data(), patch)) return false;

    g_tramp = static_cast<uint8_t*>(
        VirtualAlloc(nullptr, patch + 32, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE));
    if (!g_tramp) {
        g_original.clear();
        return false;
    }
    std::memcpy(g_tramp, g_original.data(), patch);
    WriteAbsJmp(g_tramp + patch, target + patch);  // jump back
    FlushInstructionCache(GetCurrentProcess(), g_tramp, patch + kPatchSize);

    g_stub = BuildStub(reinterpret_cast<uintptr_t>(&HookThunk),
                       reinterpret_cast<uintptr_t>(g_tramp));
    if (!g_stub) {
        VirtualFree(g_tramp, 0, MEM_RELEASE);
        g_tramp = nullptr;
        g_original.clear();
        return false;
    }

    DWORD old = 0;
    if (!VirtualProtect(reinterpret_cast<void*>(target), patch, PAGE_EXECUTE_READWRITE,
                        &old)) {
        VirtualFree(g_stub, 0, MEM_RELEASE);
        VirtualFree(g_tramp, 0, MEM_RELEASE);
        g_stub = g_tramp = nullptr;
        g_original.clear();
        return false;
    }

    WriteAbsJmp(reinterpret_cast<uint8_t*>(target),
                reinterpret_cast<uintptr_t>(g_stub));
    for (size_t i = kPatchSize; i < patch; ++i) {
        reinterpret_cast<uint8_t*>(target)[i] = 0x90;  // nop padding
    }
    FlushInstructionCache(GetCurrentProcess(), reinterpret_cast<void*>(target), patch);

    DWORD ignored = 0;
    VirtualProtect(reinterpret_cast<void*>(target), patch, old, &ignored);

    g_target = target;
    g_patchLen = patch;
    g_hits.store(0);
    g_firstHit.store(0);
    return true;
}

bool RemoveInlineHook() {
    if (!IsHooked()) return false;

    DWORD old = 0;
    VirtualProtect(reinterpret_cast<void*>(g_target), g_patchLen, PAGE_EXECUTE_READWRITE,
                   &old);
    std::memcpy(reinterpret_cast<void*>(g_target), g_original.data(), g_patchLen);
    FlushInstructionCache(GetCurrentProcess(), reinterpret_cast<void*>(g_target), g_patchLen);
    DWORD ignored = 0;
    VirtualProtect(reinterpret_cast<void*>(g_target), g_patchLen, old, &ignored);

    VirtualFree(g_stub, 0, MEM_RELEASE);
    VirtualFree(g_tramp, 0, MEM_RELEASE);
    g_stub = nullptr;
    g_tramp = nullptr;
    g_target = 0;
    g_patchLen = 0;
    g_original.clear();
    return true;
}
