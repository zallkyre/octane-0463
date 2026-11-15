# Octane 0.463 — Lua VM dispatch (live-memory analysis)

Facts from a **live** `OctanePlayer.exe` 0.463.0.417004 (x86, base `0x400000`).
The on-disk exe is VMProtect-packed; string/table scans on the file lie. Analyse the
process image instead (see `tools/dump-live-module.ps1`, which rebuilds a PE from
`ReadProcessMemory` with VA-aligned sections).

Image: 12 sections, `SizeOfImage=0x2FD8000`, `.text` `VA=0x1000 size=0x1861646`,
plus `.vmp0/.vmp1`. Core Luau functions have ordinary prologues in `.text`
(`lua_pcall`, `luaD_pcall`, `luau_load`, `lua_tolstring`, `lua_pushlstring`), so the
VM itself is not virtualised — only some entry thunks are.

## 1. `global` pointer is XOR-encoded

`lua_State* L`, field `+0x18` holds `global`, but encoded:

```
global = *(uint32*)(L + 0x18) ^ (uint32)(L + 0x18)
```

Confirmed in `luaV_execute` handler code (`lea ecx,[esi+0x18]; mov eax,[ecx]; xor eax,ecx`).
Arithmetic, not a key schedule. This is why a raw read of `L+0x18` gave an
uncommitted pointer (`0x53B018D0`) instead of `global_State*`.

`lua_State` observed slots: `stack=+0x0C`, `top=+0x10`, `base=+0x14`,
`global(enc)=+0x18`, then a stack-region pointer at `+0x1C`. Fields around these do
not match 0.501's header.

## 2. Opcode dispatch is two-level and shuffled

The interpreter does **not** index a direct 256-entry jump table. It performs:

```
movzx eax, byte ptr [eax + 0x013485E8]   ; opcode -> handler index
jmp   dword ptr [eax*4 + 0x013484CC]     ; handler index -> code
```

- `0x13485E8` — 256-byte **opcode → handler-index** map (`0x46` = invalid/unsupported).
- `0x13484CC` — 70-entry **handler-index → code** table.
- Dispatch site: `RVA 0xF44E87` (main loop). A second copy at `RVA 0xF48797`
  (fast-call path) uses map `0x134BDE0` and table `0x134BCC4` (70 entries).

This shuffled opcode numbering is why 0.501-compiled bytecode loads (`LBC_VERSION`
still 1) but faults at execution: the loader accepts it, the dispatch reads wrong
opcode bytes, and a handler is entered with a null/mismatched target (`EIP=0`).

### 2.1 Opcode → handler index (256 bytes at `0x13485E8`)

```
       0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
00:   00 46 46 46 01 46 46 46 46 02 46 46 46 46 03 46
10:   46 46 46 04 46 46 46 05 06 46 46 46 07 46 46 46
20:   46 08 46 46 46 46 09 46 46 46 46 0A 46 46 46 0B
30:   0C 46 46 46 0D 0E 46 46 46 0F 46 46 46 46 10 46
40:   46 46 46 11 46 46 46 46 12 46 46 46 13 14 46 46
50:   46 15 16 46 46 46 17 46 46 46 46 18 46 46 46 46
60:   19 46 46 46 46 1A 46 46 46 1B 1C 46 46 46 1D 1E
70:   46 46 46 1F 46 46 46 46 20 46 46 46 46 21 46 46
80:   46 46 22 46 46 46 23 24 46 46 46 25 26 46 46 46
90:   27 46 46 46 46 28 46 46 46 46 29 46 46 46 46 2A
A0:   46 46 46 2B 2C 46 46 46 2D 2E 46 46 46 2F 46 46
B0:   46 46 30 46 46 46 46 31 46 46 46 46 32 46 46 46
C0:   33 34 46 46 46 35 36 46 46 46 37 46 46 46 46 38
D0:   46 46 46 46 39 46 46 46 46 3A 46 46 46 3B 3C 46
E0:   46 46 3D 3E 46 46 46 3F 46 46 46 46 40 46 46 46
F0:   46 41 46 46 46 46 42 46 46 46 43 44 46 46 46 45
```

Valid opcode values are sparse: `0x00,0x04,0x09,0x0E,0x13,0x18,0x19,0x1D,…`
(`0x46` fills the gaps). Handler index 0..0x45 (70 handlers).

## 3. Handler-index → code (70 dwords at `0x13484CC`)

```
00 0x01344E1C  01 0x013473FD  02 0x01346D2B  03 0x013461C1
04 0x0134587A  05 0x01347E3B  06 0x0134508A  07 0x01347789
08 0x01347342  09 0x01346C2E  0A 0x0134618E  0B 0x0134849E
0C 0x01345476  0D 0x01347C84  0E 0x01344FBE  0F 0x0134769F
10 0x01347230  11 0x01346B31  12 0x01348319  13 0x013483CD
14 0x013452DA  15 0x01347BFB  16 0x01344F8E  17 0x01347656
18 0x01347137  19 0x01346A35  1A 0x01348358  1B 0x01348384
1C 0x01345752  1D 0x01347B7C  1E 0x01344F7F  1F 0x0134760A
20 0x013470D7  21 0x0134687A  22 0x013460B4  23 0x01348361
24 0x0134567E  25 0x01347AC8  26 0x01344F4C  27 0x013475C0
28 0x01347077  29 0x013464D1  2A 0x01345C9D  2B 0x013481F6
2C 0x01345252  2D 0x01347A2F  2E 0x01344F1B  2F 0x01347573
30 0x01346FF1  31 0x01346957  32 0x01345B48  33 0x013481C6
34 0x01345218  35 0x013478FA  36 0x01344F01  37 0x01347540
38 0x01346F45  39 0x013467B9  3A 0x01345A2B  3B 0x013480A5
3C 0x013451A7  3D 0x01347898  3E 0x01344E8E  3F 0x013474EE
40 0x01346E38  41 0x013461F5  42 0x01345935  43 0x01347EA4
44 0x01345167  45 0x01347842
```

All targets sit in `0x1344E1C..0x134849E` — one big function body (case labels, no
prologues). Handler `0` (`0x1344E1C`) de-obfuscates `global` and branches on the
next opcode byte, consistent with a hot path (CALL/RETURN or LOADK fast path).

## 4. Where this leaves exec

0.501 `Compiler.cpp` emits dense opcodes 0..~85; the client dispatches on the sparse
shuffled values above. To run our bytecode we must **remap each emitted 0.501 opcode
to this build's opcode value** (and keep AUX/ABC operand layout, which appears
unchanged).

Remap needs handler-index → semantics. Plan:

1. Classify the 70 handlers by disassembling each and matching call targets
   (`luaV_gettable`, `luaH_get`, `luaV_concat`, `luaV_equalval`, `forgloop`,
   `luaD_call`, `luaF_close`, gates/quanta, etc.). These helpers are in `.text` and
   identifiable by their own prologues/strings.
2. Invert `0x13485E8` to get opcode-value per semantic.
3. Emit a 0.501-opcode → client-opcode table and post-process `Luau::compile`
   output: rewrite each instruction word's opcode byte (bits 24..31), leave operands.
4. Validate one instruction at a time against the live VM before running real scripts.

A reference build of the vendored 0.501 VM can supply handler fingerprints to match
against the client for step 1.
