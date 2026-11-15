#include "lua_bridge.h"

#include "hook.h"
#include "mem.h"

#include "Luau/Compiler.h"

#include <cctype>
#include <chrono>
#include <cstdio>
#include <condition_variable>
#include <cstring>
#include <exception>
#include <iostream>
#include <mutex>
#include <sstream>
#include <string>
#include <vector>

namespace {

using LoadBufferFn = int(__cdecl*)(void* L, const char* buff, size_t sz, const char* name);
using LuauLoadFn = int(__cdecl*)(void* L, const char* chunkname, const char* data,
                                 size_t size, int env);
using PCallFn = int(__cdecl*)(void* L, int nargs, int nresults, int errfunc);
using ToStringFn = const char*(__cdecl*)(void* L, int idx, size_t* len);
using GetTopFn = int(__cdecl*)(void* L);
using SetTopFn = void(__cdecl*)(void* L, int idx);
using PushCClosureFn = void(__cdecl*)(void* L, int(__cdecl*)(void* L), int nupvalues);
using SetFieldFn = void(__cdecl*)(void* L, int idx, const char* k);

// LUA_GLOBALSINDEX in Lua 5.1 / Luau 0.463: -10002
constexpr int kLuaGlobalsIndex = -10002;
// lua_CFunction signature for the runtime loadstring.
using LuaCFunction = int(__cdecl*)(void* L);

enum class Loader { None, LoadBuffer, Luau };

constexpr int kLuaMulRet = -1;
constexpr int kNativeFault = -999;

// Last SEH fault, for reporting where the client took the fault.
thread_local int g_faultCode = 0;
thread_local uintptr_t g_faultAddr = 0;

uintptr_t g_state = 0;
LoadBufferFn g_load = nullptr;
LuauLoadFn g_luau = nullptr;
PCallFn g_pcall = nullptr;
ToStringFn g_tostr = nullptr;
GetTopFn g_gettop = nullptr;
SetTopFn g_settop = nullptr;
PushCClosureFn g_pushcclosure = nullptr;
SetFieldFn g_setfield = nullptr;
uintptr_t g_gettopAddr = 0;
Loader g_loader = Loader::None;
bool g_captureArmed = false;

// Compile settings, switchable at runtime so one session can test several
// bytecode shapes against the host VM.
int g_optLevel = 0;
int g_dbgLevel = 0;

std::mutex g_execMutex;
std::condition_variable g_execCv;
std::string g_pendingSource;
std::string g_pendingBytecode;
bool g_pendingIsBytecode = false;
std::string g_pendingOutput;
bool g_pendingDone = false;
bool g_pendingActive = false;

std::string Hex(uintptr_t v) {
    std::ostringstream o;
    o << "0x" << std::hex << std::uppercase << v;
    return o.str();
}

uintptr_t FindAscii(const ModuleRange& mod, const std::string& needle) {
    std::vector<uint8_t> bytes(needle.begin(), needle.end());
    std::vector<bool> wild(bytes.size(), false);
    return ScanModule(mod, bytes, wild);
}

// SEH wrappers: a bad call must not take the host down. POD only, no unwinding.
int CallLoad(LuauLoadFn fn, void* L, const char* name, const char* data, size_t size,
             int env) {
#ifdef _MSC_VER
    __try {
        return fn(L, name, data, size, env);
    } __except (g_faultCode = GetExceptionCode(),
                g_faultAddr = reinterpret_cast<uintptr_t>(
                    GetExceptionInformation()->ExceptionRecord->ExceptionAddress),
                EXCEPTION_EXECUTE_HANDLER) {
        return kNativeFault;
    }
#else
    return fn(L, name, data, size, env);
#endif
}

int CallLoadBuffer(LoadBufferFn fn, void* L, const char* data, size_t size,
                   const char* name) {
#ifdef _MSC_VER
    __try {
        return fn(L, data, size, name);
    } __except (g_faultCode = GetExceptionCode(),
                g_faultAddr = reinterpret_cast<uintptr_t>(
                    GetExceptionInformation()->ExceptionRecord->ExceptionAddress),
                EXCEPTION_EXECUTE_HANDLER) {
        return kNativeFault;
    }
#else
    return fn(L, data, size, name);
#endif
}

int CallPCall(PCallFn fn, void* L, int nargs, int nresults, int errfunc) {
#ifdef _MSC_VER
    __try {
        return fn(L, nargs, nresults, errfunc);
    } __except (g_faultCode = GetExceptionCode(),
                g_faultAddr = reinterpret_cast<uintptr_t>(
                    GetExceptionInformation()->ExceptionRecord->ExceptionAddress),
                EXCEPTION_EXECUTE_HANDLER) {
        return kNativeFault;
    }
#else
    return fn(L, nargs, nresults, errfunc);
#endif
}

int CallGetTop(GetTopFn fn, void* L) {
#ifdef _MSC_VER
    __try { return fn(L); } __except (EXCEPTION_EXECUTE_HANDLER) { return kNativeFault; }
#else
    return fn(L);
#endif
}

const char* CallToStr(ToStringFn fn, void* L, int idx, size_t* len) {
#ifdef _MSC_VER
    __try { return fn(L, idx, len); } __except (EXCEPTION_EXECUTE_HANDLER) { return nullptr; }
#else
    return fn(L, idx, len);
#endif
}

void CallSetTop(SetTopFn fn, void* L, int idx) {
#ifdef _MSC_VER
    __try { fn(L, idx); } __except (EXCEPTION_EXECUTE_HANDLER) { }
#else
    fn(L, idx);
#endif
}

std::string RunCaptured(const std::string& source) {
    std::ostringstream buffer;
    std::streambuf* old = std::cout.rdbuf(buffer.rdbuf());
    bool ok = LuaExec(source);
    std::cout.rdbuf(old);
    std::string text = buffer.str();
    if (text.empty() && !ok) text = "exec failed";
    return text;
}

// "code 0xC0000005 at 0x... (client RVA 0x...)" for the last SEH fault.
std::string FaultText(const char* where) {
    std::ostringstream o;
    o << "native fault in " << where << ": code 0x" << std::hex << std::uppercase
      << g_faultCode << " at 0x" << g_faultAddr;
    ModuleRange m = MainModule();
    if (m.base && g_faultAddr >= m.base && g_faultAddr < m.base + m.size) {
        o << " (client RVA 0x" << (g_faultAddr - m.base) << ")";
    } else {
        o << " (outside the client image)";
    }
    return o.str();
}

// Runs a raw bytecode blob: load, pcall, print results. Used to probe the host's
// loader/VM format without recompiling on every iteration.
std::string ExecBytecode(const std::string& bytecode) {
    std::ostringstream buffer;
    std::streambuf* old = std::cout.rdbuf(buffer.rdbuf());
    bool ok = false;
    do {
        if (g_state == 0 || g_luau == nullptr || g_pcall == nullptr) {
            std::cout << "missing api\n";
            break;
        }
        void* L = reinterpret_cast<void*>(g_state);
        int base = g_gettop ? CallGetTop(g_gettop, L) : 0;

        int rc = CallLoad(g_luau, L, "@bc", bytecode.data(), bytecode.size(), 0);
        if (rc == kNativeFault) {
            std::cout << FaultText("luau_load") << "\n";
            break;
        }
        if (rc != 0) {
            if (g_tostr) {
                const char* err = CallToStr(g_tostr, L, -1, nullptr);
                std::cout << "load error: " << (err ? err : "(unprintable)") << "\n";
            } else {
                std::cout << "load error (code " << rc << ")\n";
            }
            if (g_settop) CallSetTop(g_settop, L, base);
            break;
        }

        rc = CallPCall(g_pcall, L, 0, kLuaMulRet, 0);
        if (rc == kNativeFault) {
            std::cout << FaultText("lua_pcall") << "\n";
            break;
        }
        if (rc != 0) {
            if (g_tostr) {
                const char* err = CallToStr(g_tostr, L, -1, nullptr);
                std::cout << "runtime error: " << (err ? err : "(unprintable)") << "\n";
            } else {
                std::cout << "runtime error (code " << rc << ")\n";
            }
            if (g_settop) CallSetTop(g_settop, L, base);
            break;
        }

        if (g_tostr && g_gettop) {
            int top = CallGetTop(g_gettop, L);
            for (int i = base + 1; i <= top; ++i) {
                size_t len = 0;
                const char* s = CallToStr(g_tostr, L, i, &len);
                if (s) std::cout << "-> " << std::string(s, len) << "\n";
            }
        }
        if (g_settop) CallSetTop(g_settop, L, base);
        ok = true;
    } while (false);

    std::cout.rdbuf(old);
    std::string text = buffer.str();
    if (text.empty() && !ok) text = "bytecode exec failed";
    return text;
}
int __cdecl LoadstringImpl(void* L) {
    if (L == nullptr || g_tostr == nullptr || g_luau == nullptr) return 0;

    size_t len = 0;
    const char* src = CallToStr(g_tostr, L, 1, &len);
    if (src == nullptr) return 0;  // not a string: return nil

    std::string bytecode;
    try {
        Luau::CompileOptions options;
        options.optimizationLevel = g_optLevel;
        options.debugLevel = g_dbgLevel;
        bytecode = Luau::compile(std::string(src, len), options);
    } catch (const std::exception&) {
        return 0;  // compile error: nil, err unavailable without pushstring
    }
    if (bytecode.empty()) return 0;

    int rc = CallLoad(g_luau, L, "@loadstring", bytecode.data(), bytecode.size(), 0);
    if (rc == kNativeFault) return 0;
    // Both paths leave exactly one value on the stack: the function, or the
    // error object luau_load pushed.
    return 1;
}

}  // namespace

