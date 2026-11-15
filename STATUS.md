# Octane 0.463 executor — full status / handoff

Everything an agent needs to resume. Read this first, then `octane-offsets.md`
for the original offset notes (partly superseded — see "Corrections").

---

## 1. Target

| | |
|---|---|
| exe | `OctanePlayer.exe` 0.463.0.417004 (2021-01-22) |
| path | `C:\Users\zallkyre _3\AppData\Local\Octane\clients\2021\OctanePlayer.exe` |
| arch | x86, image base `0x400000` |
| SHA-256 | `8F8337B073186F9A69904DA6BFE6595FF2F0A1FF925BB3779C42CDCD21073F21` |

The user runs their **own** game server now, so testing there is permitted.

Work dir: `C:\Users\zallkyre _3\Desktop\injector-base`

---

## 2. What exists and works

| piece | notes |
|---|---|
| `build32\bin\injector.exe` | remote-thread `LoadLibraryW` injector, x86 |
| `build64\bin\injector.exe` | x64 build, unused (client is x86) |
| `build32\bin\payload.dll` | injected payload |
| `ui\payload.dll` | payload the GUI injects (keep next to the exe) |
| `ui\payload.cfg` | RVAs, bound at load |
| `ui\OctaneExecutor.exe` | WinForms GUI (Xeno-style shell) |
| `ui\src\*.cs` | GUI source: `Theme.cs`, `PipeClient.cs`, `GameProcess.cs`, `MainForm.cs` |
| `tools\pefind.exe` | PE scanner: `find`, `calls`, `func`, `hex`, `rva`, `table`, `switch` |
| `tools\build-ui.ps1` | rebuild the GUI |
| `third_party\luau` | Luau **0.501** compiler (the mismatch source) |
| `tests\` | hook/lua/compile self-tests |

State: injector + hooks + capture + GUI + pipe protocol are all working and
verified. **Script execution does not work.** That is the only open problem.

---

## 3. Verified offsets (RVA, this build only)

| function | RVA | status |
|---|---|---|
| `lua_gettop` | `0xF413C0` | prologue `55 8B EC 8B 4D 08 8B 41 10 2B 41 14 C1 F8 04 5D C3` |
| `lua_pcall` | `0xF41980` | 6-byte-safe hook point |
| `luaD_pcall` | `0xF43EF0` | 6-byte-safe, fires in-game |
| `luau_load` | `0xF4C710` | 5 args `(L, chunkname, data, size, env)` |
| `lua_tolstring` | `0xF42BF0` | |
| `luaS_newlstr` | `0x1356DB0` | found via `luau_load` call site at RVA `0xF4C77E` |
| `lua_pushlstring` | `0xF41C80` | **confirmed by code shape** (see §7) |

All hook sites decode to clean 6-byte instruction boundaries; the payload's
`prologue.cpp` decoder rejects anything with a relative branch.

`lua_State`: `top = +0x10`, `base = +0x14`, `global = +0x18` (obfuscated, XOR with
its own address). **`ci` is NOT `+0xC` or `+0x1C`** — see §8.

---

## 4. Pipe protocol

Server: `\\.\pipe\octane_exec`, one line in, one reply out.
Replies are framed `b64:` + base64 (plaintext is also accepted for legacy).

```
PING                    -> PONG
INIT                    -> OK / FAIL   (hooks lua_gettop, arms capture)
STATUS                  -> attached / hooked / idle
STATE                   -> state=0x...
HITS                    -> hits=N target=0x... len=N
LOG                     -> payload ring-buffer text, or "-"
EXEC <b64 source>       -> captured output, or fault text
BC <b64 bytecode>       -> load+run raw bytecode
PROBE <b64 source>      -> compile=N load_status=N   (load only, no call)
LOADTEST <b64 bytecode> -> load_status=N
STRUCT <b64 bytecode>   -> TValue / closure / Proto dump
FIELD <b64 name>        -> queued globals probe (see §6)
HOOK rva:0x...          -> replace hook
HOOKPCALL               -> hook lua_pcall (0xF41980)
UNHOOK                  -> restore bytes
PROLOGUE rva:0x...      -> decode + safety report
OPT <opt> <dbg>         -> set compile options for EXEC
LOADSTRING              -> register global loadstring (needs 2 RVAs, unset)
```

---

## 5. THE BLOCKER

Path taken for `exec`: compile with vendored Luau **0.501** -> `luau_load` returns
**0** -> `lua_pcall` faults `0xC0000005` at `EIP = 0x0` (jump to null).

Proven:

- The bytecode container parses; the client builds a real closure (`tag 0x106`,
  `nupvalues 1`) and pushes it.
- Our emitted Proto for the same chunk says `nups = 0`; the client's closure has
  **1**. So the `Proto` struct / opcode layout differs from 0.501.
- All four compile modes (`opt 0/1` x `dbg 0/1`) fault identically -> not debug info.
- `LBC_VERSION` stays 1 across those versions, so the loader accepts the blob; the
  mismatch only appears at execution.

Corruption note: a failed `EXEC` damages the client's string table. Afterwards every
`luau_load` faults at `0xF56DFD` (string interning). **Restart the client before any
clean load test.**

---

## 6. Ruled out (do not redo)

- **Public Jan-2021 Luau source**: does not exist. `roblox/luau` was docs-only then;
  the oldest tag is `0.501`, which is what we vendor.
- **Client has no compiler**: `malformed number`, `unexpected char`, `BytecodeBuilder`
  -> 0 hits in the exe.
- **Discord payloads** (`DiddyWare2021M.dll`, `alx.vmp.dll`): crash 0.463 (target 0.477).
  DiddyWare contains **plain Lua 5.1** (io-lib strings `popen`/`tmpfile`,
  `"%s: %s in precompiled chunk"`), not Luau — so its embedded compiler cannot produce
  Luau bytecode.
- **`LUA_GLOBALSINDEX` (-10002) does not exist in Luau.** Five candidate functions were
  probed with `idx = -10002`: all return nil or fault. The globals table cannot be
  reached through a pseudo-index on this client.

---

## 7. What was found in this session

`luaS_newlstr` is called from 20 sites. Five are followed ~15 bytes later by
`add [reg+0x10], 0x10` (a push). Decoding the tightest one:

```
0x1341C80  55 8B EC 57 8B 7D 08        push ebp; mov ebp,esp; push edi; mov edi,[ebp+8]  ; L
           8B 4F 18 8D 47 18 33 C8     de-obfuscate L->global
           8B 41 44 3B 41 40 72 0B     GC step check
           6A 01 57 E8 ...             luaC_step
           56 FF 75 10 8B 77 10        push len; esi = L->top
           FF 75 0C 57                 push ptr; push L
           E8 ... (0x1356DB0)          luaS_newlstr(L, ptr, len)
           89 06                       top->value = string
           C7 46 0C 05 00 00 00        top->tt = 5   (string)
           83 47 10 10                 L->top += 16
