#!/usr/bin/env python
"""Disassemble Octane 0.463 luaV_execute handlers from the live module dump.

The VM dispatch is a two-level, shuffled opcode table (see docs/lua-vm.md):
  opcode -> handler index  (256-byte map @ VA 0x13485E8, 0x46 = invalid)
  handler index -> code    (70 dwords @ VA 0x13484CC)

File layout: the dump is rebuilt with section raw pointer == virtual address,
so file offset == VA. Run:

    python tools/luaop_probe.py C:\\path\\Octane_live.exe
"""
import sys

try:
    from capstone import Cs, CS_ARCH_X86, CS_MODE_32
except ImportError:
    sys.stderr.write("pip install capstone\n")
    sys.exit(1)

# handler index -> code VA (from docs/lua-vm.md, table @ 0x13484CC)
HANDLERS = [
    0x01344E1C, 0x013473FD, 0x01346D2B, 0x013461C1, 0x0134587A, 0x01347E3B, 0x0134508A,
    0x01347789, 0x01347342, 0x01346C2E, 0x0134618E, 0x0134849E, 0x01345476, 0x01347C84,
    0x01344FBE, 0x0134769F, 0x01347230, 0x01346B31, 0x01348319, 0x013483CD, 0x013452DA,
    0x01347BFB, 0x01344F8E, 0x01347656, 0x01347137, 0x01346A35, 0x01348358, 0x01348384,
    0x01345752, 0x01347B7C, 0x01344F7F, 0x0134760A, 0x013470D7, 0x0134687A, 0x013460B4,
    0x01348361, 0x0134567E, 0x01347AC8, 0x01344F4C, 0x013475C0, 0x01347077, 0x013464D1,
    0x01345C9D, 0x013481F6, 0x01345252, 0x01347A2F, 0x01344F1B, 0x01347573, 0x01346FF1,
    0x01346957, 0x01345B48, 0x013481C6, 0x01345218, 0x013478FA, 0x01344F01, 0x01347540,
    0x01346F45, 0x013467B9, 0x01345A2B, 0x013480A5, 0x013451A7, 0x01347898, 0x01344E8E,
    0x013474EE, 0x01346E38, 0x013461F5, 0x01345935, 0x01347EA4, 0x01345167, 0x01347842,
]

# opcode -> handler index map (@0x13485E8), 0x46 = invalid
MAP = bytes.fromhex(
    "00 46 46 46 01 46 46 46 46 02 46 46 46 46 03 46"
    "46 46 46 04 46 46 46 05 06 46 46 46 07 46 46 46"
    "46 08 46 46 46 46 09 46 46 46 46 0A 46 46 46 0B"
    "0C 46 46 46 0D 0E 46 46 46 0F 46 46 46 46 10 46"
    "46 46 46 11 46 46 46 46 12 46 46 46 13 14 46 46"
    "46 15 16 46 46 46 17 46 46 46 46 18 46 46 46 46"
    "19 46 46 46 46 1A 46 46 46 1B 1C 46 46 46 1D 1E"
    "46 46 46 1F 46 46 46 46 20 46 46 46 46 21 46 46"
    "46 46 22 46 46 46 23 24 46 46 46 25 26 46 46 46"
    "27 46 46 46 46 28 46 46 46 46 29 46 46 46 46 2A"
    "46 46 46 2B 2C 46 46 46 2D 2E 46 46 46 2F 46 46"
    "46 46 30 46 46 46 46 31 46 46 46 46 32 46 46 46"
    "33 34 46 46 46 35 36 46 46 46 37 46 46 46 46 38"
    "46 46 46 46 39 46 46 46 46 3A 46 46 46 3B 3C 46"
    "46 46 3D 3E 46 46 46 3F 46 46 46 46 40 46 46 46"
    "46 41 46 46 46 46 42 46 46 46 43 44 46 46 46 45"
)

STARTS = sorted(HANDLERS)
END = STARTS[-1] + 0x200


def next_start(addr):
    for s in STARTS:
        if s > addr:
            return s
    return END


def main():
    if len(sys.argv) < 2:
        sys.stderr.write("usage: luaop_probe.py <dump.exe>\n")
        return 2
    data = open(sys.argv[1], "rb").read()
    md = Cs(CS_ARCH_X86, CS_MODE_32)
    md.detail = True

    # The dump stores sections with PointerToRawData == VirtualAddress, so a
    # file offset equals the RVA (VA - image base). image base is 0x400000.
    base = 0x400000

    print("idx  va          first insns                                           calls")
    for i, va in enumerate(HANDLERS):
        limit = next_start(va)
        insns = []
        calls = []
        n = 0
        for ins in md.disasm(data[va - base:limit - base], va):
            txt = ins.mnemonic + (" " + ins.op_str if ins.op_str else "")
            insns.append(txt)
            if ins.mnemonic == "call" and ins.operands and ins.operands[0].type == 2:  # IMM
                tgt = ins.operands[0].imm & 0xFFFFFFFF
                calls.append(tgt - 0x400000)  # RVA
            n += 1
            if n >= 6 or ins.mnemonic in ("ret", "jmp") and n > 2:
                break
        cs = ",".join("0x%X" % c for c in calls)
        print("%3d  0x%08X  %-52s  %s" % (i, va, " ; ".join(insns)[:52], cs))

    # invert: which opcode values select each handler
    print("\nopcode value -> handler idx (valid only)")
    inv = {}
    for op, hidx in enumerate(MAP):
        if hidx != 0x46:
            inv.setdefault(hidx, []).append(op)
    for hidx in range(70):
        ops = inv.get(hidx, [])
        print("  h%-2d : %s" % (hidx, " ".join("0x%02X" % o for o in ops)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
