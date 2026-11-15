#include "Luau/Compiler.h"
#include <cstdio>
#include <string>

int main() {
    const char* src = "print('hi')";
    std::string bc;
    try {
        bc = Luau::compile(src);
    } catch (const std::exception& e) {
        std::printf("compile error: %s\n", e.what());
        return 3;
    }
    unsigned version = bc.empty() ? 0 : (unsigned char)bc[0];
    std::printf("[test] bytecode size=%zu version=%u\n", bc.size(), version);
    bool pass = !bc.empty() && version == 1;
    std::printf("[test] %s\n", pass ? "PASS" : "FAIL");
    return pass ? 0 : 2;
}
