using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Octane.UI
{
    public class MainForm : Form
    {
        readonly string _dllPath;
        readonly string _scriptsDir;
        readonly ToolTip _tt = new ToolTip();

        TitleBar _title;
        DoubleBufferedPanel _content;
        StatusPill _status;
        FlatButton _connectButton;
        FlatButton _runButton;
        FlatButton _autoButton;

        // executor page
        ComboBox _gameBox;
        RichTextBox _editor;
        RichTextBox _out;
        TableLayoutPanel _execTable;

        // pages
        DoubleBufferedPanel _pageExec, _pageScripts, _pageTools;
        NavButton _navExec, _navScripts, _navTools;

        // state
        bool _auto = true;
        bool _busy;
        bool _connecting;
        bool _autoBusy;
        bool _connected;
        int _currentPage = -1;
        System.Windows.Forms.Timer _slideTimer;
        System.Windows.Forms.Timer _fadeTimer;
        Panel _navBar;
        System.Windows.Forms.Timer _navTimer;
        int _lastPid;
        readonly StringBuilder _pending = new StringBuilder();
        readonly object _logLock = new object();
        System.Windows.Forms.Timer _logTimer;
        System.Windows.Forms.Timer _autoTimer;
        System.Windows.Forms.Timer _logPoll;
        bool _polling;
        bool _payloadHasLog = true;
        string _logLastLine;
        int _logRepeat;
        int _logRepeatAt;
        bool _closing;

        public MainForm()
        {
            string root = AppDomain.CurrentDomain.BaseDirectory;
            _dllPath = Path.Combine(root, "payload.dll");
            _scriptsDir = Path.Combine(root, "scripts");
            Directory.CreateDirectory(_scriptsDir);

            Text = "Octane";
            try { Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath); } catch { }
            FormBorderStyle = FormBorderStyle.None;
            BackColor = Palette.Bg;
            ForeColor = Palette.Text;
            Font = Palette.Body;
            Size = new Size(1060, 690);
            MinimumSize = new Size(900, 560);
            StartPosition = FormStartPosition.CenterScreen;
            DoubleBuffered = true;

            // dock order matters: Fill is added first so the sidebar and status bar
            // claim their edges before it fills what is left
            BuildContent();
            BuildStatusBar();
            BuildSidebar();

            _title = new TitleBar(this, "OCTANE  -  executor");
            Controls.Add(_title);

            _logTimer = new System.Windows.Forms.Timer();
            _logTimer.Interval = 80;
            _logTimer.Tick += delegate { FlushLog(); };
            _logTimer.Start();

            _autoTimer = new System.Windows.Forms.Timer();
            _autoTimer.Interval = 3000;
            _autoTimer.Tick += delegate { AutoTick(); };
            _autoTimer.Start();

            _logPoll = new System.Windows.Forms.Timer();
            _logPoll.Interval = 700;
            _logPoll.Tick += delegate { PollPayloadLog(); };
            _logPoll.Start();

            Shown += delegate
            {
                RoundCorners();
                LoadWindowBounds();
                // prime it here too: OnResize may not have run before the first maximize
                MaximizedBounds = Screen.FromControl(this).WorkingArea;
                FadeIn();
                ShowPage(0);
                RefreshGames();
                _editor.Focus();
                Log("Start Octane, then press Connect.");
            };
            Resize += delegate { RoundCorners(); };
            ShowPage(0);
        }

        void FadeIn()
        {
            Opacity = 0.0;
            if (_fadeTimer != null) { _fadeTimer.Stop(); _fadeTimer.Dispose(); }
            _fadeTimer = new System.Windows.Forms.Timer();
            _fadeTimer.Interval = 15;
            _fadeTimer.Tick += delegate
            {
                double next = Opacity + 0.12;
                if (next >= 1.0)
                {
                    Opacity = 1.0;
                    _fadeTimer.Stop();
                    _fadeTimer.Dispose();
                    _fadeTimer = null;
                    return;
                }
                Opacity = next;
            };
            _fadeTimer.Start();
        }


        static string BoundsPath()
        {
            string dir = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Octane");
            Directory.CreateDirectory(dir);
            return Path.Combine(dir, "window.txt");
        }

        void LoadWindowBounds()
        {
            try
            {
                string path = BoundsPath();
                if (!File.Exists(path)) return;
                string[] parts = File.ReadAllText(path).Split(',');
                if (parts.Length != 4) return;
                int x, y, w, h;
                if (!int.TryParse(parts[0], out x)) return;
                if (!int.TryParse(parts[1], out y)) return;
                if (!int.TryParse(parts[2], out w)) return;
                if (!int.TryParse(parts[3], out h)) return;
                w = Math.Max(MinimumSize.Width, w);
                h = Math.Max(MinimumSize.Height, h);
                Rectangle r = new Rectangle(x, y, w, h);
                Rectangle screen = Screen.FromPoint(new Point(x, y)).WorkingArea;
                if (!screen.IntersectsWith(r)) return;
                Bounds = r;
                RoundCorners();
            }
            catch { }
        }

        void SaveBounds()
        {
            try
            {
                Rectangle r = WindowState == FormWindowState.Normal ? Bounds : RestoreBounds;
                File.WriteAllText(BoundsPath(),
                    r.Left + "," + r.Top + "," + r.Width + "," + r.Height);
            }
            catch { }
        }

        // Borderless form: allow resizing from the edges.
        protected override void WndProc(ref Message m)
        {
            const int WM_NCHITTEST = 0x84;
            const int HTCLIENT = 1;
            const int HTLEFT = 10, HTRIGHT = 11, HTTOP = 12, HTTOPLEFT = 13;
            const int HTTOPRIGHT = 14, HTBOTTOM = 15, HTBOTTOMLEFT = 16, HTBOTTOMRIGHT = 17;

            base.WndProc(ref m);

            if (m.Msg != WM_NCHITTEST || (long)m.Result != HTCLIENT) return;

            long lp = m.LParam.ToInt64();
            Point screen = new Point((short)(lp & 0xFFFF), (short)((lp >> 16) & 0xFFFF));
            Point p = PointToClient(screen);
            const int grip = 7;

            bool left = p.X <= grip;
            bool right = p.X >= ClientSize.Width - grip;
            bool top = p.Y <= grip;
            bool bottom = p.Y >= ClientSize.Height - grip;

            if (top && left) m.Result = (IntPtr)HTTOPLEFT;
            else if (top && right) m.Result = (IntPtr)HTTOPRIGHT;
            else if (bottom && left) m.Result = (IntPtr)HTBOTTOMLEFT;
            else if (bottom && right) m.Result = (IntPtr)HTBOTTOMRIGHT;
            else if (left) m.Result = (IntPtr)HTLEFT;
            else if (right) m.Result = (IntPtr)HTRIGHT;
            else if (top) m.Result = (IntPtr)HTTOP;
            else if (bottom) m.Result = (IntPtr)HTBOTTOM;
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            // never block a Windows shutdown or Task Manager with a 90ms fade
            if (!_closing && e.CloseReason == CloseReason.UserClosing)
            {
                e.Cancel = true;
                _closing = true;
                if (_fadeTimer != null) { _fadeTimer.Stop(); _fadeTimer.Dispose(); _fadeTimer = null; }
                SaveBounds();
                System.Windows.Forms.Timer t = new System.Windows.Forms.Timer();
                t.Interval = 15;
                t.Tick += delegate
                {
                    double next = Opacity - 0.18;
                    if (next <= 0.0) { Opacity = 0.0; t.Stop(); t.Dispose(); Close(); return; }
                    Opacity = next;
                };
                t.Start();
                return;
            }
            base.OnFormClosing(e);
        }

        void KillGame()
        {
            using (Process target = CurrentTarget())
            {
                if (target == null) { Log("No game running."); return; }
                string name = "the game";
                try
                {
                    name = target.ProcessName;
                    target.Kill();
                    _lastPid = 0;
                    _connected = false;
                    SetStatus("not connected", Palette.Muted);
                    Log("Closed " + name + ".");
                }
                catch (Exception e) { Log("Could not close " + name + ": " + e.Message); }
            }
        }

        protected override void OnResize(EventArgs e)
        {
            // borderless maximize would cover the taskbar; clamp to the working area
            // queried by WM_GETMINMAXINFO before the resize lands, so keep it current
            // for the screen we are on even while normal
            MaximizedBounds = Screen.FromControl(this).WorkingArea;
            RoundCorners();
            base.OnResize(e);
        }

        void RoundCorners()
        {
            Region old = Region;
            if (WindowState == FormWindowState.Maximized)
            {
                Region = null;
                if (old != null) old.Dispose();      // Region owns an unmanaged HRGN
                return;
            }
            using (GraphicsPath path = FlatButton.Round(new Rectangle(0, 0, Width, Height), 14))
            {
                Region = new Region(path);
                if (old != null) old.Dispose();
            }
        }

        // ---------------- chrome ----------------

        void BuildStatusBar()
        {
            DoubleBufferedPanel bar = new DoubleBufferedPanel();
            bar.Dock = DockStyle.Bottom;
            bar.Height = 38;
            bar.BackColor = Palette.Panel;
            bar.Paint += delegate (object s, PaintEventArgs e)
            {
                e.Graphics.DrawLine(Palette.BorderPen, 0, 0, bar.Width, 0);
            };

            _status = new StatusPill();
            _status.Left = 14;
            _status.Top = 6;
            _status.Width = 220;
            _status.Set("not connected", Palette.Muted);

            _autoButton = new FlatButton();
            _autoButton.Text = "AUTO CONNECT: ON";
            _autoButton.Left = 250;
            _autoButton.Top = 6;
            _autoButton.Width = 168;
            _autoButton.Height = 26;
            _autoButton.Font = Palette.Small;
            _tt.SetToolTip(_autoButton, "Connect automatically whenever the game is running");
            _autoButton.Click += delegate
            {
                _auto = !_auto;
                _autoButton.Text = "AUTO CONNECT: " + (_auto ? "ON" : "OFF");
                Log(_auto ? "Auto connect on." : "Auto connect off.");
            };

            Label hint = new Label();
            hint.AutoSize = false;
            hint.Text = "keep payload.dll next to this exe";
            hint.ForeColor = Palette.Muted;
            hint.Font = Palette.Small;
            hint.TextAlign = ContentAlignment.MiddleRight;
            hint.Dock = DockStyle.Right;
            hint.Width = 300;

            bar.Controls.Add(_status);
            bar.Controls.Add(_autoButton);
            bar.Controls.Add(hint);
            Controls.Add(bar);
        }

        void BuildSidebar()
        {
            DoubleBufferedPanel side = new DoubleBufferedPanel();
            side.Dock = DockStyle.Left;
            side.Width = 196;
            side.BackColor = Palette.Panel;
            side.Paint += delegate (object s, PaintEventArgs e)
            {
                e.Graphics.DrawLine(Palette.BorderPen, side.Width - 1, 0, side.Width - 1, side.Height);
            };

            Label logo = new Label();
            logo.Text = "OCTANE";
            logo.Font = Palette.Logo;
            logo.ForeColor = Palette.Text;
            logo.Left = 20;
            logo.Top = 18;
            logo.AutoSize = true;

            Label sub = new Label();
            sub.Text = "0.463 executor";
            sub.Font = Palette.Small;
            sub.ForeColor = Palette.Muted;
            sub.Left = 21;
            sub.Top = 44;
            sub.AutoSize = true;

            _navExec = new NavButton("Executor");
            _navExec.Left = 0; _navExec.Top = 86; _navExec.Width = side.Width; _navExec.Selected = true;
            _navScripts = new NavButton("Scripts");
            _navScripts.Left = 0; _navScripts.Top = 122; _navScripts.Width = side.Width;
            _navTools = new NavButton("Advanced");
            _navTools.Left = 0; _navTools.Top = 158; _navTools.Width = side.Width;

            _navExec.Click += delegate { ShowPage(0); };
            _navScripts.Click += delegate { ShowPage(1); };
            _navTools.Click += delegate { ShowPage(2); };

            Label ver = new Label();
            ver.Text = "v1.0";
            ver.Font = Palette.Small;
            ver.ForeColor = Palette.Muted;
            ver.Left = 20;
            ver.AutoSize = true;
            side.Resize += delegate { ver.Top = side.Height - 40; };

            _navBar = new Panel();
            _navBar.Width = 3;
            _navBar.Height = 22;
            _navBar.Left = 0;
            _navBar.Top = _navExec.Top + 7;
            _navBar.BackColor = Palette.Accent;

            side.Controls.Add(logo);
            side.Controls.Add(sub);
            side.Controls.Add(_navExec);
            side.Controls.Add(_navScripts);
            side.Controls.Add(_navTools);
            side.Controls.Add(ver);
            side.Controls.Add(_navBar);
            _navBar.BringToFront();
            Controls.Add(side);
        }

        void BuildContent()
        {
            _content = new DoubleBufferedPanel();
            _content.Dock = DockStyle.Fill;
            _content.BackColor = Palette.Bg;

            _content.Controls.Add(BuildAdvancedPage());
            _content.Controls.Add(BuildScriptsPage());
            _content.Controls.Add(BuildExecutorPage());
            Controls.Add(_content);
        }

        void ShowPage(int index)
        {
            if (_pageExec == null || _pageScripts == null || _pageTools == null) return;
            if (_navExec == null || _navScripts == null || _navTools == null) return;

            Control target = index == 0 ? (Control)_pageExec
                           : index == 1 ? (Control)_pageScripts
                                        : (Control)_pageTools;

            int direction = index == _currentPage ? 0 : (index > _currentPage ? 1 : -1);

            _pageExec.Visible = index == 0;
            _pageScripts.Visible = index == 1;
            _pageTools.Visible = index == 2;

            bool first = _currentPage == -1 || direction == 0;
            _currentPage = index;

            AnimateNav(index, first);

            if (first) { target.Dock = DockStyle.Fill; return; }
            SlideVertical(target, direction);
        }

        // Marshals to the UI thread and tolerates the form closing mid-flight.
        void Ui(Action action)
        {
            if (action == null) return;
            if (IsDisposed || !IsHandleCreated) return;
            try { BeginInvoke((MethodInvoker)delegate { action(); }); }
            catch (ObjectDisposedException) { }     // also an InvalidOperationException
            catch (InvalidOperationException) { }
        }

        static float EaseOut(float t)
        {
            if (t <= 0f) return 0f;
            if (t >= 1f) return 1f;
            float inv = 1f - t;
            return 1f - inv * inv * inv;   // cubic ease-out
        }

        // Slides the accent bar and cross-fades the labels between items.
        void AnimateNav(int index, bool instant)
        {
            if (_navBar == null || _navExec == null) return;

            NavButton[] navs = { _navExec, _navScripts, _navTools };
            int[] tops = { _navExec.Top, _navScripts.Top, _navTools.Top };
            int targetTop = tops[index] + 7;

            float[] from = new float[3];
            for (int i = 0; i < 3; i++) from[i] = navs[i].Highlight;

            if (_navTimer != null) { _navTimer.Stop(); _navTimer.Dispose(); _navTimer = null; }

            if (instant)
            {
                _navBar.Top = targetTop;
                for (int i = 0; i < 3; i++)
                {
                    navs[i].Selected = i == index;
                    navs[i].Highlight = i == index ? 1f : 0f;
                    navs[i].Invalidate();
                }
                return;
            }

            int startTop = _navBar.Top;
            int step = 0;
            const int steps = 10;

            _navTimer = new System.Windows.Forms.Timer();
            _navTimer.Interval = 14;
            _navTimer.Tick += delegate
            {
                step++;
                float e = EaseOut(step / (float)steps);

                _navBar.Top = startTop + (int)Math.Round((targetTop - startTop) * e);

                for (int i = 0; i < 3; i++)
                {
                    float want = i == index ? 1f : 0f;
                    navs[i].Highlight = from[i] + (want - from[i]) * e;
                    navs[i].Invalidate();
                }

                if (step >= steps)
                {
                    _navTimer.Stop();
                    _navTimer.Dispose();
                    _navTimer = null;
                    _navBar.Top = targetTop;
                    for (int i = 0; i < 3; i++)
                    {
                        navs[i].Selected = i == index;
                        navs[i].Highlight = i == index ? 1f : 0f;
                        navs[i].Invalidate();
                    }
                }
            };
            _navTimer.Start();
        }

        // Moves the incoming page along Y: entering from below when moving down the
        // sidebar, from above when moving up. Docking is restored when it lands.
        void SlideVertical(Control page, int direction)
        {
            if (_slideTimer != null) { _slideTimer.Stop(); _slideTimer.Dispose(); _slideTimer = null; }

            Rectangle area = _content.ClientRectangle;
            const int travel = 24;
            int step = 0;

            page.SuspendLayout();
            page.Dock = DockStyle.None;
            page.Bounds = new Rectangle(0, direction * travel, area.Width, area.Height);

            _slideTimer = new System.Windows.Forms.Timer();
            _slideTimer.Interval = 12;
            _slideTimer.Tick += delegate
            {
                step++;
                float eased = EaseOut(step / 6f);
                int offset = (int)Math.Round(direction * travel * (1f - eased));
                Rectangle now = _content.ClientRectangle;   // may have been resized mid-slide
                page.Bounds = new Rectangle(0, offset, now.Width, now.Height);
                if (step >= 6)
                {
                    _slideTimer.Stop();
                    _slideTimer.Dispose();
                    _slideTimer = null;
                    page.Dock = DockStyle.Fill;
                    page.ResumeLayout();
                }
            };
            _slideTimer.Start();
        }

        // ---------------- executor ----------------

        DoubleBufferedPanel BuildExecutorPage()
        {
            _execTable = new BufferedTable();
            _execTable.Dock = DockStyle.Fill;
            _execTable.ColumnCount = 1;
            _execTable.RowCount = 4;
            _execTable.BackColor = Palette.Bg;
            _execTable.Padding = new Padding(12);
            _execTable.RowStyles.Add(new RowStyle(SizeType.Absolute, 44));
            _execTable.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            _execTable.RowStyles.Add(new RowStyle(SizeType.Absolute, 44));
            _execTable.RowStyles.Add(new RowStyle(SizeType.Absolute, 190));

            // --- game row
            DoubleBufferedPanel top = new DoubleBufferedPanel();
            top.Dock = DockStyle.Fill;
            top.BackColor = Palette.Bg;

            Label gameLabel = new Label();
            gameLabel.Text = "Game";
            gameLabel.ForeColor = Palette.Muted;
            gameLabel.Font = Palette.Small;
            gameLabel.Left = 2;
            gameLabel.Top = 10;
            gameLabel.Width = 40;

            _gameBox = new ComboBox();
            _gameBox.Left = 46;
            _gameBox.Top = 4;
            _gameBox.Width = 250;
            _gameBox.DropDownStyle = ComboBoxStyle.DropDownList;
            _gameBox.BackColor = Palette.PanelAlt;
            _gameBox.ForeColor = Palette.Text;
            _gameBox.FlatStyle = FlatStyle.Flat;
            _gameBox.Font = Palette.Body;

            _connectButton = new FlatButton();
            _connectButton.Text = "Connect";
            _connectButton.Left = 306;
            _connectButton.Top = 4;
            _connectButton.Width = 110;
            _connectButton.Height = 30;
            _connectButton.Accent = true;
            _connectButton.Fill = Palette.Accent;
            _tt.SetToolTip(_connectButton, "Inject and attach to the selected game");
            _connectButton.Click += delegate { DoConnect(); };

            FlatButton refresh = Btn("Refresh", 424, 4, 76);
            FlatButton kill = Btn("Kill", 508, 4, 62);
            _tt.SetToolTip(kill, "Close the selected game process");
            kill.Click += delegate { KillGame(); };
            _tt.SetToolTip(refresh, "Look for a running game again");
            refresh.Click += delegate { RefreshGames(); };

            top.Controls.Add(gameLabel);
            top.Controls.Add(_gameBox);
            top.Controls.Add(_connectButton);
            top.Controls.Add(refresh);
            top.Controls.Add(kill);
            _execTable.Controls.Add(top, 0, 0);

            // --- editor with a small header
            DoubleBufferedPanel editWrap = new DoubleBufferedPanel();
            editWrap.Dock = DockStyle.Fill;
            editWrap.BackColor = Palette.Panel;
            editWrap.Padding = new Padding(10, 6, 10, 8);

            Label editHead = new Label();
            editHead.Text = "SCRIPT   -   Ctrl+Enter runs it";
            editHead.Font = Palette.Small;
            editHead.ForeColor = Palette.Muted;
            editHead.Dock = DockStyle.Top;
            editHead.Height = 18;

            _editor = new RichTextBox();
            _editor.Dock = DockStyle.Fill;
            _editor.BorderStyle = BorderStyle.None;
            _editor.BackColor = Palette.Panel;
            _editor.ForeColor = Palette.Text;
            _editor.Font = Palette.Mono;
            _editor.DetectUrls = false;
            _editor.AcceptsTab = false;
            _editor.WordWrap = false;
            _editor.ScrollBars = RichTextBoxScrollBars.Both;
            _editor.Text = "-- write Lua here, then press Ctrl+Enter\nprint(\"hello from Octane\")";
            _editor.KeyDown += delegate (object s, KeyEventArgs e)
            {
                if (e.Control && e.KeyCode == Keys.Enter) { e.SuppressKeyPress = true; DoExecute(); }
                if (e.KeyCode == Keys.Tab)
                {
                    e.SuppressKeyPress = true;
                    _editor.SelectedText = "    ";
                }
            };

            editWrap.Controls.Add(_editor);
            editWrap.Controls.Add(editHead);
            _execTable.Controls.Add(editWrap, 0, 1);

            // --- actions
            DoubleBufferedPanel actions = new DoubleBufferedPanel();
            actions.Dock = DockStyle.Fill;
            actions.BackColor = Palette.Bg;

            _runButton = Btn("RUN", 0, 4, 120);
            FlatButton run = _runButton;
            run.Accent = true;
            run.Fill = Palette.Accent;
            _tt.SetToolTip(run, "Run the script in the game (Ctrl+Enter)");
            FlatButton open = Btn("Open", 128, 4, 90);
            FlatButton save = Btn("Save", 224, 4, 90);
            FlatButton clear = Btn("Clear log", 320, 4, 96);
            FlatButton copy = Btn("Copy", 422, 4, 80);
            copy.Click += delegate
            {
                try { Clipboard.SetText(_out.Text); Log("Copied log to clipboard."); }
                catch (Exception ex) { Log("Clipboard unavailable: " + ex.Message); }
            };
            run.Click += delegate { DoExecute(); };
            open.Click += delegate { OpenScript(); };
            save.Click += delegate { SaveScript(); };
            clear.Click += delegate
            {
                _out.Clear();
                _logLastLine = null;
                _logRepeat = 0;
            };

            actions.Controls.Add(run);
            actions.Controls.Add(open);
            actions.Controls.Add(save);
            actions.Controls.Add(clear);
            actions.Controls.Add(copy);
            _execTable.Controls.Add(actions, 0, 2);

            // --- output
            DoubleBufferedPanel outWrap = new DoubleBufferedPanel();
            outWrap.Dock = DockStyle.Fill;
            outWrap.BackColor = Palette.Panel;
            outWrap.Padding = new Padding(10, 6, 10, 8);

            Label outHead = new Label();
            outHead.Text = "OUTPUT   ·   print() also shows in the game's F9 console";
            outHead.Font = Palette.Small;
            outHead.ForeColor = Palette.Muted;
            outHead.Dock = DockStyle.Top;
            outHead.Height = 18;

            _out = new RichTextBox();
            _out.Dock = DockStyle.Fill;
            _out.BorderStyle = BorderStyle.None;
            _out.ReadOnly = true;
            _out.BackColor = Palette.Panel;
            _out.ForeColor = Palette.Text;
            _out.Font = Palette.Mono;
            _out.DetectUrls = false;
            _out.WordWrap = false;
            _out.ScrollBars = RichTextBoxScrollBars.Vertical;

            outWrap.Controls.Add(_out);
            outWrap.Controls.Add(outHead);
            _execTable.Controls.Add(outWrap, 0, 3);

            _pageExec = Wrap(_execTable);
            return _pageExec;
        }

        static DoubleBufferedPanel Wrap(Control inner)
        {
            DoubleBufferedPanel host = new DoubleBufferedPanel();
            host.Dock = DockStyle.Fill;
            host.BackColor = Palette.Bg;
            inner.Dock = DockStyle.Fill;
            host.Controls.Add(inner);
            return host;
        }

        static FlatButton Btn(string text, int x, int y, int w)
        {
            FlatButton b = new FlatButton();
            b.Text = text;
            b.Left = x;
            b.Top = y;
            b.Width = w;
            b.Height = 30;
            return b;
        }

        // ---------------- scripts ----------------

        DoubleBufferedPanel BuildScriptsPage()
        {
            _pageScripts = new DoubleBufferedPanel();
            _pageScripts.Dock = DockStyle.Fill;
            _pageScripts.BackColor = Palette.Bg;
            _pageScripts.Padding = new Padding(16);

            Label head = new Label();
            head.Text = "SAVED SCRIPTS   -   double-click to open";
            head.Font = Palette.Small;
            head.ForeColor = Palette.Muted;
            head.Dock = DockStyle.Top;
            head.Height = 22;

            ListBox list = new ListBox();
            list.Dock = DockStyle.Fill;
            list.BackColor = Palette.Panel;
            list.ForeColor = Palette.Text;
            list.BorderStyle = BorderStyle.None;
            list.Font = Palette.Mono;
            RefreshScriptList(list);
            list.DoubleClick += delegate
            {
                if (list.SelectedItem == null) return;
                string name = list.SelectedItem.ToString();
                if (name.StartsWith("(")) return;
                string path = Path.Combine(_scriptsDir, name);
                Task.Run(() =>
                {
                    try
                    {
                        string text = File.ReadAllText(path);
                        Ui(delegate
                        {
                            _editor.Text = text;
                            ShowPage(0);
                            Log("Opened " + name);
                        });
                    }
                    catch (Exception e)
                    {
                        Ui(delegate { Log("Could not open: " + e.Message); });
                    }
                });
            };

            DoubleBufferedPanel bar = new DoubleBufferedPanel();
            bar.Dock = DockStyle.Bottom;
            bar.Height = 40;
            bar.BackColor = Palette.Bg;
            FlatButton reload = Btn("Refresh", 0, 5, 90);
            FlatButton folder = Btn("Open folder", 96, 5, 110);
            reload.Click += delegate { RefreshScriptList(list); };
            folder.Click += delegate { Process.Start("explorer.exe", _scriptsDir); };
            bar.Controls.Add(reload);
            bar.Controls.Add(folder);

            _pageScripts.Controls.Add(list);
            _pageScripts.Controls.Add(bar);
            _pageScripts.Controls.Add(head);
            return _pageScripts;
        }

        void RefreshScriptList(ListBox list)
        {
            list.Items.Clear();
            try
            {
                foreach (string f in Directory.GetFiles(_scriptsDir, "*.lua"))
                    list.Items.Add(Path.GetFileName(f));
            }
            catch { }
            if (list.Items.Count == 0) list.Items.Add("(no scripts yet - use Save in the editor)");
        }

        // ---------------- advanced ----------------

        DoubleBufferedPanel BuildAdvancedPage()
        {
            _pageTools = new DoubleBufferedPanel();
            _pageTools.Dock = DockStyle.Fill;
            _pageTools.BackColor = Palette.Bg;
            _pageTools.AutoScroll = true;
            _pageTools.Padding = new Padding(18, 14, 18, 14);

            Label head = new Label();
            head.Text = "ADVANCED";
            head.Font = Palette.Small;
            head.ForeColor = Palette.Muted;
            head.Dock = DockStyle.Top;
            head.Height = 20;

            Label blurb = new Label();
            blurb.Text = "You do not need this for normal use. Connect and Run are enough.";
            blurb.Font = Palette.Body;
            blurb.ForeColor = Palette.Text;
            blurb.Dock = DockStyle.Top;
            blurb.Height = 24;

            Panel body = new DoubleBufferedPanel();
            body.Dock = DockStyle.Fill;
            body.AutoScroll = true;
            body.BackColor = Palette.Bg;
            _advY = 6;

            Section(body, "Connection", "Only if the game restarted or a hook needs removing.");
            Row(body, "Re-attach", "Hooks lua_gettop again and re-captures the Lua state.",
                "Reattach", delegate { DoConnect(); });
            Row(body, "Restore original code", "Undoes the inline hook in the game.",
                "Unhook", delegate { Pipe.SendAsync("UNHOOK", this, r => Log("Unhook: " + r)); });

            Section(body, "Diagnostics", "Checks for when Connect does not work.");
            Row(body, "Hook hit counter", "Samples the hook twice, five seconds apart.",
                "Check", delegate { SampleHits(); });
            Row(body, "Offsets", "Decodes the prologue at each known function address.",
                "Check", delegate { Prologues(); });
            Row(body, "Lua state address", "Shows where the game's lua_State lives.",
                "Show", delegate { Pipe.SendAsync("STATE", this, r => Log("State: " + r)); });

            Section(body, "Experiments", "Unfinished routes. Safe to ignore.");
            Row(body, "Register loadstring", "Needs two RVAs in payload.cfg before it can work.",
                "Try", delegate { Pipe.SendAsync("LOADSTRING", this, r => Log("Loadstring: " + r)); });
            Row(body, "Compile mode", "Bytecode shape used by Run. Only for testing.",
                "0/0", delegate { Pipe.SendAsync("OPT 0 0", this, r => Log("Compile: " + r)); });

            _pageTools.Controls.Add(body);
            _pageTools.Controls.Add(blurb);
            _pageTools.Controls.Add(head);
            return _pageTools;
        }

        int _advY;

        void Section(Panel host, string title, string subtitle)
        {
            _advY += 14;

            Label t = new Label();
            t.Text = title.ToUpperInvariant();
            t.Font = Palette.Small;
            t.ForeColor = Palette.Accent;
            t.Left = 0;
            t.Top = _advY;
            t.AutoSize = true;
            host.Controls.Add(t);
            _advY += 20;

            Label s = new Label();
            s.Text = subtitle;
            s.Font = Palette.Small;
            s.ForeColor = Palette.Muted;
            s.Left = 0;
            s.Top = _advY;
            s.Width = 640;
            host.Controls.Add(s);
            _advY += 26;
        }

        void Row(Panel host, string title, string description, string actionText, Action action)
        {
            FlatButton b = new FlatButton();
            b.Text = actionText;
            b.Left = 0;
            b.Top = _advY;
            b.Width = 96;
            b.Height = 28;
            _tt.SetToolTip(b, description);
            b.Click += delegate { action(); };

            Label l = new Label();
            l.Text = title;
            l.Font = Palette.Body;
            l.ForeColor = Palette.Text;
            l.Left = 108;
            l.Top = _advY + 4;
            l.AutoSize = true;

            Label d = new Label();
            d.Text = description;
            d.Font = Palette.Small;
            d.ForeColor = Palette.Muted;
            d.Left = 108;
            d.Top = _advY + 20;
            d.Width = 620;

            host.Controls.Add(b);
            host.Controls.Add(l);
            host.Controls.Add(d);
            _advY += 46;
        }
        // ---------------- behaviour ----------------

        void RefreshGames()
        {
            _gameBox.Items.Clear();
            List<Process> all = GameProcess.FindAll();
            string first = all.Count > 0 ? all[0].ProcessName : null;
            foreach (Process p in all)
                _gameBox.Items.Add(p.ProcessName + "  (pid " + p.Id + ")");
            GameProcess.DisposeAll(all);          // clears the list, so use `first`
            if (first != null)
            {
                _gameBox.SelectedIndex = 0;
                Log("Found " + first + ".");
            }
            else
            {
                Log("Octane is not running.");
            }
        }

        Process CurrentTarget()
        {
            string text = (_gameBox.Text ?? "").Trim();
            int open = text.IndexOf("(pid ");
            if (open > 0)
            {
                int pid;
                string id = text.Substring(open + 5).TrimEnd(')', ' ');
                if (int.TryParse(id, out pid))
                {
                    try { return Process.GetProcessById(pid); } catch { }
                }
                text = text.Substring(0, open).Trim();   // pid gone: search by name only
            }
            return GameProcess.Find(text);
        }

        // One entry point: if already loaded just re-attach, otherwise inject first.
        void DoConnect()
        {
            // reachable from the Connect button, the auto-tick worker and retries:
            // always run the control updates on the UI thread
            if (InvokeRequired)
            {
                Ui(delegate { DoConnect(); });
                return;
            }
            if (_connecting) return;

            Process target = CurrentTarget();
            if (target == null)
            {
                Log("No game found. Start Octane, then press Connect.");
                SetStatus("no game", Palette.Warn);
                return;
            }

            _connecting = true;
            int pid = target.Id;
            string pname = target.ProcessName;
            try { target.Dispose(); } catch { }   // Process holds a Win32 handle
            _connectButton.Enabled = false;
            _connectButton.Text = "Connecting...";
            SetStatus("connecting...", Palette.Warn);

            new Thread(() =>
            {
                bool ok;
                string detail;
                // the pipe is global: a PONG only means *some* instance answers,
                // so inject unless this is the pid we already loaded into
                if (_connected && _lastPid == pid && Pipe.Send("PING", 500) == "PONG")
                {
                    ok = true;
                    detail = "already loaded";
                }
                else
                {
                    ok = GameProcess.TryInject(pid, _dllPath, out detail);
                    // no sleep: INIT blocks in Connect until the payload is ready
                }

                string init = ok ? Pipe.Send("INIT", 4000) : "FAIL";
                bool connected = ok && init == "OK";

                Ui(delegate
                {
                    if (IsDisposed) return;
                    _connecting = false;
                    _connectButton.Enabled = true;
                    _connectButton.Text = connected ? "Reconnect" : "Connect";
                    if (connected)
                    {
                        _connected = true;
                        _lastPid = pid;        // manual connects must arm the liveness check too
                        SetStatus("connected", Palette.Good);
                        Log("Connected to " + pname + ".");
                    }
                    else
                    {
                        _connected = false;
                        SetStatus("not connected", Palette.Bad);
                        Log("Could not connect (" + detail + ").");
                        // a bitness mismatch never fixes itself: stop retrying this pid
                        if (detail != null && detail.IndexOf("architecture mismatch") >= 0) _lastPid = pid;
                        else _lastPid = 0;
                    }
                });
            }) { IsBackground = true }.Start();
        }

        void DoExecute()
        {
            if (!_connected)
            {
                Log("Not connected. Press Connect first.");
                return;
            }
            if (_busy) { Log("Still running the previous script..."); return; }
            _busy = true;
            if (_runButton != null) { _runButton.Enabled = false; _runButton.Text = "Running..."; }
            SetStatus("running...", Palette.Warn);
            Pipe.SendAsync("EXEC " + Pipe.Encode(_editor.Text), reply =>
            {
                _busy = false;
                Ui(delegate
                {
                    if (!string.IsNullOrEmpty(reply))
                    {
                        string t = reply.Trim();
                        if (t.Length > 0 && t != "OK") Log(t);
                    }
                    if (_runButton != null) { _runButton.Enabled = true; _runButton.Text = "RUN"; }
                    if (reply.StartsWith("ERR"))
                    {
                        _connected = false;
                        SetStatus("not connected", Palette.Bad);
                    }
                    else SetStatus("connected", Palette.Good);
                });
            }, 8000);
        }

        void SampleHits()
        {
            if (_busy) { Log("Busy - the pipe is in use, try again."); return; }
            _busy = true;
            Pipe.SendAsync("HITS", first =>
            {
                Log("Hits: " + first);
                Thread.Sleep(5000);
                Pipe.SendAsync("HITS", second =>
                {
                    Log("Hits: " + second);
                    Log("Change over 5s: " + Delta(first, second));
                    _busy = false;
                });
            });
        }

        static string Delta(string a, string b)
        {
            int i = a.IndexOf("hits=");
            int j = b.IndexOf("hits=");
            if (i < 0 || j < 0) return "?";
            int va, vb;
            int.TryParse(a.Substring(i + 5).Split(' ')[0], out va);
            int.TryParse(b.Substring(j + 5).Split(' ')[0], out vb);
            return (vb - va).ToString();
        }

        void Prologues()
        {
            if (_busy) { Log("Busy - the pipe is in use, try again."); return; }
            _busy = true;

            string[] rvas = { "0xF413C0", "0xF41980", "0xF43EF0", "0xF4C710" };
            int index = 0;
            Action next = null;
            next = delegate
            {
                if (index >= rvas.Length) { _busy = false; return; }
                string rva = rvas[index++];
                Pipe.SendAsync("PROLOGUE rva:" + rva, r =>
                {
                    Log(rva + "  " + r);
                    next();
                });
            };
            next();
        }

        void OpenScript()
        {
            string path;
            using (OpenFileDialog d = new OpenFileDialog())
            {
                d.Filter = "Lua scripts|*.lua;*.txt|All files|*.*";
                if (d.ShowDialog() != DialogResult.OK) return;
                path = d.FileName;
            }
            Task.Run(() =>
            {
                try
                {
                    string text = File.ReadAllText(path);      // disk IO off the UI thread
                    Ui(delegate
                    {
                        _editor.Text = text;
                        Log("Opened " + Path.GetFileName(path));
                    });
                }
                catch (Exception e)
                {
                    Ui(delegate { Log("Could not open: " + e.Message); });
                }
            });
        }

        void SaveScript()
        {
            string path;
            using (SaveFileDialog d = new SaveFileDialog())
            {
                d.Filter = "Lua scripts|*.lua|All files|*.*";
                d.InitialDirectory = _scriptsDir;
                d.FileName = "script.lua";
                if (d.ShowDialog() != DialogResult.OK) return;
                path = d.FileName;
            }
            string body = _editor.Text;
            Task.Run(() =>
            {
                try
                {
                    File.WriteAllText(path, body);
                    Ui(delegate { Log("Saved " + Path.GetFileName(path)); });
                }
                catch (Exception e)
                {
                    Ui(delegate { Log("Could not save: " + e.Message); });
                }
            });
        }

        // The payload prints into a ring buffer; pull it so the console shows its side.
        void PollPayloadLog()
        {
            if (!_connected) return;          // nothing to poll while idle
            if (_busy || _connecting) return; // EXEC/HITS own the pipe; a timeout is not a disconnect
            if (!_payloadHasLog) return;
            if (_polling) return;
            _polling = true;
            Pipe.SendAsync("LOG", reply =>
            {
                _polling = false;
                if (string.IsNullOrEmpty(reply) || reply == "-") return;
                if (reply.StartsWith("ERR"))
                {
                    // a busy pipe also times out, so confirm the game is really gone
                    // (worker thread - no control access, no Process allocation)
                    if (!GameProcess.IsPidAlive(_lastPid))
                    {
                        _connected = false;
                        SetStatus("not connected", Palette.Muted);
                    }
                    return;
                }
                if (reply.IndexOf("unknown command", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    // older payload build: no log channel, stop asking every 700ms
                    _payloadHasLog = false;
                    if (_logPoll != null) _logPoll.Stop();
                    Log("This payload build has no log channel (rebuild + reinject to see its output).");
                    return;
                }
                string[] lines = reply.Replace("\r", "").Split('\n');
                foreach (string line in lines)
                    if (line.Trim().Length > 0) Log(line.TrimEnd());
            }, 400);
        }

        void AutoTick()
        {
            // one auto attempt at a time: an injection can take longer than the tick
            if (_autoBusy || _connecting) return;
            if (_connectButton == null) return;

            // already connected: one cheap handle check instead of a full process snapshot
            if (_connected && _lastPid > 0 && GameProcess.IsPidAlive(_lastPid)) return;

            List<Process> all = GameProcess.FindAll();
            if (all.Count == 0)
            {
                _lastPid = 0;
                if (_connected)
                {
                    _connected = false;
                    SetStatus("not connected", Palette.Muted);
                    Log("Game closed.");
                }
                return;
            }

            if (!_auto) { GameProcess.DisposeAll(all); return; }   // still watch for closure
            if (!_connectButton.Enabled) { GameProcess.DisposeAll(all); return; }

            Process p = all[0];
            int pid = p.Id;
            string pname = p.ProcessName;
            GameProcess.DisposeAll(all);          // ids/names copied out above
            if (pid == _lastPid) return;

            _autoBusy = true;
            Log("Found " + pname + ", connecting...");
            Ui(delegate
            {
                // refresh first so CurrentTarget() has a real entry to read
                RefreshGames();
                _autoBusy = false;
                DoConnect();
            });
        }

        // ---------------- logging ----------------

        void SetStatus(string text, Color color)
        {
            if (InvokeRequired) { Ui(delegate { SetStatus(text, color); }); return; }
            _status.Set(text, color);
        }

        void Log(string line)
        {
            lock (_logLock) { _pending.Append(line).Append('\n'); }
        }

        static Color ColorFor(string line)
        {
            if (line.StartsWith("ERR") || line.IndexOf("fault", StringComparison.OrdinalIgnoreCase) >= 0)
                return Palette.Bad;
            if (line.StartsWith("->") || line.StartsWith("Connected"))
                return Palette.Good;
            if (line.StartsWith("Could not") || line.StartsWith("No game") || line.StartsWith("Octane is not"))
                return Palette.Warn;
            return Palette.Text;
        }

        [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
        struct ScrollPoint { public int X, Y; }

        [System.Runtime.InteropServices.DllImport("user32.dll")]
        static extern IntPtr SendMessage(IntPtr hWnd, int msg, IntPtr wParam, ref ScrollPoint lParam);

        const int EM_GETSCROLLPOS = 0x0400 + 221;
        const int EM_SETSCROLLPOS = 0x0400 + 222;

        [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
        struct ScrollInfo
        {
            public uint cbSize, fMask;
            public int nMin, nMax, nPage, nPos, nTrackPos;
        }

        [System.Runtime.InteropServices.DllImport("user32.dll")]
        static extern bool GetScrollInfo(IntPtr hWnd, int bar, ref ScrollInfo si);

        bool LogAtBottom()
        {
            if (_out == null || _out.TextLength == 0) return true;
            if (!_out.IsHandleCreated) return true;

            // Scrollbar geometry is exact; character geometry lies when the last
            // line ends in blank lines.
            ScrollInfo si = new ScrollInfo();
            si.cbSize = (uint)System.Runtime.InteropServices.Marshal.SizeOf(typeof(ScrollInfo));
            si.fMask = 0x17;                       // SIF_ALL
            if (!GetScrollInfo(_out.Handle, 1, ref si)) return true;   // SB_VERT

            return si.nPos >= si.nMax - si.nPage + 1;
        }

        const int WM_SETREDRAW = 0x000B;

        [System.Runtime.InteropServices.DllImport("user32.dll")]
        static extern IntPtr SendMessage(IntPtr hWnd, int msg, IntPtr wParam, IntPtr lParam);

        // Batches consecutive same-colour lines into one AppendText.
        void QueueRun(StringBuilder run, ref Color runColor, string text, Color color)
        {
            if (run.Length > 0 && !color.Equals(runColor))
            {
                AppendRun(run.ToString(), runColor);
                run.Length = 0;
            }
            runColor = color;
            run.Append(text).Append("\n");
        }

        void AppendRun(string text, Color color)
        {
            _out.SelectionStart = _out.TextLength;
            _out.SelectionColor = color;
            _out.AppendText(text);
        }

        void FlushLog()
        {
            string chunk = null;
            lock (_logLock)
            {
                if (_pending.Length > 0)
                {
                    chunk = _pending.ToString();
                    _pending.Clear();
                }
            }
            if (_out == null || _out.IsDisposed) return;

            // A folded run that has gone quiet still has to be reported. This check
            // must happen before the "nothing pending" return or it never runs.
            bool quietRepeat = chunk == null && _logRepeat > 0 &&
                               unchecked(Environment.TickCount - _logRepeatAt) > 700;
            if (chunk == null && !quietRepeat) return;

            if (_out.TextLength > 300000)
            {
                _out.Clear();
                _logLastLine = null;
                _logRepeat = 0;
            }

            bool stick = LogAtBottom();

            // keep the reader's place: AppendText parks the caret at the end and
            // scrolls on its own, so save scroll + selection and put them back
            int saveSel = _out.SelectionStart;
            int saveLen = _out.SelectionLength;
            ScrollPoint saveScroll = new ScrollPoint();
            bool haveScroll = !stick && _out.IsHandleCreated;
            if (haveScroll) SendMessage(_out.Handle, EM_GETSCROLLPOS, IntPtr.Zero, ref saveScroll);

            _out.SuspendLayout();
            if (_out.IsHandleCreated) SendMessage(_out.Handle, WM_SETREDRAW, IntPtr.Zero, IntPtr.Zero);

            string[] lines = chunk != null ? chunk.Split('\n') : null;
            StringBuilder run = new StringBuilder();
            Color runColor = Color.Empty;

            for (int i = 0; lines != null && i < lines.Length; i++)
            {
                string line = lines[i];
                if (line.Length == 0) continue;

                if (_logLastLine != null && line == _logLastLine)
                {
                    _logRepeat++;      // counted across ticks, not just this chunk
                    _logRepeatAt = Environment.TickCount;
                    continue;
                }
                if (_logRepeat > 0)
                {
                    QueueRun(run, ref runColor, "    ... repeated " + _logRepeat + " more time(s)", Palette.Muted);
                    _logRepeat = 0;
                }
                QueueRun(run, ref runColor, line, ColorFor(line));
                _logLastLine = line;
            }
            if (run.Length > 0) AppendRun(run.ToString(), runColor);

            // a run that stops repeating must still be reported: wait until the
            // stream has been quiet for a moment, then say how many were folded
            if (_logRepeat > 0 && unchecked(Environment.TickCount - _logRepeatAt) > 700)
            {
                AppendRun("    ... repeated " + _logRepeat + " more time(s)\n", Palette.Muted);
                _logRepeat = 0;
            }

            if (_out.IsHandleCreated)
            {
                SendMessage(_out.Handle, WM_SETREDRAW, (IntPtr)1, IntPtr.Zero);
                _out.Invalidate();
            }
            if (stick)
            {
                _out.SelectionStart = _out.TextLength;
                _out.ScrollToCaret();
            }
            else
            {
                if (haveScroll) SendMessage(_out.Handle, EM_SETSCROLLPOS, IntPtr.Zero, ref saveScroll);
                if (saveSel <= _out.TextLength)
                {
                    _out.SelectionStart = saveSel;
                    _out.SelectionLength = Math.Min(saveLen, _out.TextLength - saveSel);
                }
            }
            _out.ResumeLayout();
        }

        protected override void OnFormClosed(FormClosedEventArgs e)
        {
            if (_logTimer != null) { _logTimer.Stop(); _logTimer.Dispose(); }
            if (_autoTimer != null) { _autoTimer.Stop(); _autoTimer.Dispose(); }
            if (_logPoll != null) { _logPoll.Stop(); _logPoll.Dispose(); }
            if (_slideTimer != null) { _slideTimer.Stop(); _slideTimer.Dispose(); }
            if (_navTimer != null) { _navTimer.Stop(); _navTimer.Dispose(); }
            if (_fadeTimer != null) { _fadeTimer.Stop(); _fadeTimer.Dispose(); }
            if (_tt != null) _tt.Dispose();
            Palette.DisposeFonts();
            base.OnFormClosed(e);
        }
    }

    static class Program
    {
        [STAThread]
        static void Main()
        {
            try
            {
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                Application.Run(new MainForm());
            }
            catch (Exception e)
            {
                try
                {
                    File.WriteAllText(
                        Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "crash.txt"), e.ToString());
                }
                catch { }
                throw;
            }
        }
    }
}