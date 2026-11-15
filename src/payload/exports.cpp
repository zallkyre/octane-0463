// Public API mirroring the usual executor surface: attach / execute / isAttached.
#include <windows.h>

#include "hook.h"
#include "lua_bridge.h"

#include <string>

extern "C" __declspec(dllexport) int __cdecl attach() {
    uintptr_t entry = LuaGetTopAddress();
    if (entry == 0) return 0;
    if (IsHooked()) {
        LuaArmCapture();
        return 1;
    }
    if (!InstallInlineHook(entry, kHookMinLen)) return 0;
    LuaArmCapture();
    return 1;
}

extern "C" __declspec(dllexport) int __cdecl execute(const char* source) {
    if (!source) return 0;
    std::string out;
    return LuaSubmit(source, out, 5000) ? 1 : 0;
}

extern "C" __declspec(dllexport) int __cdecl isAttached() {
    return (IsHooked() && LuaState() != 0) ? 1 : 0;
}
