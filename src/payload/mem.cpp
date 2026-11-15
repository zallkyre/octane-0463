#include "mem.h"

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <cwctype>
#include <tlhelp32.h>

static size_t SizeOfImageAt(uintptr_t base) {
    auto dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(base);
    if (!dos || dos->e_magic != IMAGE_DOS_SIGNATURE) {
        return 0;
    }
    auto nt = reinterpret_cast<const IMAGE_NT_HEADERS*>(base + dos->e_lfanew);
    if (!nt || nt->Signature != IMAGE_NT_SIGNATURE) {
        return 0;
    }
    return nt->OptionalHeader.SizeOfImage;
}

ModuleRange MainModule() {
    ModuleRange out;
    HMODULE exe = GetModuleHandleW(nullptr);
    out.base = reinterpret_cast<uintptr_t>(exe);
    out.size = SizeOfImageAt(out.base);
    return out;
}

std::vector<std::pair<std::wstring, ModuleRange>> ListModules() {
    std::vector<std::pair<std::wstring, ModuleRange>> out;
    HANDLE snap =
        CreateToolhelp32Snapshot(TH32CS_SNAPMODULE | TH32CS_SNAPMODULE32, GetCurrentProcessId());
    if (snap == INVALID_HANDLE_VALUE) {
        return out;
    }
    MODULEENTRY32W me{};
    me.dwSize = sizeof(me);
    if (Module32FirstW(snap, &me)) {
        do {
            out.emplace_back(me.szModule,
                             ModuleRange{reinterpret_cast<uintptr_t>(me.modBaseAddr),
                                         static_cast<size_t>(me.modBaseSize)});
        } while (Module32NextW(snap, &me));
    }
    CloseHandle(snap);
    return out;
}

bool PatternToBytes(const std::string& text, std::vector<uint8_t>& bytes,
                    std::vector<bool>& wildcard) {
    bytes.clear();
    wildcard.clear();

    size_t i = 0;
    while (i < text.size()) {
        while (i < text.size() && (text[i] == ' ' || text[i] == '\t')) {
            ++i;
        }
        if (i >= text.size()) {
            break;
        }
        size_t begin = i;
        while (i < text.size() && text[i] != ' ' && text[i] != '\t') {
            ++i;
        }
        std::string token = text.substr(begin, i - begin);

        if (token == "?" || token == "??") {
            bytes.push_back(0);
            wildcard.push_back(true);
            continue;
        }
        if (token.size() != 2) {
            return false;
        }
        auto hex = [](char c) -> int {
            if (c >= '0' && c <= '9') return c - '0';
            if (c >= 'a' && c <= 'f') return c - 'a' + 10;
            if (c >= 'A' && c <= 'F') return c - 'A' + 10;
            return -1;
        };
        int hi = hex(token[0]);
        int lo = hex(token[1]);
        if (hi < 0 || lo < 0) {
            return false;
        }
        bytes.push_back(static_cast<uint8_t>((hi << 4) | lo));
        wildcard.push_back(false);
    }
    return !bytes.empty();
}

bool ParseHex(const std::string& text, uintptr_t& out) {
    std::string s = text;
    if (s.size() > 2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) {
        s = s.substr(2);
    }
    if (s.empty()) {
        return false;
    }
    try {
        out = static_cast<uintptr_t>(std::stoull(s, nullptr, 16));
        return true;
    } catch (...) {
        return false;
    }
}

