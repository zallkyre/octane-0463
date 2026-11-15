#pragma once
#include <cstdint>
#include <cstddef>
#include <string>

// Saved volatile state of the hooked function, in stack order.
// A callback may edit these; they are restored before the original code runs.
#if defined(_WIN64)
struct SavedRegs {
    uint64_t r11, r10, r9, r8, rdx, rcx, rax, flags;
};
#else
struct SavedRegs {
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax, flags;
};
#endif

using HookCallback = void (*)(SavedRegs* regs);

// What a detour at a given address would do, decided before anything is patched.
struct HookPlanInfo {
    bool ok = false;           // safe to install as planned
    size_t patchLen = 0;       // bytes actually copied/patched (instruction aligned)
    bool relative = false;     // copied bytes contain a rel8/rel32 branch or call
    bool terminal = false;     // copied bytes contain ret/int3/ud2/hlt
    std::string text;          // decoded prologue ("55 push ebp; ...")
    std::string reason;        // why ok == false
};

// Decides the detour for `target`, covering at least `minLen` bytes and always
// ending on an instruction boundary.
HookPlanInfo PlanHook(uintptr_t target, size_t minLen);

#if defined(_WIN64)
constexpr size_t kHookMinLen = 14;  // jmp qword ptr [rip+0] + abs64
#else
constexpr size_t kHookMinLen = 6;   // push imm32 ; ret
#endif

// Installs a jump at `target` (patchLen bytes, >= kHookMinLen) that routes to an
// internal stub which saves registers, calls HookThunk, restores and continues.
// `patchLen` is a minimum: the real length is the next instruction boundary.
bool InstallInlineHook(uintptr_t target, size_t patchLen);
bool RemoveInlineHook();

bool IsHooked();
uintptr_t HookTarget();
size_t HookPatchLen();
const HookPlanInfo& LastHookPlan();
uint64_t HookHits();
uint64_t HookFirstHitTick();
void SetHookCallback(HookCallback cb);

// First argument of the hooked call as a pointer-sized value.
// x64: rcx (Win64 fastcall). x86: [esp+4] (cdecl stack argument).
uintptr_t HookFirstArg(const SavedRegs* regs);
