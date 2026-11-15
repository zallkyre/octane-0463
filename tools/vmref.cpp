// Minimal driver that links the vendored Luau VM so its luaV_execute (and the
// 77 opcode handlers) end up in vmref.exe, for offline handler fingerprinting.
#include "lua.h"
#include "lualib.h"

#include <cstdio>

int main() {
    lua_State* L = luaL_newstate();
    if (!L) {
        std::printf("newstate failed\n");
        return 1;
    }
    luaL_openlibs(L);
    std::printf("vmref: state ok\n");
    lua_close(L);
    return 0;
}