void LuaSetApi(const std::string& name, uintptr_t addr) {
    if (addr == 0) {
        std::cout << "bad address\n";
        return;
    }
    if (name == "luau_load" || name == "luau") {
        g_luau = reinterpret_cast<LuauLoadFn>(addr);
        g_loader = Loader::Luau;
    } else if (name == "loadbuffer" || name == "load") {
        g_load = reinterpret_cast<LoadBufferFn>(addr);
        g_loader = Loader::LoadBuffer;
    } else if (name == "pcall" || name == "call") {
        g_pcall = reinterpret_cast<PCallFn>(addr);
    } else if (name == "tostring" || name == "tolstring") {
        g_tostr = reinterpret_cast<ToStringFn>(addr);
    } else if (name == "gettop") {
        g_gettop = reinterpret_cast<GetTopFn>(addr);
        g_gettopAddr = addr;
    } else if (name == "settop") {
        g_settop = reinterpret_cast<SetTopFn>(addr);
    } else if (name == "pushcclosure" || name == "pushcfunction") {
        g_pushcclosure = reinterpret_cast<PushCClosureFn>(addr);
    } else if (name == "setfield" || name == "setglobal") {
        g_setfield = reinterpret_cast<SetFieldFn>(addr);
    } else {
        std::cout << "unknown api: " << name
                  << " (luau_load|loadbuffer|pcall|tostring|gettop|settop|"
                     "pushcclosure|setfield)\n";
        return;
    }
    std::cout << name << " = " << Hex(addr) << "\n";
}