static int Nibble(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

std::vector<uint8_t> ParseBytes(const std::string& text) {
    std::vector<uint8_t> out;
    std::string digits;
    for (char c : text) {
        if (c == ' ' || c == '\t' || c == ',' || c == '-') continue;
        if (Nibble(c) < 0) return {};
        digits.push_back(c);
    }
    if (digits.size() % 2 != 0) return {};
    for (size_t i = 0; i < digits.size(); i += 2) {
        out.push_back(static_cast<uint8_t>((Nibble(digits[i]) << 4) | Nibble(digits[i + 1])));
    }
    return out;
}

static bool PageReadable(const MEMORY_BASIC_INFORMATION& mbi) {
    if (mbi.State != MEM_COMMIT) return false;
    if (mbi.Protect & (PAGE_GUARD | PAGE_NOACCESS)) return false;
    DWORD p = mbi.Protect & 0xFF;
    return p == PAGE_READONLY || p == PAGE_READWRITE || p == PAGE_WRITECOPY ||
           p == PAGE_EXECUTE_READ || p == PAGE_EXECUTE_READWRITE ||
           p == PAGE_EXECUTE_WRITECOPY;
}

static bool PageWritable(const MEMORY_BASIC_INFORMATION& mbi) {
    if (mbi.State != MEM_COMMIT) return false;
    if (mbi.Protect & (PAGE_GUARD | PAGE_NOACCESS)) return false;
    DWORD p = mbi.Protect & 0xFF;
    return p == PAGE_READWRITE || p == PAGE_WRITECOPY || p == PAGE_EXECUTE_READWRITE ||
           p == PAGE_EXECUTE_WRITECOPY;
}

bool SafeRead(uintptr_t addr, void* buf, size_t len) {
    auto out = static_cast<uint8_t*>(buf);
    size_t left = len;
    uintptr_t cur = addr;
    while (left) {
        MEMORY_BASIC_INFORMATION mbi{};
        if (!VirtualQuery(reinterpret_cast<LPCVOID>(cur), &mbi, sizeof(mbi))) return false;
        if (!PageReadable(mbi)) return false;
        uintptr_t regionEnd =
            reinterpret_cast<uintptr_t>(mbi.BaseAddress) + mbi.RegionSize;
        size_t avail = static_cast<size_t>(regionEnd - cur);
        size_t n = std::min(avail, left);
        std::memcpy(out, reinterpret_cast<const void*>(cur), n);
        out += n;
        cur += n;
        left -= n;
    }
    return true;
}

bool SafeWrite(uintptr_t addr, const void* buf, size_t len) {
    auto in = static_cast<const uint8_t*>(buf);
    size_t left = len;
    uintptr_t cur = addr;
    while (left) {
        MEMORY_BASIC_INFORMATION mbi{};
        if (!VirtualQuery(reinterpret_cast<LPCVOID>(cur), &mbi, sizeof(mbi))) return false;
        if (!PageWritable(mbi)) return false;
        uintptr_t regionEnd =
            reinterpret_cast<uintptr_t>(mbi.BaseAddress) + mbi.RegionSize;
        size_t avail = static_cast<size_t>(regionEnd - cur);
        size_t n = std::min(avail, left);
        std::memcpy(reinterpret_cast<void*>(cur), in, n);
        in += n;
        cur += n;
        left -= n;
    }
    return true;
}

uintptr_t ScanModule(const ModuleRange& mod, const std::vector<uint8_t>& bytes,
                     const std::vector<bool>& wildcard, uintptr_t startOffset) {
    if (mod.base == 0 || mod.size == 0 || bytes.empty() ||
        bytes.size() > mod.size || wildcard.size() != bytes.size()) {
        return 0;
    }
    const uintptr_t begin = mod.base + startOffset;
    const uintptr_t end = mod.base + mod.size;
    if (begin >= end) return 0;

    const size_t plen = bytes.size();
    uintptr_t p = begin;
    while (p + plen <= end) {
        MEMORY_BASIC_INFORMATION mbi{};
        if (!VirtualQuery(reinterpret_cast<LPCVOID>(p), &mbi, sizeof(mbi))) break;
        uintptr_t regionEnd =
            reinterpret_cast<uintptr_t>(mbi.BaseAddress) + mbi.RegionSize;
        if (regionEnd > end) regionEnd = end;

        if (PageReadable(mbi)) {
            const auto* data = reinterpret_cast<const uint8_t*>(p);
            size_t limit = static_cast<size_t>(regionEnd - p);
            if (limit < plen) {
                p = regionEnd;
                continue;
            }
            for (size_t off = 0; off + plen <= limit; ++off) {
                bool hit = true;
                for (size_t k = 0; k < plen; ++k) {
                    if (!wildcard[k] && data[off + k] != bytes[k]) {
                        hit = false;
                        break;
                    }
                }
                if (hit) return p + off;
            }
        }
        if (regionEnd <= p) break;
        p = regionEnd;
    }
    return 0;
}

std::string HexDump(const void* data, size_t len) {
    const auto* b = static_cast<const uint8_t*>(data);
    std::string out;
    char line[128];
    for (size_t off = 0; off < len; off += 16) {
        std::snprintf(line, sizeof(line), "%016llX  ", static_cast<unsigned long long>(off));
        out += line;
        for (size_t i = 0; i < 16; ++i) {
            if (off + i < len) {
                std::snprintf(line, sizeof(line), "%02X ", b[off + i]);
            } else {
                std::snprintf(line, sizeof(line), "   ");
            }
            out += line;
        }
        out += " ";
        for (size_t i = 0; i < 16 && off + i < len; ++i) {
            uint8_t c = b[off + i];
            out += (c >= 32 && c < 127) ? static_cast<char>(c) : '.';
        }
        out += "\n";
    }
    return out;
}

bool DumpMainModule(const std::wstring& outPath) {
    ModuleRange m = MainModule();
    if (m.base == 0 || m.size == 0) return false;

    auto dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(m.base);
    if (!dos || dos->e_magic != IMAGE_DOS_SIGNATURE) return false;
    auto nt = reinterpret_cast<const IMAGE_NT_HEADERS*>(m.base + dos->e_lfanew);
    if (!nt || nt->Signature != IMAGE_NT_SIGNATURE) return false;

    constexpr DWORD kAlign = 0x1000;
    auto roundUp = [](DWORD v, DWORD a) { return (v + a - 1) & ~(a - 1); };

    const DWORD headersOriginal = nt->OptionalHeader.SizeOfHeaders;
    const DWORD headers = roundUp(headersOriginal, kAlign);

    const IMAGE_SECTION_HEADER* sec = IMAGE_FIRST_SECTION(nt);
    size_t total = headers;
    for (WORD i = 0; i < nt->FileHeader.NumberOfSections; ++i) {
        total += roundUp(sec[i].Misc.VirtualSize, kAlign);
    }

    std::vector<uint8_t> img(total, 0);
    if (!SafeRead(m.base, img.data(), headersOriginal)) return false;

    auto outDos = reinterpret_cast<IMAGE_DOS_HEADER*>(img.data());
    auto outNt = reinterpret_cast<IMAGE_NT_HEADERS*>(img.data() + outDos->e_lfanew);
    outNt->OptionalHeader.FileAlignment = kAlign;
    outNt->OptionalHeader.SizeOfHeaders = headers;

    auto outSec = IMAGE_FIRST_SECTION(outNt);
    DWORD ptr = headers;
    for (WORD i = 0; i < outNt->FileHeader.NumberOfSections; ++i) {
        DWORD vsize = outSec[i].Misc.VirtualSize;
        DWORD rawSize = roundUp(vsize, kAlign);
        if (vsize != 0) {
            SafeRead(m.base + outSec[i].VirtualAddress, img.data() + ptr, vsize);
        }
        outSec[i].PointerToRawData = ptr;
        outSec[i].SizeOfRawData = rawSize;
        ptr += rawSize;
    }

    std::ofstream out(outPath, std::ios::binary | std::ios::trunc);
    if (!out) return false;
    out.write(reinterpret_cast<const char*>(img.data()),
              static_cast<std::streamsize>(img.size()));
    return out.good();
}
