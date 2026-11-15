#include "prologue.h"

#include "mem.h"

#include <cstdio>

namespace {

enum : unsigned short {
    F_MODRM = 1u << 0,
    F_IMM8 = 1u << 1,
    F_IMM16 = 1u << 2,
    F_IMM32 = 1u << 3,
    F_REL8 = 1u << 4,
    F_REL32 = 1u << 5,
    F_IMMSZ = 1u << 6,   // imm16 or imm32, by operand size (66 prefix)
    F_ADDR = 1u << 7,    // 4-byte moffs
    F_REL = 1u << 8,     // relative control transfer: unsafe to copy
    F_TERM = 1u << 9,    // ret / int3 / ud2 / hlt
    F_GROUP = 1u << 10,  // F6/F7: only /0 and /1 with mod==3 take an imm8
};

struct Op {
    unsigned short f = 0;
    const char* n = nullptr;
};

struct Tables {
    Op one[256];
    Op two[256];
    std::string pushName[8];
    std::string popName[8];
    std::string incName[8];
    std::string decName[8];

    Tables() {
        static const char* const r32[8] = {"eax", "ecx", "edx", "ebx",
                                           "esp", "ebp", "esi", "edi"};
        auto s = [this](unsigned i, unsigned short f, const char* n) {
            one[i].f = f;
            one[i].n = n;
        };
        auto s2 = [this](unsigned i, unsigned short f, const char* n) {
            two[i].f = f;
            two[i].n = n;
        };

        // 00..3F: add/or/adc/sbb/and/sub/xor/cmp in 8-byte families
        static const char* const fam[8] = {"add", "or",  "adc", "sbb",
                                           "and", "sub", "xor", "cmp"};
        for (unsigned g = 0; g < 8; ++g) {
            unsigned base = g * 8;
            s(base + 0, F_MODRM, fam[g]);
            s(base + 1, F_MODRM, fam[g]);
            s(base + 2, F_MODRM, fam[g]);
            s(base + 3, F_MODRM, fam[g]);
            s(base + 4, F_IMM8, fam[g]);
            s(base + 5, F_IMMSZ, fam[g]);
        }
        s(0x06, 0, "push es");
        s(0x07, 0, "pop es");
        s(0x0E, 0, "push cs");
        s(0x16, 0, "push ss");
        s(0x17, 0, "pop ss");
        s(0x1E, 0, "push ds");
        s(0x1F, 0, "pop ds");
        s(0x27, 0, "daa");
        s(0x2F, 0, "das");
        s(0x37, 0, "aaa");
        s(0x3F, 0, "aas");

        for (unsigned i = 0; i <= 7; ++i) {
            incName[i] = std::string("inc ") + r32[i];
            decName[i] = std::string("dec ") + r32[i];
            pushName[i] = std::string("push ") + r32[i];
            popName[i] = std::string("pop ") + r32[i];
            s(0x40 + i, 0, incName[i].c_str());
            s(0x48 + i, 0, decName[i].c_str());
            s(0x50 + i, 0, pushName[i].c_str());
            s(0x58 + i, 0, popName[i].c_str());
        }

        s(0x60, 0, "pushad");
        s(0x61, 0, "popad");
        s(0x62, F_MODRM, "bound");
        s(0x63, F_MODRM, "arpl");
        s(0x68, F_IMMSZ, "push imm");
        s(0x69, F_MODRM | F_IMMSZ, "imul");
        s(0x6A, F_IMM8, "push imm8");
        s(0x6B, F_MODRM | F_IMM8, "imul");
        s(0x6C, 0, "insb");
        s(0x6D, 0, "insd");
        s(0x6E, 0, "outsb");
        s(0x6F, 0, "outsd");

        for (unsigned i = 0x70; i <= 0x7F; ++i) s(i, F_REL8 | F_REL, "jcc short");
        s(0x80, F_MODRM | F_IMM8, "grp1 r/m8, imm8");
        s(0x81, F_MODRM | F_IMMSZ, "grp1 r/m32, imm32");
        s(0x82, F_MODRM | F_IMM8, "grp1 r/m8, imm8");
        s(0x83, F_MODRM | F_IMM8, "grp1 r/m32, imm8");
        s(0x84, F_MODRM, "test r/m8, r8");
        s(0x85, F_MODRM, "test r/m32, r32");
        s(0x86, F_MODRM, "xchg r/m8, r8");
        s(0x87, F_MODRM, "xchg r/m32, r32");
        s(0x88, F_MODRM, "mov r/m8, r8");
        s(0x89, F_MODRM, "mov r/m32, r32");
        s(0x8A, F_MODRM, "mov r8, r/m8");
        s(0x8B, F_MODRM, "mov r32, r/m32");
        s(0x8C, F_MODRM, "mov r/m16, sreg");
        s(0x8D, F_MODRM, "lea");
        s(0x8E, F_MODRM, "mov sreg, r/m16");
        s(0x8F, F_MODRM, "pop r/m32");

        s(0x90, 0, "nop");
        for (unsigned i = 0x91; i <= 0x97; ++i) s(i, 0, "xchg eax, reg");
        s(0x98, 0, "cwde");
        s(0x99, 0, "cdq");
        s(0x9B, 0, "wait");
        s(0x9C, 0, "pushfd");
        s(0x9D, 0, "popfd");
        s(0x9E, 0, "sahf");
        s(0x9F, 0, "lahf");

        s(0xA0, F_ADDR, "mov al, moffs8");
        s(0xA1, F_ADDR, "mov eax, moffs32");
        s(0xA2, F_ADDR, "mov moffs8, al");
        s(0xA3, F_ADDR, "mov moffs32, eax");
        s(0xA4, 0, "movsb");
        s(0xA5, 0, "movsd");
        s(0xA6, 0, "cmpsb");
        s(0xA7, 0, "cmpsd");
        s(0xA8, F_IMM8, "test al, imm8");
        s(0xA9, F_IMMSZ, "test eax, imm");
        s(0xAA, 0, "stosb");
        s(0xAB, 0, "stosd");
        s(0xAC, 0, "lodsb");
        s(0xAD, 0, "lodsd");
        s(0xAE, 0, "scasb");
        s(0xAF, 0, "scasd");

        for (unsigned i = 0xB0; i <= 0xB7; ++i) s(i, F_IMM8, "mov r8, imm8");
        for (unsigned i = 0xB8; i <= 0xBF; ++i) s(i, F_IMMSZ, "mov r32, imm");

        s(0xC0, F_MODRM | F_IMM8, "shift r/m8, imm8");
        s(0xC1, F_MODRM | F_IMM8, "shift r/m32, imm8");
        s(0xC2, F_IMM16 | F_TERM, "ret imm16");
        s(0xC3, F_TERM, "ret");
        s(0xC4, F_MODRM, "les");
        s(0xC5, F_MODRM, "lds");
        s(0xC6, F_MODRM | F_IMM8, "mov r/m8, imm8");
        s(0xC7, F_MODRM | F_IMMSZ, "mov r/m32, imm32");
        s(0xC8, F_IMM16 | F_IMM8, "enter");
        s(0xC9, 0, "leave");
        s(0xCA, F_IMM16 | F_TERM, "retf imm16");
        s(0xCB, F_TERM, "retf");
        s(0xCC, F_TERM, "int3");
        s(0xCD, F_IMM8, "int imm8");
        s(0xCE, 0, "into");
        s(0xCF, F_TERM, "iret");

        for (unsigned i = 0xD0; i <= 0xD3; ++i) s(i, F_MODRM, "shift r/m, 1/cl");
        s(0xD4, F_IMM8, "aam");
        s(0xD5, F_IMM8, "aad");
        s(0xD6, 0, "salc");
        s(0xD7, 0, "xlat");
        for (unsigned i = 0xD8; i <= 0xDF; ++i) s(i, F_MODRM, "x87");

        for (unsigned i = 0xE0; i <= 0xE3; ++i) s(i, F_REL8 | F_REL, "loop/jecxz");
        s(0xE4, F_IMM8, "in al, imm8");
        s(0xE5, F_IMM8, "in eax, imm8");
        s(0xE6, F_IMM8, "out imm8, al");
        s(0xE7, F_IMM8, "out imm8, eax");
        s(0xE8, F_REL32 | F_REL, "call rel32");
        s(0xE9, F_REL32 | F_REL, "jmp rel32");
        s(0xEB, F_REL8 | F_REL, "jmp short");
        s(0xEC, 0, "in al, dx");
        s(0xED, 0, "in eax, dx");
        s(0xEE, 0, "out dx, al");
        s(0xEF, 0, "out dx, eax");
        s(0xF1, 0, "int1");
        s(0xF4, F_TERM, "hlt");
        s(0xF5, 0, "cmc");
        s(0xF6, F_MODRM | F_GROUP, "grp3 r/m8");
        s(0xF7, F_MODRM | F_GROUP, "grp3 r/m32");
        s(0xF8, 0, "clc");
        s(0xF9, 0, "stc");
        s(0xFA, 0, "cli");
        s(0xFB, 0, "sti");
        s(0xFC, 0, "cld");
        s(0xFD, 0, "std");
        s(0xFE, F_MODRM, "inc/dec r/m8");
        s(0xFF, F_MODRM, "inc/dec/call/jmp/push r/m32");

        // ---- 0F xx ----
        s2(0x01, F_MODRM, "grp7");
        s2(0x05, 0, "syscall");
        s2(0x06, 0, "clts");
        s2(0x07, 0, "sysret");
        s2(0x08, 0, "invd");
        s2(0x09, 0, "wbinvd");
        s2(0x0B, F_TERM, "ud2");
        s2(0x0D, F_MODRM, "prefetch");
        s2(0x0E, 0, "femms");
        for (unsigned i = 0x10; i <= 0x17; ++i) s2(i, F_MODRM, "movups/movss family");
        for (unsigned i = 0x18; i <= 0x1F; ++i) s2(i, F_MODRM, "prefetch/nop");
        for (unsigned i = 0x28; i <= 0x2F; ++i) s2(i, F_MODRM, "movaps family");
        s2(0x30, 0, "wrmsr");
        s2(0x31, 0, "rdtsc");
        s2(0x32, 0, "rdmsr");
        s2(0x33, 0, "rdpmc");
        s2(0x34, 0, "sysenter");
        s2(0x35, 0, "sysexit");
        s2(0x37, 0, "getsec");
        for (unsigned i = 0x40; i <= 0x4F; ++i) s2(i, F_MODRM, "cmovcc");
        for (unsigned i = 0x50; i <= 0x6F; ++i) s2(i, F_MODRM, "sse");
        for (unsigned i = 0x70; i <= 0x73; ++i) s2(i, F_MODRM | F_IMM8, "sse shift imm8");
        for (unsigned i = 0x74; i <= 0x76; ++i) s2(i, F_MODRM, "sse");
        s2(0x77, 0, "emms");
        for (unsigned i = 0x78; i <= 0x7F; ++i) s2(i, F_MODRM, "sse");
        for (unsigned i = 0x80; i <= 0x8F; ++i) s2(i, F_REL32 | F_REL, "jcc near");
        for (unsigned i = 0x90; i <= 0x9F; ++i) s2(i, F_MODRM, "setcc");
        s2(0xA0, 0, "push fs");
        s2(0xA1, 0, "pop fs");
        s2(0xA2, 0, "cpuid");
        s2(0xA3, F_MODRM, "bt");
        s2(0xA4, F_MODRM | F_IMM8, "shld imm8");
        s2(0xA5, F_MODRM, "shld cl");
        s2(0xA8, 0, "push gs");
        s2(0xA9, 0, "pop gs");
        s2(0xAA, 0, "rsm");
        s2(0xAB, F_MODRM, "bts");
        s2(0xAC, F_MODRM | F_IMM8, "shrd imm8");
        s2(0xAD, F_MODRM, "shrd cl");
        s2(0xAE, F_MODRM, "fxsave/clflush");
        s2(0xAF, F_MODRM, "imul");
        s2(0xB0, F_MODRM, "cmpxchg r/m8");
        s2(0xB1, F_MODRM, "cmpxchg r/m32");
        s2(0xB2, F_MODRM, "lss");
        s2(0xB3, F_MODRM, "btr");
        s2(0xB4, F_MODRM, "lfs");
        s2(0xB5, F_MODRM, "lgs");
        s2(0xB6, F_MODRM, "movzx r, r/m8");
        s2(0xB7, F_MODRM, "movzx r, r/m16");
        s2(0xB8, F_MODRM, "popcnt");
        s2(0xB9, F_MODRM, "ud1");
        s2(0xBA, F_MODRM | F_IMM8, "grp8 bt imm8");
        s2(0xBB, F_MODRM, "btc");
        s2(0xBC, F_MODRM, "bsf");
        s2(0xBD, F_MODRM, "bsr");
        s2(0xBE, F_MODRM, "movsx r, r/m8");
        s2(0xBF, F_MODRM, "movsx r, r/m16");
        s2(0xC0, F_MODRM, "xadd r/m8");
        s2(0xC1, F_MODRM, "xadd r/m32");
        s2(0xC7, F_MODRM, "cmpxchg8b");
        for (unsigned i = 0xC8; i <= 0xCF; ++i) s2(i, 0, "bswap");
        for (unsigned i = 0xD0; i <= 0xFF; ++i) s2(i, F_MODRM, "sse");
    }
};

const Tables& T() {
    static const Tables t;
    return t;
}

}  // namespace