void LuaPrintApi() {
    const char* loader = g_loader == Loader::Luau ? "luau_load"
                         : g_loader == Loader::LoadBuffer ? "loadbuffer"
                                                          : "(none)";
    std::cout << "state      " << (g_state ? Hex(g_state) : "(none)")
              << "\nloader     " << loader
              << "\nloadbuffer " << (g_load ? Hex(reinterpret_cast<uintptr_t>(g_load)) : "-")
              << "\nluau_load  " << (g_luau ? Hex(reinterpret_cast<uintptr_t>(g_luau)) : "-")
              << "\npcall      " << (g_pcall ? Hex(reinterpret_cast<uintptr_t>(g_pcall)) : "-")
              << "\ntostring   " << (g_tostr ? Hex(reinterpret_cast<uintptr_t>(g_tostr)) : "-")
              << "\ngettop     " << (g_gettop ? Hex(reinterpret_cast<uintptr_t>(g_gettop)) : "-")
              << "\nsettop     " << (g_settop ? Hex(reinterpret_cast<uintptr_t>(g_settop)) : "-")
              << "\npushcclosure " << (g_pushcclosure ? Hex(reinterpret_cast<uintptr_t>(g_pushcclosure)) : "-")
              << "\nsetfield   " << (g_setfield ? Hex(reinterpret_cast<uintptr_t>(g_setfield)) : "-")
              << "\n";
}

void LuaSetState(uintptr_t state) {
    g_state = state;
    std::cout << "lua_State* = " << Hex(state) << "\n";
}

uintptr_t LuaState() { return g_state; }

uintptr_t LuaGetTopAddress() { return g_gettopAddr; }

uintptr_t LuaPcallAddress() { return reinterpret_cast<uintptr_t>(g_pcall); }

bool LuaLoadstringReady() { return g_pushcclosure != nullptr && g_setfield != nullptr; }

void LuaSetCompileOptions(int optimizationLevel, int debugLevel) {
    if (optimizationLevel < 0) optimizationLevel = 0;
    if (optimizationLevel > 2) optimizationLevel = 2;
    if (debugLevel < 0) debugLevel = 0;
    if (debugLevel > 2) debugLevel = 2;
    g_optLevel = optimizationLevel;
    g_dbgLevel = debugLevel;
}

void LuaGetCompileOptions(int& optimizationLevel, int& debugLevel) {
    optimizationLevel = g_optLevel;
    debugLevel = g_dbgLevel;
}

bool LuaRegisterLoadstring() {
    if (g_state == 0 || !LuaLoadstringReady() || g_luau == nullptr || g_tostr == nullptr) {
        return false;
    }
    void* L = reinterpret_cast<void*>(g_state);
    int before = g_gettop ? CallGetTop(g_gettop, L) : 0;
#ifdef _MSC_VER
    __try {
        g_pushcclosure(L, &LoadstringImpl, 0);
        g_setfield(L, kLuaGlobalsIndex, "loadstring");
    } __except (EXCEPTION_EXECUTE_HANDLER) {
        return false;
    }
#else
    g_pushcclosure(L, &LoadstringImpl, 0);
    g_setfield(L, kLuaGlobalsIndex, "loadstring");
#endif
    int after = g_gettop ? CallGetTop(g_gettop, L) : before;
    return after == before;  // the closure must have been consumed
}

