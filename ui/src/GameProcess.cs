using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

namespace Octane.UI
{
    // Process discovery + injection. Every Process handed out is the caller's to
    // dispose; DisposeAll() exists for the list-returning helpers.
    public static class GameProcess
    {
        const uint PROCESS_ALL = 0x1F0FFF;
        const uint MEM_COMMIT_RESERVE = 0x3000;
        const uint MEM_RELEASE = 0x8000;
        const uint PAGE_READWRITE = 0x04;

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr OpenProcess(uint access, bool inherit, int pid);
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr VirtualAllocEx(IntPtr p, IntPtr addr, IntPtr size, uint type, uint protect);
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool VirtualFreeEx(IntPtr p, IntPtr addr, IntPtr size, uint type);
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool WriteProcessMemory(IntPtr p, IntPtr addr, byte[] buf, IntPtr size, out IntPtr written);
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        static extern IntPtr GetModuleHandleW(string name);
        [DllImport("kernel32.dll", CharSet = CharSet.Ansi, SetLastError = true)]
        static extern IntPtr GetProcAddress(IntPtr mod, string name);
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr CreateRemoteThread(IntPtr p, IntPtr attr, uint stack, IntPtr start,
                                                IntPtr param, uint flags, out IntPtr tid);
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool GetExitCodeThread(IntPtr thread, out uint code);   // LPDWORD: always 32-bit
        [DllImport("kernel32.dll")]
        static extern uint WaitForSingleObject(IntPtr h, uint ms);
        [DllImport("kernel32.dll")]
        static extern bool CloseHandle(IntPtr h);
        [DllImport("kernel32.dll")]
        static extern bool IsWow64Process(IntPtr h, out bool wow);

        public static readonly string[] KnownNames = { "OctanePlayer", "RobloxPlayerBeta" };

        public static List<Process> FindAll()
        {
            List<Process> found = new List<Process>();
            foreach (string name in KnownNames)
            {
                try { found.AddRange(Process.GetProcessesByName(name)); }
                catch { }
            }
            return found;
        }

        public static void DisposeAll(List<Process> list)
        {
            if (list == null) return;
            foreach (Process p in list)
            {
                try { p.Dispose(); } catch { }
            }
            list.Clear();
        }

        public static Process Find(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) name = KnownNames[0];
            if (name.EndsWith(".exe", StringComparison.OrdinalIgnoreCase))
                name = name.Substring(0, name.Length - 4);
            try
            {
                Process[] list = Process.GetProcessesByName(name);
                if (list.Length == 0) return null;
                for (int i = 1; i < list.Length; i++) list[i].Dispose();
                return list[0];
            }
            catch { return null; }
        }

        // ~1 microsecond, no heap: far cheaper than enumerating every process.
        public static bool IsPidAlive(int pid)
        {
            if (pid <= 0) return false;
            const uint SYNCHRONIZE = 0x00100000;
            const uint WAIT_TIMEOUT = 0x102;
            IntPtr h = OpenProcess(SYNCHRONIZE, false, pid);
            if (h == IntPtr.Zero)
            {
                // access denied still means the pid exists
                const int ERROR_ACCESS_DENIED = 5;
                return Marshal.GetLastWin32Error() == ERROR_ACCESS_DENIED;
            }
            try { return WaitForSingleObject(h, 0) == WAIT_TIMEOUT; }
            finally { CloseHandle(h); }
        }

        public static bool IsAlive(Process p)
        {
            try { return p != null && !p.HasExited; }
            catch { return false; }
        }

        // Target bitness: WOW64 only exists on 64-bit Windows, so a 32-bit OS
        // reports false for everything and must be handled explicitly.
        public static bool IsTarget64Bit(IntPtr handle, out string error)
        {
            error = null;
            bool wow;
            if (!IsWow64Process(handle, out wow))
            {
                error = "IsWow64Process failed (" + Marshal.GetLastWin32Error() + ")";
                return false;
            }
            return Environment.Is64BitOperatingSystem && !wow;
        }

        public static bool TryInject(int pid, string dllPath, out string detail)
        {
            detail = "";
            if (pid <= 0) { detail = "no target"; return false; }

            IntPtr handle = OpenProcess(PROCESS_ALL, false, pid);
            if (handle == IntPtr.Zero)
            {
                detail = "OpenProcess failed " + Marshal.GetLastWin32Error();
                return false;
            }

            IntPtr remote = IntPtr.Zero;
            IntPtr thread = IntPtr.Zero;
            bool remoteOwned = true;
            try
            {
                string archError;
                bool targetIs64 = IsTarget64Bit(handle, out archError);
                if (archError != null) { detail = archError; return false; }

                bool selfIs64 = Environment.Is64BitProcess;
                if (targetIs64 != selfIs64)
                {
                    detail = "architecture mismatch: injector is " + (selfIs64 ? "x64" : "x86") +
                             ", target is " + (targetIs64 ? "x64" : "x86");
                    return false;
                }

                byte[] pathBytes = Encoding.Unicode.GetBytes(dllPath + "\0");
                remote = VirtualAllocEx(handle, IntPtr.Zero, (IntPtr)pathBytes.Length,
                                        MEM_COMMIT_RESERVE, PAGE_READWRITE);
                if (remote == IntPtr.Zero) { detail = "VirtualAllocEx failed"; return false; }

                IntPtr written;
                if (!WriteProcessMemory(handle, remote, pathBytes, (IntPtr)pathBytes.Length, out written))
                {
                    detail = "WriteProcessMemory failed";
                    return false;
                }

                IntPtr loadLibrary = GetProcAddress(GetModuleHandleW("kernel32.dll"), "LoadLibraryW");
                if (loadLibrary == IntPtr.Zero) { detail = "LoadLibraryW not found"; return false; }

                IntPtr tid;
                thread = CreateRemoteThread(handle, IntPtr.Zero, 0, loadLibrary, remote, 0, out tid);
                if (thread == IntPtr.Zero)
                {
                    detail = "CreateRemoteThread failed " + Marshal.GetLastWin32Error();
                    return false;
                }

                // WAIT_OBJECT_0 == 0. If it times out the remote thread is still
                // reading the path buffer, so the buffer must stay valid.
                uint wait = WaitForSingleObject(thread, 10000);
                if (wait != 0)
                {
                    remoteOwned = false;
                    detail = "LoadLibraryW still running after 10s (code " + wait + ")";
                    return false;
                }

                uint exitCode;
                GetExitCodeThread(thread, out exitCode);
                detail = "LoadLibraryW -> 0x" + exitCode.ToString("X");
                return exitCode != 0;
            }
            finally
            {
                // the path buffer lives in the target: release it or it leaks there
                if (remoteOwned && remote != IntPtr.Zero) VirtualFreeEx(handle, remote, IntPtr.Zero, MEM_RELEASE);
                if (thread != IntPtr.Zero) CloseHandle(thread);
                CloseHandle(handle);
            }
        }
    }
}