PrologueInfo DecodePrologue(uintptr_t addr, size_t minLen, size_t maxLen) {
    PrologueInfo info;
#if defined(_WIN64)
    (void)addr;
    (void)minLen;
    (void)maxLen;
    info.error = "prologue decoding is x86-only";
    return info;
#else
    if (minLen == 0) minLen = 1;
    if (maxLen < minLen) maxLen = minLen + 16;
    if (maxLen > 64) maxLen = 64;

    uint8_t buf[64] = {};
    if (!SafeRead(addr, buf, maxLen)) {
        info.error = "unreadable";
        return info;
    }

    const Tables& t = T();
    size_t off = 0;
    std::string text;

    while (off < minLen) {
        if (off >= maxLen) {
            info.error = "no instruction boundary within " + std::to_string(maxLen) + " bytes";
            info.length = off;
            return info;
        }

        size_t start = off;
        bool opsize16 = false;
        bool addrsize16 = false;

        for (;;) {
            if (off >= maxLen) {
                info.error = "truncated in prefixes";
                info.length = start;
                return info;
            }
            uint8_t b = buf[off];
            if (b == 0x66) {
                opsize16 = true;
                ++off;
            } else if (b == 0x67) {
                addrsize16 = true;
                ++off;
            } else if (b == 0xF0 || b == 0xF2 || b == 0xF3 || b == 0x2E || b == 0x36 ||
                       b == 0x3E || b == 0x26 || b == 0x64 || b == 0x65) {
                ++off;
            } else {
                break;
            }
        }

        uint8_t op = buf[off++];
        const Op* oi = nullptr;
        unsigned shown = op;
        if (op == 0x0F) {
            if (off >= maxLen) {
                info.error = "truncated in 0F escape";
                info.length = start;
                return info;
            }
            unsigned op2 = buf[off++];
            oi = &t.two[op2];
            shown = 0x0F00u | op2;
        } else {
            oi = &t.one[op];
        }

        if (oi->n == nullptr) {
            char msg[80];
            std::snprintf(msg, sizeof(msg), "unsupported opcode %02X at +%u",
                          shown & 0xFF, static_cast<unsigned>(start));
            info.error = msg;
            info.length = start;
            return info;
        }

        unsigned short f = oi->f;
        bool imm8 = (f & F_IMM8) != 0;

        if (f & F_MODRM) {
            if (off >= maxLen) {
                info.error = "truncated in ModRM";
                info.length = start;
                return info;
            }
            uint8_t modrm = buf[off++];
            unsigned mod = modrm >> 6;
            unsigned reg = (modrm >> 3) & 7;
            unsigned rm = modrm & 7;
            if (addrsize16) {
                info.error = "67 (16-bit addressing) prefix unsupported";
                info.length = start;
                return info;
            }
            if (mod != 3) {
                if (rm == 4) {
                    if (off >= maxLen) {
                        info.error = "truncated in SIB";
                        info.length = start;
                        return info;
                    }
                    uint8_t sib = buf[off++];
                    if (mod == 0 && (sib & 7) == 5) off += 4;
                }
                if (mod == 0 && rm == 5) {
                    off += 4;
                } else if (mod == 1) {
                    off += 1;
                } else if (mod == 2) {
                    off += 4;
                }
            }
            if ((f & F_GROUP) && mod == 3 && reg <= 1) imm8 = true;
        }

        if (imm8) off += 1;
        if (f & F_IMM16) off += 2;
        if (f & F_IMM32) off += 4;
        if (f & F_IMMSZ) off += opsize16 ? 2 : 4;
        if (f & F_ADDR) off += 4;
        if (f & F_REL8) off += 1;
        if (f & F_REL32) off += 4;

        if (off > maxLen) {
            info.error = "truncated in operands";
            info.length = start;
            return info;
        }

        if (f & F_REL) info.hasRelative = true;
        if (f & F_TERM) info.hasTerminal = true;

        char hex[3 * 16 + 1] = {};
        size_t hn = 0;
        for (size_t k = start; k < off && hn + 4 < sizeof(hex); ++k) {
            hn += static_cast<size_t>(
                std::snprintf(hex + hn, sizeof(hex) - hn, "%02X ", buf[k]));
        }
        if (!text.empty()) text += "; ";
        text += hex;
        text += oi->n;
    }

    info.decoded = true;
    info.length = off;
    info.text = text;
    return info;
#endif
}