void LuaArmCapture() { g_captureArmed = true; }

bool LuaCaptureFrom(SavedRegs* regs) {
    if (!g_captureArmed || g_state != 0) return false;
    uintptr_t candidate = HookFirstArg(regs);
    if (candidate == 0) return false;
    g_state = candidate;
    g_captureArmed = false;
    return true;
}

void LuaPrintVersion() {
    static const char* candidates[] = {"Lua 5.0", "Lua 5.1", "Lua 5.2",
                                       "Lua 5.3", "Lua 5.4", "LuaJIT",
                                       "Luau"};
    ModuleRange m = MainModule();
    if (m.base == 0) {
        std::cout << "no main module\n";
        return;
    }
    bool any = false;
    for (const char* name : candidates) {
        uintptr_t hit = FindAscii(m, name);
        if (hit) {
            std::cout << "found \"" << name << "\" at " << Hex(hit) << "\n";
            any = true;
        }
    }
    if (!any) {
        std::cout << "no Lua version string in the main module (look in modules with 'mods')\n";
    }
    std::cout << "note: the string only fingerprints the build; LuaJIT reports \"Lua 5.1\" too\n";
}

bool LuaExec(const std::string& source) {
    if (g_state == 0) {
        std::cout << "no lua_State* - run 'lua-init' (hooks gettop and captures)\n";
        return false;
    }
    if (!g_pcall || (g_loader == Loader::Luau ? !g_luau : !g_load)) {
        std::cout << "missing api - set 'luaapi luau_load <addr>' and 'luaapi pcall <addr>'\n";
        return false;
    }

    std::string bytecode;
    if (g_loader == Loader::Luau) {
        try {
            Luau::CompileOptions options;
            options.optimizationLevel = g_optLevel;
            options.debugLevel = g_dbgLevel;
            bytecode = Luau::compile(source, options);
        } catch (const std::exception& e) {
            std::cout << "compile error: " << e.what() << "\n";
            return false;
        }
        if (bytecode.empty()) {
            std::cout << "compile error: empty output\n";
            return false;
        }
    }

    void* L = reinterpret_cast<void*>(g_state);
    int base = g_gettop ? CallGetTop(g_gettop, L) : 0;

    int rc = (g_loader == Loader::Luau)
                 ? CallLoad(g_luau, L, "@console", bytecode.data(), bytecode.size(), 0)
                 : CallLoadBuffer(g_load, L, source.c_str(), source.size(), "@console");
    if (rc == kNativeFault) {
        std::cout << FaultText("luau_load") << "\n";
        return false;
    }
    if (rc != 0) {
        if (g_tostr) {
            const char* err = CallToStr(g_tostr, L, -1, nullptr);
            std::cout << "load error: " << (err ? err : "(unprintable)") << "\n";
        } else {
            std::cout << "load error (code " << rc << ")\n";
        }
        if (g_settop) CallSetTop(g_settop, L, base);
        return false;
    }

    rc = CallPCall(g_pcall, L, 0, kLuaMulRet, 0);
    if (rc == kNativeFault) {
        std::cout << FaultText("lua_pcall") << "\n";
        return false;
    }
    if (rc != 0) {
        if (g_tostr) {
            const char* err = CallToStr(g_tostr, L, -1, nullptr);
            std::cout << "runtime error: " << (err ? err : "(unprintable)") << "\n";
        } else {
            std::cout << "runtime error (code " << rc << ")\n";
        }
        if (g_settop) CallSetTop(g_settop, L, base);
        return false;
    }

    if (g_tostr && g_gettop) {
        int top = CallGetTop(g_gettop, L);
        for (int i = base + 1; i <= top; ++i) {
            size_t len = 0;
            const char* s = CallToStr(g_tostr, L, i, &len);
            if (s) std::cout << "-> " << std::string(s, len) << "\n";
        }
    }
    if (g_settop) CallSetTop(g_settop, L, base);
    return true;
}

int LuaLoadRaw(const std::string& bytes) {
    if (g_state == 0 || g_luau == nullptr) return -1;
    return CallLoad(g_luau, reinterpret_cast<void*>(g_state), "@probe", bytes.data(),
                     bytes.size(), 0);
}

