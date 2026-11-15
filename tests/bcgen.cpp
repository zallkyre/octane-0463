// Prints compiled bytecode for a source string: hex + base64, for probing the
// host loader with hand-modified variants.
//   bcgen.exe "return 2" [opt] [dbg]
#include "Luau/Compiler.h"

#include <cstdio>
#include <cstdlib>
#include <string>

static const char* kB64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static std::string B64(const std::string& in) {
    std::string out;
    int val = 0, valb = -6;
    for (unsigned char c : in) {
        val = (val << 8) + c;
        valb += 8;
        while (valb >= 0) {
            out.push_back(kB64[(val >> valb) & 0x3F]);
            valb -= 6;
        }
    }
    if (valb > -6) out.push_back(kB64[((val << 8) >> (valb + 8)) & 0x3F]);
    while (out.size() % 4) out.push_back('=');
    return out;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::printf("usage: bcgen \"<source>\" [opt] [dbg]\n");
        return 2;
    }
    Luau::CompileOptions options;
    options.optimizationLevel = argc > 2 ? std::atoi(argv[2]) : 0;
    options.debugLevel = argc > 3 ? std::atoi(argv[3]) : 0;

    std::string bc;
    try {
        bc = Luau::compile(argv[1], options);
    } catch (const std::exception& e) {
        std::printf("compile error: %s\n", e.what());
        return 3;
    }

    std::printf("size=%zu opt=%d dbg=%d\n", bc.size(), options.optimizationLevel,
                options.debugLevel);
    for (size_t i = 0; i < bc.size(); ++i) {
        if (i % 16 == 0) std::printf("%s0x%04zX: ", i ? "\n" : "", i);
        std::printf("%02X ", (unsigned char)bc[i]);
    }
    std::printf("\nb64=%s\n", B64(bc).c_str());
    return 0;
}
