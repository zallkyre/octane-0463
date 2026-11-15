#pragma once
#include <cstddef>
#include <cstdint>
#include <string>

// Decoded view of a function's first bytes, used to pick a detour length that
// ends on an instruction boundary and to refuse copies that a trampoline would
// break (relative branches).
struct PrologueInfo {
    bool decoded = false;      // every byte in [0, length) is a whole instruction
    size_t length = 0;         // bytes covered by whole instructions (>= minLen)
    bool hasRelative = false;  // rel8/rel32 jmp, jcc, call, loop inside the range
    bool hasTerminal = false;  // ret / int3 / ud2 / hlt inside the range
    std::string text;          // "55 push ebp; 8B EC mov ebp,esp; ..."
    std::string error;         // set when decoded == false
};

// x86 (32-bit) only. On x64 returns decoded == false with an explanatory error.
PrologueInfo DecodePrologue(uintptr_t addr, size_t minLen, size_t maxLen = 32);