namespace {

std::string HexLine(uintptr_t addr, const uint8_t* p, size_t n) {
    char line[16 * 3 + 1] = {};
    size_t o = 0;
    for (size_t i = 0; i < n && o + 4 < sizeof(line); ++i)
        o += static_cast<size_t>(std::snprintf(line + o, sizeof(line) - o, "%02X ", p[i]));
    std::ostringstream s;
    s << "0x" << std::hex << std::uppercase << addr << "  " << line;
    return s.str();
}

// Loads `return 2`, then dumps the TValue, the closure and the candidate Proto so
// the host's real field order can be read off the heap.
std::string ProbeStructures(const std::string& bytecode) {
    std::ostringstream out;
    if (g_state == 0 || g_luau == nullptr || !g_gettop) return "missing api\n";

    void* L = reinterpret_cast<void*>(g_state);
    int base = CallGetTop(g_gettop, L);
    int rc = CallLoad(g_luau, L, "@probe", bytecode.data(), bytecode.size(), 0);
    out << "load_status=" << rc << "\n";
    if (rc != 0) return out.str();

    uintptr_t Lp = g_state;
    uint32_t top = 0, bas = 0;
    if (!SafeRead(Lp + 0x10, &top, 4) || !SafeRead(Lp + 0x14, &bas, 4)) {
        out << "cannot read lua_State\n";
        return out.str();
    }
    out << "L=0x" << std::hex << std::uppercase << Lp << " top=0x" << top
        << " base=0x" << bas << std::dec << " slots=" << ((top - bas) / 16) << "\n";

    uint8_t tv[16] = {};
    if (!SafeRead(top - 16, tv, sizeof(tv))) {
        out << "cannot read TValue\n";
        return out.str();
    }
    out << HexLine(top - 16, tv, sizeof(tv)) << "\n";

    uint32_t closure = 0;
    std::memcpy(&closure, tv, 4);
    out << "closure=0x" << std::hex << std::uppercase << closure << std::dec << "\n";

    uint8_t cl[48] = {};
    if (closure && SafeRead(closure, cl, sizeof(cl))) {
        out << HexLine(closure, cl, 32) << "\n";
        for (int slot : {8, 12, 16, 20, 24}) {
            uint32_t ptr = 0;
            std::memcpy(&ptr, cl + slot, 4);
            if (ptr < 0x10000 || ptr > 0xF0000000) continue;
            uint8_t p[64] = {};
            if (!SafeRead(ptr, p, sizeof(p))) continue;
            out << "  [" << slot << "] -> 0x" << std::hex << std::uppercase << ptr
                << std::dec << "\n";
            out << "    " << HexLine(ptr, p, 32) << "\n";
            uint32_t f16 = 0, f20 = 0, f24 = 0;
            std::memcpy(&f16, p + 16, 4);
            std::memcpy(&f20, p + 20, 4);
            std::memcpy(&f24, p + 24, 4);
            out << "    +16=0x" << std::hex << std::uppercase << f16 << " +20=0x" << f20
                << " +24=0x" << f24 << std::dec << "\n";
        }
    }

    if (g_settop) CallSetTop(g_settop, L, base);
    return out.str();
}

}  // namespace

std::string LuaProbeStructures(const std::string& bytecode) {
    return ProbeStructures(bytecode);
}

namespace {

int g_fieldCode = 0;
uintptr_t g_fieldAddr = 0;

// POD-only wrapper so SEH is allowed (no C++ objects in this frame).
void CallField3(void(__cdecl* fn)(void*, int, const char*), void* L, const char* name) {
    g_fieldCode = 0;
    g_fieldAddr = 0;
#ifdef _MSC_VER
    __try {
        fn(L, kLuaGlobalsIndex, name);
    } __except (g_fieldCode = GetExceptionCode(),
                g_fieldAddr = reinterpret_cast<uintptr_t>(
                    GetExceptionInformation()->ExceptionRecord->ExceptionAddress),
                EXCEPTION_EXECUTE_HANDLER) {
    }
#else
    fn(L, kLuaGlobalsIndex, name);
#endif
}

// Calls a candidate lua_setfield/lua_getfield with (L, LUA_GLOBALSINDEX, name) and
// reports how the stack moved: a setter pops one value, a getter pushes one.
std::string ProbeField(const std::string& name, const std::string& seedBytecode) {
    std::ostringstream out;
    if (g_state == 0 || !g_gettop || g_luau == nullptr) return "missing api\n";

    // Compile the push-value seed ourselves: a fixed blob is easy to get wrong
    // (shape, options) and produced misleading "seed load failed" results.
    std::string seed = seedBytecode;
    if (seed.empty()) {
        try {
            Luau::CompileOptions opt;
            opt.optimizationLevel = 1;
            opt.debugLevel = 1;
            seed = Luau::compile("return", opt);
        } catch (...) {
            return "seed compile failed\n";
        }
    }

    struct Cand { const char* label; uint32_t rva; };
    static const Cand cands[] = {
        {"0xF41CF0", 0xF41CF0}, {"0xF42170", 0xF42170},
        {"0xF41C80", 0xF41C80},
        {"0xF40BD0", 0xF40BD0}, {"0xF41E40", 0xF41E40},
    };

    void* L = reinterpret_cast<void*>(g_state);
    uintptr_t base = MainModule().base;
    int anchor = CallGetTop(g_gettop, L);

    for (const Cand& c : cands) {
        (void)anchor;
        int rc = CallLoad(g_luau, L, "@seed", seed.data(), seed.size(), 0);
        if (rc != 0) { out << c.label << ": seed load failed (rc=" << rc
                    << " bytes=" << seed.size() << ")\n"; continue; }
        int before = CallGetTop(g_gettop, L);

        auto fn = reinterpret_cast<void(__cdecl*)(void*, int, const char*)>(base + c.rva);
        CallField3(fn, L, name.c_str());

        int after = CallGetTop(g_gettop, L);
        out << c.label << "  top " << before << " -> " << after << "  delta "
            << (after - before);
        if (g_fieldCode) {
            out << "  FAULT 0x" << std::hex << std::uppercase << g_fieldCode << std::dec;
        }
        if (after > before) {
            uint32_t tv[4] = {};
            uint32_t top = 0;
            if (SafeRead(g_state + 0x10, &top, 4) && SafeRead(top - 16, tv, 16)) {
                out << "  pushed value=0x" << std::hex << std::uppercase << tv[0]
                    << " tt=0x" << tv[3] << std::dec;
            }
        }
        out << "\n";
    }

        (void)anchor;   // settop is not bound in this payload; the call was a null-pointer no-op
    return out.str();
}

}  // namespace

