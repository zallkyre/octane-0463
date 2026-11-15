# Octane Executor — UI

WinForms shell for `payload.dll`. Borderless dark window, sidebar nav,
editor + live console, auto inject/attach.

## Files next to the exe

```
OctaneExecutor.exe
payload.dll      (build32\bin\payload.dll)
payload.cfg      (RVAs for 0.463.0.417004)
scripts\         (your .lua files)
```

## Build

```
powershell -File ..\tools\build-ui.ps1
```

Close the app first — csc cannot overwrite a running exe. The in-box compiler
is C# 5 only: no `?.`, no string interpolation, no `nameof`.

## Source layout

| file | role |
|---|---|
| `src\Theme.cs` | palette, fonts, rounded buttons, title bar, status pill, nav |
| `src\PipeClient.cs` | named-pipe client, returns `ERR ...` instead of throwing |
| `src\GameProcess.cs` | process lookup + `CreateRemoteThread`/`LoadLibraryW` injection |
| `src\MainForm.cs` | layout, pages, event wiring, auto-inject loop |
| `legacy\OctaneExecutor.v1.cs` | previous single-file version, kept for reference |

## Pages

- **Executor** — pick the game, press **Connect** (injects if needed, then attaches),
  write Lua, press **RUN** or Ctrl+Enter. Open / Save / Clear log.
- **Scripts** — lists `scripts\*.lua`, double-click loads it into the editor.
- **Advanced** — diagnostics only: hook/unhook, hit counter, offset check, state
  address, loadstring registration, compile options. Tooltips explain each button.

Connect is idempotent: if the payload is already loaded it just re-attaches, so the
button becomes **Reconnect**. Auto-connect does the same thing every 3 s while the
game is running; toggle it in the status bar.

## Performance choices

- Custom controls use `OptimizedDoubleBuffer | AllPaintingInWmPaint`; the form is
  double buffered and repaints only on resize.
- Console logging is batched on an 80 ms timer into a `StringBuilder`, then flushed
  once — no per-line `AppendText`, and the buffer is capped at ~300 KB so long
  sessions stay smooth.
- Every pipe call runs on a worker thread (`Pipe.SendAsync`), so the UI never
  blocks on a 2.5 s connect timeout.
- Timers: auto-attach polls every 3 s and only acts when the pid changes.

## Pipe protocol (as used here)

| request | reply |
|---|---|
| `PING` | `PONG` |
| `INIT` | `OK` / `FAIL` (hooks lua_gettop, arms capture) |
| `STATUS` | `attached` / `hooked` / `idle` |
| `STATE` | `state=0x...` |
| `EXEC <b64>` | captured output |
| `BC <b64 bytecode>` | load + call raw bytecode |
| `FIELD <b64 "name\|seed">` | probes the globals table |
| `STRUCT <b64 bytecode>` | dumps TValue/closure/Proto candidates |
| `HOOK rva:0x...` / `HOOKPCALL` / `UNHOOK` / `HITS` | hook control |
| `PROLOGUE rva:0x...` | decode bytes at an RVA |
| `OPT <opt> <dbg>` | compile options for EXEC |
| `LOADSTRING` | register global loadstring (needs two RVAs) |