```

=> **`lua_pushlstring` = `0xF41C80`**. Confirmed, not inferred.
Also: **string TValue tag = 5**, and the tag lives at `TValue + 0xC`.

Function entries recovered by walking back to a prologue:
`0xF41CF0` (call site `0xF41DEB`), `0xF42170` (call site `0xF421BC`).
Both behave like getters (they push) but ignore `-10002` — consistent with §6.

---

## 8. Current investigation — read the globals table directly

Plan: from a live `lua_State`, reach `CallInfo -> func -> LClosure -> env` and read
the globals table, then `luaH_get("loadstring")`.

Captured state dump (`L = 0x313FD5D0`, idle thread):

```
L+00: 00 FA 3B 31  07 00 00 00  60 FB 78 31  B8 59 AA 2E
L+10: C8 59 AA 2E  C8 59 AA 2E  E0 E8 98 20  28 5C AA 2E
L+20: 60 FB 78 31  08 00 00 00
```

- `L+0x10 == L+0x14`  -> `top == base`, thread idle (expected)
- `L+0x0C = 0x2EAA59B8` -> memory there is ASCII `"137,-0.06266"` (TString data)
- `L+0x1C = 0x2EAA5C28` -> ASCII `"1.17411,-0.867373,0.099004][1,0,"`

Neither is a `CallInfo`. **The 5.1 layout in `octane-offsets.md` is wrong for this
build**; `ci` offset is unknown.

Next step: capture a state **during active Lua** (a hook hit inside a running script),
dump `L`, `L+0xC`, `L+0x18`, `L+0x1C`, and locate the `CallInfo` by structure
(`func` = StkId pointing into the stack range, `savedpc` pointing into `.text`).

Then: closure -> `env` TValue -> globals table pointer -> `luaH_get` with an interned
key. We already have `luaS_newlstr` and `lua_pushlstring` for the key.

---

## 9. Build / test loop

```
# GUI (stop the exe first; the in-box csc is C# 5: no ?. , no $"", no nameof)
powershell -File tools\build-ui.ps1

# payload
cmake --build build32dev --config Release --target payload
copy build32dev\bin\payload_dev.dll ui\payload.dll

# inject (a loaded DLL is locked: the client must restart for a new build)
build32\bin\injector.exe <pid> "<abs path>\ui\payload.dll"

# then
INIT -> wait for STATUS=attached -> PROBE / FIELD / EXEC
```

Environment notes:
- Defender blocks these files unless excluded. Exclusions already added for
  `injector-base`, `%LOCALAPPDATA%\Octane`, and `%TEMP%\opencode`.
- `cmake` is not on PATH; use
  `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe`
- Build dir for a payload that is *not* locked: `build32dev` (output `payload_dev.dll`).

---

## 10. GUI state — done, do not re-polish

15 audit rounds closed. No known leaks, races, or crashes:

- auto inject/attach, kill, fade in/out, directional nav slide, resizable borderless
- log batching with `WM_SETREDRAW`, dedupe across ticks, scroll/selection preserved
- cached GDI objects, `Process` disposal, `VirtualFreeEx` on a completed wait,
  `PipeOptions.Asynchronous`, `b64:` framing, UI marshalling through `Ui()`

---

## 11. The one open question

> Does this client expose a usable `loadstring`, or can we reach its globals table?

- **Yes** -> the client compiles scripts with its own matching compiler; the executor
  works with no bytecode work at all.
- **No** -> reconstruct this VM's opcode table. Multi-day, uncertain. The entry point
  for that work is `luaV_execute`, reached from `luaD_call`; `0x2BF547` is the only
  caller of `luau_load` (the `luaL_loadbuffer` wrapper) and is a good landmark.

---

## 12. Corrections to `octane-offsets.md`

- `ci` / `global` offsets there are **not** valid for this build (see §8).
- `LUA_GLOBALSINDEX` (-10002) does not exist in Luau (§6).
- `luaS_newlstr` = `0x1356DB0` and `lua_pushlstring` = `0xF41C80` are new facts.
- The `luau_load` caller at RVA `0x2BF547` is `luaL_loadbuffer` — bytecode only.