std::string LuaProbeField(const std::string& name, const std::string& seedBytecode) {
    return ProbeField(name, seedBytecode);
}

namespace {

// Luau 0.501 struct geometry, x86. Used only as a starting hypothesis: every
// candidate table is validated against readable memory before it is trusted.
constexpr uint32_t kTvTt = 0x0C;            // TValue.tt
constexpr uint32_t kTStringLen = 0x10;      // TString.len
constexpr uint32_t kTStringData = 0x14;     // TString.data
constexpr uint32_t kTableLsizenode = 0x0B;  // Table.lsizenode
constexpr uint32_t kTableSizearray = 0x10;  // Table.sizearray
constexpr uint32_t kTableNode = 0x20;       // Table.node
constexpr uint32_t kNodeSize = 0x20;        // sizeof(LuaNode)
constexpr uint32_t kNodeValTt = 0x0C;       // LuaNode.val.tt
constexpr uint32_t kNodeKeyVal = 0x10;      // LuaNode.key.value
constexpr uint32_t kNodeKeyTt = 0x1C;       // LuaNode.key.tt (low nibble)
constexpr uint32_t kTagString = 5;
constexpr uint32_t kTagTable = 6;
constexpr uint32_t kMaxNodeBytes = 16u * 1024u * 1024u;

bool ReadU32(uintptr_t addr, uint32_t& v) { return SafeRead(addr, &v, 4); }

bool Committed(uintptr_t addr) {
    MEMORY_BASIC_INFORMATION mbi;
    if (VirtualQuery(reinterpret_cast<LPCVOID>(addr), &mbi, sizeof(mbi)) == 0) return false;
    if (mbi.State != MEM_COMMIT) return false;
    return (mbi.Protect & (PAGE_NOACCESS | PAGE_GUARD)) == 0;
}

bool PlausiblePtr(uint32_t p) {
    return p >= 0x10000 && p < 0x7FFF0000 && (p & 3) == 0 && Committed(p);
}

bool ReadLuaString(uint32_t tstr, std::string& out) {
    out.clear();
    if (!PlausiblePtr(tstr)) return false;
    uint32_t len = 0;
    if (!ReadU32(tstr + kTStringLen, len)) return false;
    if (len > 1024) return false;
    out.assign(len, '\0');
    if (len != 0 && !SafeRead(tstr + kTStringData, &out[0], len)) {
        out.clear();
        return false;
    }
    return true;
}

bool Identifierish(const std::string& s) {
    if (s.empty() || s.size() > 128) return false;
    for (unsigned char c : s) {
        if (!(std::isalnum(c) != 0 || c == '_' || c == '.' || c == '-')) return false;
    }
    return true;
}

struct GlobalHit {
    uintptr_t stateOff = 0;
    uint32_t tablePtr = 0;
    uint32_t nodePtr = 0;
    uint32_t sizearray = 0;
    int lsizenode = 0;
    int keyCount = 0;
    int idCount = 0;
    std::vector<std::pair<std::string, uint32_t>> entries;  // name, value tag
};

// Reads one table's hash part. Fails (returns false) on any structural doubt so a
// wrong offset hypothesis is discarded instead of producing garbage.
bool WalkTable(uint32_t table, GlobalHit& hit) {
    hit.tablePtr = table;
    hit.entries.clear();
    hit.keyCount = 0;
    hit.idCount = 0;

    uint8_t lsz = 0;
    if (!SafeRead(table + kTableLsizenode, &lsz, 1)) return false;
    if (lsz > 20) return false;

    uint32_t node = 0;
    if (!ReadU32(table + kTableNode, node)) return false;
    if (node == 0) return false;
    ReadU32(table + kTableSizearray, hit.sizearray);

    uint32_t count = 1u << lsz;
    uint64_t bytes = static_cast<uint64_t>(count) * kNodeSize;
    if (bytes > kMaxNodeBytes) return false;
    if (!Committed(node)) return false;
    if (!Committed(node + static_cast<uintptr_t>(bytes) - 1)) return false;

    hit.lsizenode = lsz;
    hit.nodePtr = node;

    for (uint32_t i = 0; i < count; ++i) {
        uintptr_t n = node + static_cast<uintptr_t>(i) * kNodeSize;
        uint32_t ktt = 0;
        if (!ReadU32(n + kNodeKeyTt, ktt)) continue;
        if ((ktt & 0xF) != kTagString) continue;
        uint32_t kp = 0;
        if (!ReadU32(n + kNodeKeyVal, kp)) continue;
        std::string name;
        if (!ReadLuaString(kp, name)) continue;
        uint32_t vtt = 0;
        ReadU32(n + kNodeValTt, vtt);
        ++hit.keyCount;
        if (Identifierish(name)) ++hit.idCount;
        if (hit.entries.size() < 400) hit.entries.emplace_back(name, vtt);
    }
    return true;
}

}  // namespace

