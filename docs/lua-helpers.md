# Octane 0.463 — luaV_execute helper map + remap plan

Companion to `docs/lua-vm.md`. Status of the opcode reconstruction.

## Key numbers

| | |
|---|---|
| client handlers (opcodes) | **70** (jump table `0x13484CC`, 70 entries) |
| Luau 0.501 opcodes | **77** (`LOP__COUNT`=76) |
| dispatch map | 256 bytes @ `0x13485E8`, `0x46` = invalid |
| invalid path | map gives `0x46`=70 -> `table[70]` = `0x00000000` @ `0x13485E4` -> **jmp 0** |

So the observed `EIP=0` fault on 0.501 bytecode is exactly: an opcode value this build
did not define -> index 70 -> zero entry -> jump to null. `table[70]` is the zero dword
just past the 70 real entries, before the byte map starts.

## What this means for remapping

The client is an **older/lighter Luau** (70 opcodes vs 77) with a **shuffled opcode
numbering** (the 256-byte map is a permutation). Handler order is not the 0.501 enum
order, so the map must be derived per handler, not by index.

## Helper functions called from handlers (RVA, `.text`)

Identified as real functions (clean `55 8B EC` prologues) by scanning each handler body.
These are the semantic anchors — once named, the 70 handlers fall into families.

```
0xF4C580  0xF4C460  0xF593C0  0xF58EC0  0xF59130  0xF58AB0  0xF574C0  0xF58CE0
0xF55B60  0xF59390  0xF4D160  0xF57540  0xF4D540  0xF59090  0xF58770  0xF58FF0
0xF44D90  0xF58D90  0xF43E60  0xF43EC0  0xF4D5E0  0xF4D440  0xF4D3A0  0xF55560
0xF555F0  0xF55880  0xF55B80  0xF55E40  0xF57290  0xF57690  0xF578E0
```

Observed relationships from `docs/lua-handler-summary.txt`:

- Table-read family (`GETTABLE*`): handlers calling `0xF4C460` (+ `0xF593C0`) —
  h2,h9,h15,h16,h17,h24,h29,h41,h64,h65.
- Table-write family (`SETTABLE*`): `0xF55B60` / `0xF58D90`-style — h12,h28,h53,h66.
- Global access (`xor`-deobfuscated `global`): h0,h12,h13,h18,h19,h20,h27,h28,h29,
  h37,h41,h42,h52,h61,h65,h66,h67.
- `0xF43EC0` (adjacent to `luaD_pcall` 0xF43EF0): h43,h59 -> CALL path.
- `0xF43E60` + `0xF43EC0` + `0xF4D5E0`: h42 -> likely NAMECALL/CALL composite.
- Relative jump using `D` (`movsx word [edi+2]`): h26 -> JUMP/JUMPBACK.
- Upvalue tag (`0xB`) writes: h58,h68 -> CLOSEUPVALS / NEWCLOSURE.
- Boolean tag (`1`) writes: h23,h46 -> LOADB.
- Upvalue/closure helpers `0xF555F0`,`0xF55880`: h58.

## Remap approach (chosen)

Do not translate bytecode opcodes on the host. Instead:

1. Finish naming the 31 helpers by decompiling their entry (short functions) — each name
   pins the handlers that call it.
2. Build `handler_index -> Luau opcode name` (70 rows).
3. For each 0.501 opcode `o`, look up its name, find the client opcode value `v` whose
   `map[v] == handler_index(name)`.
4. Two delivery options:
   - **Bytecode rewrite**: replace each instruction's opcode byte (bits 24..31) with `v`,
     keep ABC/AD operands. No runtime patch, no rights issues.
   - **Runtime map patch**: `REMAP <256 bytes>` overwrites `0x13485E8` so raw 0.501
     bytecode runs unchanged. Easier to test, but mutates the dispatch table.
5. Validate one opcode at a time with a two-instruction chunk (`LOADN; RETURN`) on the
   live VM, tolerating the invalid->null crash by restarting the client.

## Remaining work

The classification (steps 1-2) is the long part. It is data work over
`docs/lua-handlers.asm`; the machinery (dump, dispatch, tooling) is in place.
