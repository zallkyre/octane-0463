// Self-test for the memory image dumper: dumps this process and validates the PE.
#include <windows.h>
#include <cstdio>
#include <cstdint>
#include <vector>

#include "mem.h"

int main() {
    const wchar_t* out = L"dump_test_out.exe";
    bool dumped = DumpMainModule(out);
    std::printf("[test] dump=%d\n", static_cast<int>(dumped));
    if (!dumped) {
        std::printf("[test] FAIL\n");
        return 2;
    }

    FILE* f = nullptr;
    _wfopen_s(&f, out, L"rb");
    if (!f) {
        std::printf("[test] FAIL (cannot reopen)\n");
        return 2;
    }
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    fseek(f, 0, SEEK_SET);
    unsigned char hdr[0x1000] = {};
    size_t got = fread(hdr, 1, sizeof(hdr), f);
    fclose(f);

    bool valid = false;
    int sections = 0;
    if (got > 0x200) {
        auto dos = reinterpret_cast<IMAGE_DOS_HEADER*>(hdr);
        if (dos->e_magic == IMAGE_DOS_SIGNATURE) {
            auto nt = reinterpret_cast<IMAGE_NT_HEADERS*>(hdr + dos->e_lfanew);
            if (nt->Signature == IMAGE_NT_SIGNATURE) {
                valid = true;
                sections = nt->FileHeader.NumberOfSections;
            }
        }
    }

    std::printf("[test] file=%ld bytes valid_pe=%d sections=%d\n", size,
                static_cast<int>(valid), sections);
    bool pass = valid && sections > 0 && size > 0x1000;
    std::printf("[test] %s\n", pass ? "PASS" : "FAIL");
    return pass ? 0 : 2;
}
