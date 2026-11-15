#include <windows.h>

#include "console.h"
#include "hook.h"
#include "pipe.h"

static DWORD WINAPI BackgroundThread(LPVOID param) {
    RunConsole(static_cast<HMODULE>(param));
    return 0;
}

BOOL WINAPI DllMain(HMODULE self, DWORD reason, LPVOID) {
    switch (reason) {
        case DLL_PROCESS_ATTACH: {
            DisableThreadLibraryCalls(self);
            StartPipeServer();
            HANDLE thread = CreateThread(nullptr, 0, BackgroundThread, self, 0, nullptr);
            if (thread) {
                CloseHandle(thread);
            }
            break;
        }
        case DLL_PROCESS_DETACH: {
            // Never leave a patched prologue behind.
            RemoveInlineHook();
            break;
        }
        default:
            break;
    }
    return TRUE;
}
