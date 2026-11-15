// Validates the x86 prologue decoder against the real bytes of OctanePlayer.exe
// 0.463.0.417004 (RVA 0xF41980 lua_pcall, 0xF413C0 lua_gettop).
#include <cstdint>
#include <cstdio>
#include <cstring>

#include "prologue.h"

static int g_fail = 0;

static void Check(bool ok, const char* what) {
    std::printf("[%s] %s\n", ok ? "ok  " : "FAIL", what);
    if (!ok) ++g_fail;
}

static bool Contains(const std::string& hay, const char* needle) {
    return hay.find(needle) != std::string::npos;
}

int main() {
#if defined(_WIN64)
    std::printf("[test] x64 host: the decoder is x86-only, SKIP\n");
    return 0;
#else
    // lua_pcall, on-disk bytes (32 shown; the decoder never needs more than 18)
    static uint8_t pcall[32] = {0x55, 0x8B, 0xEC, 0x8B, 0x4D, 0x14, 0x83, 0xEC,
                                0x08, 0x53, 0x57, 0x8B, 0x7D, 0x08, 0x85, 0xC9,
                                0x75, 0x07, 0x8B, 0x5F, 0x0C, 0x33, 0xD2, 0xEB,
                                0x2B, 0x7E, 0x18, 0x8B, 0x47, 0x14, 0xBA, 0xC0};
    // lua_gettop: push ebp; mov ebp,esp; ... ; pop ebp; ret  (17 bytes)
    static uint8_t gettop[17] = {0x55, 0x8B, 0xEC, 0x8B, 0x4D, 0x08, 0x8B, 0x41,
                                 0x10, 0x2B, 0x41, 0x14, 0xC1, 0xF8, 0x04, 0x5D,
                                 0xC3};
    // synthetic: prologue that calls out (rel32) inside the copy range
    static uint8_t withCall[8] = {0x55, 0x8B, 0xEC, 0xE8, 0x11, 0x22, 0x33, 0x44};

    PrologueInfo a = DecodePrologue(reinterpret_cast<uintptr_t>(pcall), 6);
    Check(a.decoded, "pcall/6 decodes");
    Check(a.length == 6, "pcall/6 stops on the boundary after mov ecx,[ebp+0x14]");
    Check(!a.hasRelative, "pcall/6 has no relative branch");
    Check(!a.hasTerminal, "pcall/6 is not terminal");
    Check(Contains(a.text, "push ebp"), "pcall/6 text names push ebp");
    Check(Contains(a.text, "mov r32"), "pcall/6 text names the frameless arg load");

    PrologueInfo b = DecodePrologue(reinterpret_cast<uintptr_t>(pcall), 14);
    Check(b.decoded && b.length == 14, "pcall/14 lands exactly on 14 bytes");
    Check(!b.hasRelative, "pcall/14 still avoids the jcc at +16");

    PrologueInfo c = DecodePrologue(reinterpret_cast<uintptr_t>(pcall), 17);
    Check(c.decoded && c.length == 18, "pcall/17 extends past the jcc (18 bytes)");
    Check(c.hasRelative, "pcall/17 flags the relative jcc");

    PrologueInfo d = DecodePrologue(reinterpret_cast<uintptr_t>(gettop), 17);
    Check(d.decoded && d.length == 17, "gettop/17 covers the whole function");
    Check(d.hasTerminal, "gettop/17 flags ret");
    Check(!d.hasRelative, "gettop/17 has no relative branch");

    PrologueInfo e = DecodePrologue(reinterpret_cast<uintptr_t>(withCall), 8);
    Check(e.decoded, "call prologue decodes");
    Check(e.hasRelative, "call prologue is flagged unsafe");

    std::printf("[test] %s\n", g_fail == 0 ? "PASS" : "FAIL");
    return g_fail == 0 ? 0 : 2;
#endif
}
