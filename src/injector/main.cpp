// injector.exe <process name | pid> <payload.dll>
//
// Classic user-mode injector: OpenProcess -> VirtualAllocEx -> WriteProcessMemory
// -> CreateRemoteThread(LoadLibraryW). Same approach most public injectors use.
// The process name is a CLI argument; nothing is hardcoded.

#include <windows.h>
#include <tlhelp32.h>
#include <cwchar>
#include <cwctype>
#include <string>

static void PrintLastError(const wchar_t* what) {
    wprintf(L"[injector] %s failed: error %lu\n", what, GetLastError());
}

static DWORD FindPidByName(const std::wstring& name) {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) {
        return 0;
    }
    PROCESSENTRY32W pe{};
    pe.dwSize = sizeof(pe);
    DWORD pid = 0;
    if (Process32FirstW(snap, &pe)) {
        do {
            if (_wcsicmp(pe.szExeFile, name.c_str()) == 0) {
                pid = pe.th32ProcessID;
                break;
            }
        } while (Process32NextW(snap, &pe));
    }
    CloseHandle(snap);
    return pid;
}

static bool TargetMatchesBitness(HANDLE proc) {
    // WOW64 target == 32-bit process. Our own bitness decides which side is wrong.
    BOOL targetWow = FALSE;
    BOOL selfWow = FALSE;
    IsWow64Process(proc, &targetWow);
    IsWow64Process(GetCurrentProcess(), &selfWow);
#if defined(_WIN64)
    return targetWow == FALSE;   // 64-bit injector needs a 64-bit target
#else
    if (!selfWow) return TRUE;   // 32-bit OS: everything is 32-bit
    return targetWow == TRUE;    // 64-bit OS: 32-bit injector needs a WOW64 target
#endif
}

static bool InjectDll(DWORD pid, const std::wstring& dllPath) {
    HANDLE proc = OpenProcess(PROCESS_CREATE_THREAD | PROCESS_QUERY_INFORMATION |
                                  PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ,
                              FALSE, pid);
    if (!proc) {
        PrintLastError(L"OpenProcess");
        return false;
    }

    if (!TargetMatchesBitness(proc)) {
#if defined(_WIN64)
        wprintf(L"[injector] target is 32-bit; use injector32.exe + payload32.dll\n");
#else
        wprintf(L"[injector] target is 64-bit; use injector64.exe + payload64.dll\n");
#endif
        CloseHandle(proc);
        return false;
    }

    const SIZE_T bytes = (dllPath.size() + 1) * sizeof(wchar_t);
    void* remote = VirtualAllocEx(proc, nullptr, bytes, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (!remote) {
        PrintLastError(L"VirtualAllocEx");
        CloseHandle(proc);
        return false;
    }

    bool ok = false;
    if (!WriteProcessMemory(proc, remote, dllPath.c_str(), bytes, nullptr)) {
        PrintLastError(L"WriteProcessMemory");
    } else {
        HMODULE k32 = GetModuleHandleW(L"kernel32.dll");
        auto loadLibrary =
            reinterpret_cast<LPTHREAD_START_ROUTINE>(GetProcAddress(k32, "LoadLibraryW"));
        if (!loadLibrary) {
            PrintLastError(L"GetProcAddress(LoadLibraryW)");
        } else {
            HANDLE thread =
                CreateRemoteThread(proc, nullptr, 0, loadLibrary, remote, 0, nullptr);
            if (!thread) {
                PrintLastError(L"CreateRemoteThread");
            } else {
                WaitForSingleObject(thread, 15000);
                DWORD code = 0;
                GetExitCodeThread(thread, &code);
                CloseHandle(thread);
                wprintf(L"[injector] remote LoadLibraryW returned 0x%08lX\n", code);
                ok = true;
            }
        }
    }

    VirtualFreeEx(proc, remote, 0, MEM_RELEASE);
    CloseHandle(proc);
    return ok;
}

int wmain(int argc, wchar_t** argv) {
    if (argc < 3) {
        wprintf(L"usage: injector.exe <process.exe | pid> <payload.dll>\n");
        wprintf(L"  injector.exe game.exe payload.dll\n");
        wprintf(L"  injector.exe 12345 payload.dll\n");
        return 1;
    }

    std::wstring target = argv[1];
    DWORD pid = 0;
    if (!target.empty() && iswdigit(target[0])) {
        pid = static_cast<DWORD>(wcstoul(target.c_str(), nullptr, 10));
    } else {
        pid = FindPidByName(target);
    }
    if (!pid) {
        wprintf(L"[injector] process not found: %ls\n", target.c_str());
        return 2;
    }

    wchar_t full[MAX_PATH] = {};
    if (!GetFullPathNameW(argv[2], MAX_PATH, full, nullptr) ||
        GetFileAttributesW(full) == INVALID_FILE_ATTRIBUTES) {
        wprintf(L"[injector] payload not found: %ls\n", argv[2]);
        return 3;
    }

    wprintf(L"[injector] target pid %lu, payload %ls\n", pid, full);
    return InjectDll(pid, full) ? 0 : 4;
}
