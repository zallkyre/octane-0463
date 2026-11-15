// Exercises the lua bridge plumbing (ABI + exec flow) without a real Lua build.
// A faithful-signature stub host stands in for luaL_loadbuffer/lua_pcall.
#include <windows.h>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <string>

#include "lua_bridge.h"

namespace {

std::string g_code;
std::string g_value;
bool g_hasValue = false;

int __cdecl stub_loadbuffer(void*, const char* buff, size_t sz, const char*) {
    g_code.assign(buff, sz);
    return 0;
}

int __cdecl stub_luau_load(void*, const char*, const char* data, size_t sz, int) {
    g_code.assign(data, sz);
    return 0;
}

int __cdecl stub_pcall(void*, int, int, int) {
    g_hasValue = true;
    if (g_code == "boom") {
        g_value = "simulated error";
        return 1;
    }
    g_value = "ok";
    return 0;
}

const char* __cdecl stub_tostring(void*, int, size_t* len) {
    if (!g_hasValue) return nullptr;
    if (len) *len = g_value.size();
    return g_value.c_str();
}

int __cdecl stub_gettop(void*) { return g_hasValue ? 1 : 0; }

void __cdecl stub_settop(void*, int) { g_hasValue = false; }

}  // namespace

int main() {
    LuaSetApi("loadbuffer", reinterpret_cast<uintptr_t>(&stub_loadbuffer));
    LuaSetApi("pcall", reinterpret_cast<uintptr_t>(&stub_pcall));
    LuaSetApi("tostring", reinterpret_cast<uintptr_t>(&stub_tostring));
    LuaSetApi("gettop", reinterpret_cast<uintptr_t>(&stub_gettop));
    LuaSetApi("settop", reinterpret_cast<uintptr_t>(&stub_settop));
    LuaSetState(0x1234);

    bool okPath = LuaExec("print('hi')");
    bool errPath = !LuaExec("boom");

    // switch to the Luau 5-arg loader and run again
    LuaSetApi("luau_load", reinterpret_cast<uintptr_t>(&stub_luau_load));
    bool luauPath = LuaExec("print('luau')");

    std::printf("[test] exec_ok=%d exec_error_path=%d luau_ok=%d\n", static_cast<int>(okPath),
                static_cast<int>(errPath), static_cast<int>(luauPath));
    bool pass = okPath && errPath && luauPath;
    std::printf("[test] %s\n", pass ? "PASS" : "FAIL");
    return pass ? 0 : 2;
}