std::string LuaDumpGlobals() {
    std::ostringstream out;
    if (g_state == 0) return "no state - attach first\n";
    uintptr_t L = g_state;

    out << "L=0x" << std::hex << std::uppercase << L << std::dec << "\n";

    out << "raw:";
    for (uintptr_t off = 0; off < 0x40; off += 4) {
        uint32_t w = 0;
        if (SafeRead(L + off, &w, 4)) {
            out << " [" << std::hex << std::uppercase << off << "]=" << w;
        } else {
            break;
        }
    }
    out << std::dec << "\n";

    uint32_t gs = 0;
    if (ReadU32(L + 0x18, gs)) {
        out << "global_State* @ +0x18 = 0x" << std::hex << std::uppercase << gs
            << std::dec << "\n";
    }

    GlobalHit best;
    bool haveBest = false;

    // Treat every aligned word in a struct as a possible Table* and let the walk
    // decide. This drops any dependency on where (or whether) a TValue tag sits.
    auto scan = [&](uint32_t base, uint32_t len, const char* label) {
        if (!PlausiblePtr(base)) return;
        for (uint32_t off = 0; off + 4 <= len; off += 4) {
            uint32_t w = 0;
            if (!ReadU32(base + off, w)) continue;
            if (!PlausiblePtr(w)) continue;
            GlobalHit h;
            if (!WalkTable(w, h)) continue;
            if (h.keyCount == 0) continue;
            out << label << "+0x" << std::hex << std::uppercase << off
                << " table=0x" << w << std::dec << " lszi=" << h.lsizenode
                << " sizearray=" << h.sizearray << " keys=" << h.keyCount
                << " ids=" << h.idCount << "\n";
            if (!haveBest || h.idCount > best.idCount) {
                best = h;
                haveBest = true;
            }
        }
    };

    scan(static_cast<uint32_t>(L), 0x200, "L");
    if (PlausiblePtr(gs)) {
        scan(gs, 0x400, "GS");
        // mainthread: a committed lua_State whose +0x18 points back at global_State
        for (uint32_t off = 0; off + 4 <= 0x400; off += 4) {
            uint32_t p = 0;
            if (!ReadU32(gs + off, p)) continue;
            if (!PlausiblePtr(p)) continue;
            uint32_t back = 0;
            if (!ReadU32(p + 0x18, back)) continue;
            if (back != gs) continue;
            out << "mainthread? GS+0x" << std::hex << std::uppercase << off
                << " -> 0x" << p << std::dec << "\n";
            scan(p, 0x200, "MT");
            break;
        }
    }

    if (!haveBest) {
        out << "no table found in L/GS/MT; dump the raw words above\n";
        return out.str();
    }

    out << "== best table=0x" << std::hex << std::uppercase << best.tablePtr
        << std::dec << " lszi=" << best.lsizenode << " keys=" << best.keyCount
        << " ids=" << best.idCount << " ==\n";

    static const char* wanted[] = {"loadstring", "print",   "game", "require",
                                   "_G",         "script",  "Instance", "pcall",
                                   "typeof",     "warn",    "getfenv", "setfenv"};
    for (const char* w : wanted) {
        for (const auto& e : best.entries) {
            if (e.first == w) {
                out << "FOUND " << w << " tag=" << e.second << "\n";
                break;
            }
        }
    }

    int shown = 0;
    for (const auto& e : best.entries) {
        out << "  " << e.first << " (tag " << e.second << ")\n";
        if (++shown >= 300) break;
    }
    return out.str();
}

// ---- cross-thread submission: runs on the Lua thread inside the hook ----

