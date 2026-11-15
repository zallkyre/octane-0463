# octane-0463 tooling

Reverse-engineering and instrumentation tooling for a Windows x86 Roblox client
build (`OctanePlayer.exe` 0.463.0.417004, 2021-01-22). Source-only.

This is a research project: a DLL injector, an inline-hook engine, a payload with a
Luau bridge, and a small WinForms front-end. It documents what worked, what didn't,
and how each conclusion was reached.

## What works

- **Injector** (x86 + x64 builds) — `LoadLibraryW` via remote thread, with a proper
  architecture check (`IsWow64Process` used correctly, `VirtualFreeEx` on the path
  buffer).
- **Inline hook engine** — 6-byte x86 / 14-byte x64 detours with a register-saving
  stub, plus a **prologue decoder** that auto-aligns the patch length to instruction
  boundaries and *refuses* prologues containing relative branches. That single guard
  prevents most crash-on-inject failures.
- **Lua bridge** — hooks `lua_gettop` to capture `lua_State*`, resolves the four
  needed functions from a config file, and exposes a line-based command protocol.
- **GUI** — borderless dark shell, auto inject/attach, script editor, batched log.
- Verified offsets for this build (RVA): `lua_gettop 0xF413C0`, `lua_pcall 0xF41980`,
  `luaD_pcall 0xF43EF0`, `luau_load 0xF4C710`, `lua_tolstring 0xF42BF0`,
  `luaS_newlstr 0x1356DB0`, `lua_pushlstring 0xF41C80`.

## What does not work

**Script execution.** The executor compiles Lua with a vendored **Luau 0.501**
compiler, `luau_load` accepts the bytecode and builds a closure, but `lua_pcall`
then faults with `0xC0000005` at `EIP = 0`.

Cause: the client is a **January-2021** build. Its `Proto` layout and opcode enum
differ from 0.501, and Luau does not bump `LBC_VERSION` for enum changes, so the
loader cannot detect the mismatch. No public Luau source exists for that date
(the upstream repo was documentation-only then; its oldest tag is 0.501).

`STATUS.md` documents the full investigation, everything ruled out, and the two
remaining branches (client `loadstring`, or opcode-table reconstruction).

## Layout

```
src/injector/       injector executable
src/payload/        injected payload: hooks, prologue decoder, Lua bridge, pipe
ui/src/             GUI source (C# 5 / WinForms, no designer)
tools/              pefind (PE scanner: find/calls/func/hex/table/switch), scripts
tests/              hook, lua-bridge, compiler and prologue self-tests
third_party/luau/   Luau 0.501 compiler (MIT, (c) Roblox Corporation)
STATUS.md           full technical status / handoff
octane-offsets.md   original offset notes (partly superseded - see STATUS.md)
```

## Build

Needs Visual Studio 2022 C++ tools.

```
build.bat                      # both architectures
cmake --build build32 --config Release
powershell -File tools\build-ui.ps1    # GUI
```

## Notes

- Offsets live in `payload.cfg` (see `payload.cfg.example`); nothing is hardcoded.
- The payload never calls a network endpoint and installs no persistence.
- Third-party exploit DLLs used during research are **not** included in this
  repository.

## Licence

Original code here is released under the MIT licence. `third_party/luau` is Luau,
MIT licensed, (c) Roblox Corporation.
