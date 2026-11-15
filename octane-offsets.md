# OctanePlayer.exe — 0.463.0.417004 (2021-01-22)

Verified against `clients\2021\OctanePlayer.exe`, SHA-256
`8F8337B073186F9A69904DA6BFE6595FF2F0A1FF925BB3779C42CDCD21073F21`.
Image base `0x400000`, x86. RVAs below are stable for this build only.

| function | RVA | VA | notes |
|---|---|---|---|
| lua_gettop | 0xF413C0 | 0x13413C0 | `(top-base)/16`, takes `lua_State*` |
| lua_pcall | 0xF41980 | 0x1341980 | 4 args, calls luaD_pcall with f_call |
| luaD_pcall | 0xF43EF0 | 0x1343EF0 | 5 args, called by pcall + interpreter |
| luau_load | 0xF4C710 | 0x134C710 | 5 args, bytecode loader |

## Key facts

- `lua_State`: `top` = `+0x10`, `base` = `+0x14`, `global` = `+0x18`, `ci` = `+0x1C`,
  `stack_last` = `+0x20`.
- **LBC_VERSION = 1** in the client (`cmp al,1` in luau_load) — matches Luau 0.501,
  so compiler output from that revision loads.
- `luau_load` takes **bytecode**, not source: compile first, then load.
- `Lua 5.1` / Luau string pool at RVA `0x1D2F8C0`+.

## exec flow

1. hook `lua_gettop` (0x13413C0) → first arg = `lua_State*`, `capture` stores it.
2. compile script with Luau Compiler (LBC_VERSION 1) → bytecode blob.
3. `luau_load(L, "@console", bytecode, size, 0)` → pushes the closure.
4. `lua_pcall(L, 0, -1 /*LUA_MULTRET*/, 0)`.
5. restore stack with settop; read results with tolstring.

## Payload config

```
gettop   = 0xF413C0
pcall    = 0xF41980
luau_load= 0xF4C710
tostring = 0xF42BF0
```

## loadstring (needs two more RVAs)

`lua_setglobal` is a macro here (`lua_setfield(L, -10002, name)`), so registering
the global needs the real functions:

| function | RVA | status |
|---|---|---|
| lua_pushcclosure | ? | **not found yet** |
| lua_setfield | ? | **not found yet** |

Static candidates from the `push -10002` (0xFFFFD8EE) call sites, unverified:
`0xF40BD0`, `0xF41910`, `0xF41E40`, `0xF420B0`, `0xF422E0`. Do not bind a
candidate without confirming it; a wrong setter corrupts the Lua stack.

`LUA_GLOBALSINDEX = -10002`. The payload exposes `LOADSTRING` (pipe) and
`loadstring` (console) and refuses without both addresses.

## Verified on the live client (0.463.0.417004)

| probe | result |
|---|---|
| `lua_gettop` hook (`0xF413C0`) | fires ~120/s idle; state capture works |
| `lua_pcall` hook (`0xF41980`) | installs (6-byte clean prologue), **0 calls in-game** |
| `exec "return 1+1"` | `native fault in lua_pcall`; client survives via SEH |
| prologues at `0xF43EF0`, `0xF4C710`, `0xF413C0` | all decode to clean 6-byte hooks |

Conclusion: 0.463 does not route script execution through `lua_pcall`, so it is
the wrong trampoline. `luaD_pcall` (`0xF43EF0`) is the next candidate.
