using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace OctaneExecutor
{
    public class MainForm : Form
    {
        const uint PROCESS_ALL = 0x1F0FFF;
        const uint MEM_COMMIT_RESERVE = 0x3000;
        const uint PAGE_READWRITE = 0x04;
        const uint CREATE_THREAD = 0x00000000;

        [System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr OpenProcess(uint access, bool inherit, int pid);
        [System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr VirtualAllocEx(IntPtr p, IntPtr addr, IntPtr size, uint type, uint protect);
        [System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError = true)]
        static extern bool WriteProcessMemory(IntPtr p, IntPtr addr, byte[] buf, IntPtr size, out IntPtr written);
        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
        static extern IntPtr GetModuleHandle(string name);
        [System.Runtime.InteropServices.DllImport("kernel32.dll", CharSet = System.Runtime.InteropServices.CharSet.Ansi)]
        static extern IntPtr GetProcAddress(IntPtr mod, string name);
        [System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr CreateRemoteThread(IntPtr p, IntPtr attr, uint stack, IntPtr start, IntPtr param, uint flags, out IntPtr tid);
        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
        static extern uint WaitForSingleObject(IntPtr h, uint ms);
        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
        static extern bool CloseHandle(IntPtr h);
        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
        static extern bool IsWow64Process(IntPtr h, out bool wow);

        ComboBox processBox;
        TextBox scriptBox;
        TextBox outputBox;
        Label statusLabel;
        CheckBox autoBox;
        string injectedProcess = "";
        volatile bool autoOn = true;
        int autoPid = 0;
        bool autoBusy = false;

        public MainForm()
        {
            Text = "Octane Executor";
            Width = 1040;
            Height = 700;
            StartPosition = FormStartPosition.CenterScreen;
            BackColor = Color.FromArgb(18, 18, 20);
            ForeColor = Color.FromArgb(230, 230, 235);
            Font = new Font("Consolas", 9.5f);

            Panel top = new Panel();
            top.Dock = DockStyle.Top;
            top.Height = 44;
            top.BackColor = Color.FromArgb(27, 27, 30);

            processBox = new ComboBox();
            processBox.DropDownStyle = ComboBoxStyle.DropDown;
            processBox.SetBounds(12, 10, 220, 24);
            processBox.BackColor = Color.FromArgb(14, 14, 16);
            processBox.ForeColor = Color.White;
            processBox.Items.Add("OctanePlayer.exe");

            Button refresh = MakeButton("Scan", 240, 9, 60, delegate { RefreshProcesses(); });
            Button inject = MakeButton("Inject", 306, 9, 70, delegate { Inject(); });
            Button attach = MakeButton("Attach", 382, 9, 70, delegate { Attach(); });

            statusLabel = new Label();
            statusLabel.SetBounds(462, 13, 380, 20);
            statusLabel.Text = "idle";
            statusLabel.ForeColor = Color.FromArgb(140, 140, 150);

            autoBox = new CheckBox();
            autoBox.Text = "Auto";
            autoBox.Checked = true;
            autoBox.SetBounds(852, 11, 70, 22);
            autoBox.ForeColor = Color.FromArgb(200, 200, 210);
            autoBox.CheckedChanged += delegate { autoOn = autoBox.Checked; };

            top.Controls.Add(processBox);
            top.Controls.Add(refresh);
            top.Controls.Add(inject);
            top.Controls.Add(attach);
            top.Controls.Add(statusLabel);
            top.Controls.Add(autoBox);

            scriptBox = new TextBox();
            scriptBox.Multiline = true;
            scriptBox.ScrollBars = ScrollBars.Vertical;
            scriptBox.Dock = DockStyle.Fill;
            scriptBox.BackColor = Color.FromArgb(14, 14, 16);
            scriptBox.ForeColor = Color.FromArgb(230, 230, 235);
            scriptBox.BorderStyle = BorderStyle.None;
            scriptBox.Text = "print(\"hello from Octane\")";
            scriptBox.KeyDown += delegate(object s, KeyEventArgs e)
            {
                if (e.Control && e.KeyCode == Keys.Enter) { e.SuppressKeyPress = true; Execute(); }
            };

            Panel bottom = new Panel();
            bottom.Dock = DockStyle.Bottom;
            bottom.Height = 200;
            outputBox = new TextBox();
            outputBox.Multiline = true;
            outputBox.ReadOnly = true;
            outputBox.ScrollBars = ScrollBars.Vertical;
            outputBox.Dock = DockStyle.Fill;
            outputBox.BackColor = Color.FromArgb(22, 22, 24);
            outputBox.ForeColor = Color.FromArgb(160, 220, 180);
            outputBox.BorderStyle = BorderStyle.None;
            bottom.Controls.Add(outputBox);

            Panel toolbar = new Panel();
            toolbar.Dock = DockStyle.Bottom;
            toolbar.Height = 76;
            toolbar.BackColor = Color.FromArgb(27, 27, 30);

            Button run = MakeButton("Execute (Ctrl+Enter)", 12, 7, 160, delegate { Execute(); });
            Button open = MakeButton("Open .lua", 180, 7, 90, delegate { OpenScript(); });
            Button clear = MakeButton("Clear", 278, 7, 70, delegate { outputBox.Clear(); });

            Button hookPcall = MakeButton("Hook pcall", 12, 41, 96, delegate { Log("hookpcall: " + Pipe("HOOKPCALL")); });
            Button hookDPcall = MakeButton("Hook luaD", 114, 41, 90, delegate { Log("hook luaD_pcall: " + Pipe("HOOK rva:0xF43EF0")); });
            Button loadstring = MakeButton("Loadstring", 210, 41, 90, delegate { Log("loadstring: " + Pipe("LOADSTRING")); });
            Button hits = MakeButton("Hits 5s", 306, 41, 76, delegate { Hits(); });
            Button unhook = MakeButton("Unhook", 388, 41, 76, delegate { Log("unhook: " + Pipe("UNHOOK")); });
            Button prologues = MakeButton("Prologues", 470, 41, 90, delegate { Prologues(); });
            Button iy = MakeButton("Test loadstring (IY)", 566, 41, 150, delegate { TestInfiniteYield(); });

            toolbar.Controls.Add(run);
            toolbar.Controls.Add(open);
            toolbar.Controls.Add(clear);
            toolbar.Controls.Add(hookPcall);
            toolbar.Controls.Add(hookDPcall);
            toolbar.Controls.Add(loadstring);
            toolbar.Controls.Add(hits);
            toolbar.Controls.Add(unhook);
            toolbar.Controls.Add(prologues);
            toolbar.Controls.Add(iy);

            Controls.Add(scriptBox);
            Controls.Add(bottom);
            Controls.Add(toolbar);
            Controls.Add(top);

            RefreshProcesses();

            Thread auto = new Thread(AutoLoop);
            auto.IsBackground = true;
            auto.Name = "auto-inject";
            auto.Start();
        }

        // Watches for the client: injects on first sight of a pid, re-injects after
        // a restart, and attaches once the payload answers.
        void AutoLoop()
        {
            while (true)
            {
                Thread.Sleep(2000);
                if (!autoOn || autoBusy) continue;

                Process p = FindProcess();
                if (p == null)
                {
                    SetStatus("auto: waiting for OctanePlayer", Color.FromArgb(140, 140, 150));
                    continue;
                }

                string ping = Pipe("PING");
                if (ping == "PONG")
                {
                    if (p.Id != autoPid)
                    {
                        autoPid = p.Id;
                        Log("auto: payload already loaded in pid " + p.Id);
                        Attach();
                    }
                    continue;
                }

                if (autoPid == p.Id) continue;  // one attempt per client instance
                autoPid = p.Id;
                autoBusy = true;
                try
                {
                    SetStatus("auto: injecting pid " + p.Id, Color.FromArgb(251, 191, 36));
                    Log("auto: injecting pid " + p.Id);
                    if (TryInject(p)) Attach();
                }
                finally
                {
                    autoBusy = false;
                }
            }
        }

        Button MakeButton(string text, int x, int y, int w, EventHandler onClick)
        {
            Button b = new Button();
            b.Text = text;
            b.SetBounds(x, y, w, 26);
            b.FlatStyle = FlatStyle.Flat;
            b.BackColor = Color.FromArgb(38, 38, 42);
            b.ForeColor = Color.FromArgb(225, 225, 230);
            b.FlatAppearance.BorderColor = Color.FromArgb(60, 60, 66);
            b.Click += onClick;
            return b;
        }

        void RefreshProcesses()
        {
            processBox.Items.Clear();
            string[] names = { "OctanePlayer", "RobloxPlayerBeta" };
            foreach (string n in names)
            {
                foreach (Process p in Process.GetProcessesByName(n))
                {
                    processBox.Items.Add(p.ProcessName + ".exe");
                    break;
                }
            }
            if (processBox.Items.Count > 0) processBox.SelectedIndex = 0;
            Log("scan: " + processBox.Items.Count + " candidate process(es)");
        }

        void Log(string text)
        {
            if (outputBox.InvokeRequired)
            {
                outputBox.BeginInvoke((MethodInvoker)delegate { Log(text); });
                return;
            }
            outputBox.AppendText(text + Environment.NewLine);
        }

        void SetStatus(string text, Color color)
        {
            if (statusLabel.InvokeRequired)
            {
                statusLabel.BeginInvoke((MethodInvoker)delegate { SetStatus(text, color); });
                return;
            }
            statusLabel.Text = text;
            statusLabel.ForeColor = color;
        }

        Process FindProcess()
        {
            string name = (processBox.Text ?? "").Trim();
            if (name.Length == 0) name = "OctanePlayer";
            if (name.EndsWith(".exe")) name = name.Substring(0, name.Length - 4);
            Process[] list = Process.GetProcessesByName(name);
            return list.Length > 0 ? list[0] : null;
        }

        void Inject()
        {
            Process target = FindProcess();
            if (target == null) { Log("process not running: " + processBox.Text); return; }
            if (TryInject(target)) Attach();
        }

        bool TryInject(Process target)
        {
            string root = AppDomain.CurrentDomain.BaseDirectory;
            string payload = Path.Combine(root, "payload.dll");
            if (!File.Exists(payload))
            {
                Log("payload.dll not next to this exe: " + payload);
                return false;
            }

            IntPtr handle = OpenProcess(PROCESS_ALL, false, target.Id);
            if (handle == IntPtr.Zero) { Log("OpenProcess failed: " + System.Runtime.InteropServices.Marshal.GetLastWin32Error()); return false; }

            bool wow;
            IsWow64Process(handle, out wow);
            if (!wow)
            {
                Log("target is 64-bit, this build is 32-bit - use the x64 build");
                CloseHandle(handle);
                return false;
            }

            byte[] pathBytes = Encoding.Unicode.GetBytes(payload + "\0");
            IntPtr remote = VirtualAllocEx(handle, IntPtr.Zero, (IntPtr)pathBytes.Length, MEM_COMMIT_RESERVE, PAGE_READWRITE);
            IntPtr written;
            WriteProcessMemory(handle, remote, pathBytes, (IntPtr)pathBytes.Length, out written);
            IntPtr loadLibrary = GetProcAddress(GetModuleHandle("kernel32.dll"), "LoadLibraryW");
            IntPtr tid;
            IntPtr thread = CreateRemoteThread(handle, IntPtr.Zero, 0, loadLibrary, remote, CREATE_THREAD, out tid);
            if (thread == IntPtr.Zero) { Log("CreateRemoteThread failed: " + System.Runtime.InteropServices.Marshal.GetLastWin32Error()); CloseHandle(handle); return false; }
            WaitForSingleObject(thread, 10000);
            CloseHandle(thread);
            CloseHandle(handle);

            injectedProcess = target.ProcessName;
            Log("injected into " + target.ProcessName + " (" + target.Id + ")");
            Thread.Sleep(1200);
            return true;
        }

        void Attach()
        {
            try
            {
                string reply = Pipe("INIT");
                if (reply == "OK")
                {
                    SetStatus("attached", Color.FromArgb(52, 211, 153));
                    Log("attached — state captured, exec ready");
                }
                else
                {
                    SetStatus("init: " + reply, Color.FromArgb(251, 191, 36));
                    Log("init: " + reply);
                }
            }
            catch (Exception e)
            {
                SetStatus("pipe error", Color.FromArgb(248, 113, 113));
                Log("pipe error: " + e.Message);
            }
        }

        void Execute()
        {
            try
            {
                string reply = Pipe("EXEC " + B64Encode(scriptBox.Text));
                if (reply.Length == 0) reply = "(no output)";
                Log("> exec");
                Log(reply);
            }
            catch (Exception e)
            {
                Log("exec error: " + e.Message);
            }
        }

        void Hits()
        {
            string first = Pipe("HITS");
            Log(first);
            int n1 = ParseHits(first);
            Thread.Sleep(5000);
            string second = Pipe("HITS");
            Log(second);
            int n2 = ParseHits(second);
            if (n1 >= 0 && n2 >= 0)
            {
                int d = n2 - n1;
                Log("delta " + d + " over 5s" + (d == 0 ? "  <- hook never fired" : ""));
            }
        }

        static int ParseHits(string reply)
        {
            int i = reply.IndexOf("hits=");
            if (i < 0) return -1;
            int j = reply.IndexOf(' ', i);
            string num = j < 0 ? reply.Substring(i + 5) : reply.Substring(i + 5, j - i - 5);
            int v;
            return int.TryParse(num, out v) ? v : -1;
        }

        void Prologues()
        {
            string[] rvas = { "0xF413C0", "0xF41980", "0xF43EF0", "0xF4C710" };
            foreach (string rva in rvas) Log(rva + ": " + Pipe("PROLOGUE rva:" + rva));
        }

        void TestInfiniteYield()
        {
            string test = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source\"))()";
            scriptBox.Text = test;
            Log("=== loadstring test (Infinite Yield) ===");
            Log("loadstring: " + Pipe("LOADSTRING"));
            Log("exec: " + Pipe("EXEC " + B64Encode(test)));
        }

        void OpenScript()
        {
            OpenFileDialog d = new OpenFileDialog();
            d.Filter = "Lua scripts|*.lua;*.txt|All files|*.*";
            if (d.ShowDialog() == DialogResult.OK) scriptBox.Text = File.ReadAllText(d.FileName);
        }

        static string Pipe(string command)
        {
            try
            {
                using (NamedPipeClientStream pipe = new NamedPipeClientStream(".", "octane_exec", PipeDirection.InOut))
                {
                    pipe.Connect(3000);
                    byte[] bytes = Encoding.ASCII.GetBytes(command + "\n");
                    pipe.Write(bytes, 0, bytes.Length);
                    pipe.Flush();
                    using (StreamReader reader = new StreamReader(pipe, Encoding.ASCII))
                    {
                        return B64Decode(reader.ReadToEnd());
                    }
                }
            }
            catch (Exception e)
            {
                return "ERR pipe: " + e.Message + " (inject first?)";
            }
        }

        static string B64Encode(string text)
        {
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(text));
        }

        static string B64Decode(string text)
        {
            try { return Encoding.UTF8.GetString(Convert.FromBase64String(text)); }
            catch { return text; }
        }

        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.Run(new MainForm());
        }
    }
}
