// Self-test for the inline hook: hooks a trivial local function and verifies
// the callback fires while the original behaviour is preserved.
#include <windows.h>
#include <atomic>
#include <cstdint>
#include <cstdio>

#include "hook.h"

static std::atomic<int> g_hits{0};

static void OnHit(SavedRegs*) {
    g_hits.fetch_add(1);
    std::printf("[test] hook fired\n");
}

__declspec(noinline) static int TargetFunc(int a, int b) {
    return a + b;
}

int main() {
    std::printf("[test] target   %p\n", reinterpret_cast<void*>(&TargetFunc));

    int before = TargetFunc(2, 3);

    SetHookCallback(OnHit);
    bool installed = InstallInlineHook(reinterpret_cast<uintptr_t>(&TargetFunc), 14);
    std::printf("[test] install  %s\n", installed ? "ok" : "failed");
    if (!installed) return 1;

    int during = TargetFunc(20, 25);

    bool removed = RemoveInlineHook();
    int after = TargetFunc(2, 3);

    bool pass = g_hits.load() == 1 && before == 5 && during == 45 && after == 5 && removed;
    std::printf("[test] hits=%d before=%d during=%d after=%d unhook=%d\n", g_hits.load(),
                before, during, after, static_cast<int>(removed));
    std::printf("[test] %s\n", pass ? "PASS" : "FAIL");
    return pass ? 0 : 2;
}
