#pragma once
#include <windows.h>
#include <cstdint>
#include <string>
#include <utility>
#include <vector>

struct ModuleRange {
    uintptr_t base = 0;
    size_t size = 0;
};

// main executable of this process
ModuleRange MainModule();

// every loaded module, in load order
std::vector<std::pair<std::wstring, ModuleRange>> ListModules();

// "48 8B ?? ?? 0F" -> bytes + wildcard flags. Returns false on bad token.
bool PatternToBytes(const std::string& text, std::vector<uint8_t>& bytes,
                    std::vector<bool>& wildcard);

// first match inside [mod.base + startOffset, mod.base + mod.size)
uintptr_t ScanModule(const ModuleRange& mod, const std::vector<uint8_t>& bytes,
                     const std::vector<bool>& wildcard, uintptr_t startOffset = 0);

bool SafeRead(uintptr_t addr, void* buf, size_t len);
bool SafeWrite(uintptr_t addr, const void* buf, size_t len);

bool ParseHex(const std::string& text, uintptr_t& out);            // "0x7FF6..." or "7ff6..."
std::vector<uint8_t> ParseBytes(const std::string& text);          // "90 90 CC"
std::string HexDump(const void* data, size_t len);

// Writes the main module as it is right now (unpacked, in memory) to a file that
// a disassembler can open. Needed for protected/PACKED targets whose on-disk
// sections are encrypted (VMProtect etc.).
bool DumpMainModule(const std::wstring& outPath);