bool LuaSubmit(const std::string& source, std::string& output, unsigned timeoutMs) {
    {
        std::lock_guard<std::mutex> lock(g_execMutex);
        if (g_pendingActive) return false;
        g_pendingSource = source;
        g_pendingBytecode.clear();
        g_pendingIsBytecode = false;
        g_pendingOutput.clear();
        g_pendingDone = false;
        g_pendingActive = true;
    }
    std::unique_lock<std::mutex> lock(g_execMutex);
    bool finished = g_execCv.wait_for(lock, std::chrono::milliseconds(timeoutMs),
                                      [] { return g_pendingDone; });
    if (!finished) {
        g_pendingActive = false;
        return false;
    }
    output = g_pendingOutput;
    g_pendingActive = false;
    return true;
}

bool LuaSubmitBytecode(const std::string& bytecode, std::string& output,
                       unsigned timeoutMs) {
    {
        std::lock_guard<std::mutex> lock(g_execMutex);
        if (g_pendingActive) return false;
        g_pendingBytecode = bytecode;
        g_pendingIsBytecode = true;
        g_pendingSource.clear();
        g_pendingOutput.clear();
        g_pendingDone = false;
        g_pendingActive = true;
    }
    std::unique_lock<std::mutex> lock(g_execMutex);
    bool finished = g_execCv.wait_for(lock, std::chrono::milliseconds(timeoutMs),
                                      [] { return g_pendingDone; });
    if (!finished) {
        g_pendingActive = false;
        g_pendingIsBytecode = false;
        return false;
    }
    output = g_pendingOutput;
    g_pendingActive = false;
    g_pendingIsBytecode = false;
    return true;
}

static thread_local bool g_inExec = false;

void LuaRunPendingOnLuaThread() {
    if (g_state == 0 || g_inExec) return;
    std::string source;
    std::string bytecode;
    bool isBytecode = false;
    {
        std::lock_guard<std::mutex> lock(g_execMutex);
        if (!g_pendingActive || g_pendingDone) return;
        source = g_pendingSource;
        bytecode = g_pendingBytecode;
        isBytecode = g_pendingIsBytecode;
    }
    g_inExec = true;
    std::string result;
    if (isBytecode && bytecode.rfind("\x01PROBE:", 0) == 0)
        result = ProbeField(bytecode.substr(7), std::string());   // runs on the Lua thread
    else if (isBytecode && bytecode == "\x01GLOBALS")
        result = LuaDumpGlobals();
    else if (isBytecode)
        result = ExecBytecode(bytecode);
    else
        result = RunCaptured(source);
    g_inExec = false;
    {
        std::lock_guard<std::mutex> lock(g_execMutex);
        g_pendingOutput = result;
        g_pendingDone = true;
    }
    g_execCv.notify_all();
}

// ---- capture the game's own bytecode from luau_load ----

namespace {

void LoadHookCb(SavedRegs* regs) {
    uintptr_t esp = regs->esp;   // original stack: [esp]=ret, then args
    static int logged = 0;

    auto tryLog = [&](uintptr_t dataOff, uintptr_t sizeOff) -> bool {
        uint32_t data = 0, size = 0;
        if (!SafeRead(esp + dataOff, &data, 4)) return false;
        if (!SafeRead(esp + sizeOff, &size, 4)) return false;
        if (data == 0 || size < 8 || size > (1u << 20)) return false;
        uint32_t n = size > 160 ? 160 : size;
        uint8_t buf[160];
        if (!SafeRead(data, buf, n)) return false;
        std::cout << "[load off=0x" << std::hex << dataOff << " data=0x" << data
                  << " size=" << std::dec << size << " bytes=";
        char hx[4];
        for (uint32_t i = 0; i < n; ++i) {
            std::snprintf(hx, sizeof(hx), "%02X", buf[i]);
            std::cout << hx;
        }
        std::cout << "\n";
        return true;
    };

    if (logged < 8) {
        for (int k = 0; k < 6 && logged < 8; ++k) {
            uintptr_t dataOff = 0x8 + static_cast<uintptr_t>(k) * 4;
            if (tryLog(dataOff, dataOff + 4)) {
                ++logged;
                break;
            }
        }
    }
    LuaRunPendingOnLuaThread();
}

}  // namespace

bool LuaHookLoad() {
    ModuleRange m = MainModule();
    if (m.base == 0) return false;
    uintptr_t addr = m.base + 0xF4C710;   // luau_load
    if (IsHooked()) RemoveInlineHook();
    SetHookCallback(&LoadHookCb);
    HookPlanInfo plan = PlanHook(addr, kHookMinLen);
    if (!plan.ok) {
        std::cout << "hookload: " << plan.reason << "\n";
        return false;
    }
    if (!InstallInlineHook(addr, kHookMinLen)) return false;
    std::cout << "hooked luau_load at 0x" << std::hex << std::uppercase << addr
              << std::dec << " len=" << HookPatchLen() << "\n";
    return true;
}
