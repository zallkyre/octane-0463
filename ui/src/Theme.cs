using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace Octane.UI
{
    // Central palette + font set. One place to retheme everything.
    public static class Dpi
    {
        public static int Scale(Control c, int px)
        {
            if (c == null) return px;
            return (int)Math.Round(px * (c.DeviceDpi / 96.0));
        }
    }

    public static class Palette
    {
        // Fonts are process-wide; released once when the app closes.
        public static void DisposeFonts()
        {
            Body.Dispose(); BodyBold.Dispose(); Small.Dispose(); Mono.Dispose(); Logo.Dispose();
            PanelBrush.Dispose(); PanelAltBrush.Dispose(); AccentBrush.Dispose();
            TextBrush.Dispose(); MutedBrush.Dispose(); BorderPen.Dispose(); AccentPen.Dispose();
            BadBrush.Dispose();
        }

        public static readonly Color Bg = Color.FromArgb(13, 13, 16);
        public static readonly Color Panel = Color.FromArgb(20, 20, 24);
        public static readonly Color PanelAlt = Color.FromArgb(26, 26, 31);
        public static readonly Color Border = Color.FromArgb(38, 38, 45);
        public static readonly Color Text = Color.FromArgb(232, 232, 238);
        public static readonly Color Muted = Color.FromArgb(138, 138, 150);
        public static readonly Color Accent = Color.FromArgb(124, 92, 255);
        public static readonly Color AccentDim = Color.FromArgb(74, 56, 160);
        public static readonly Color Good = Color.FromArgb(80, 220, 160);
        public static readonly Color Warn = Color.FromArgb(240, 190, 90);
        public static readonly Color Bad = Color.FromArgb(240, 100, 100);

        public static readonly Font Body = new Font("Segoe UI", 9.5f);
        public static readonly Font BodyBold = new Font("Segoe UI", 9.5f, FontStyle.Bold);
        public static readonly Font Small = new Font("Segoe UI", 8.5f);
        public static readonly Font Mono = new Font("Consolas", 10f);
        public static readonly Font Logo = new Font("Segoe UI", 13f, FontStyle.Bold);

        // Cached GDI+ objects for the hot paints (hover, nav animation, title bar).
        // Shared across controls; the UI is single-threaded.
        public static readonly SolidBrush PanelBrush = new SolidBrush(Panel);
        public static readonly SolidBrush PanelAltBrush = new SolidBrush(PanelAlt);
        public static readonly SolidBrush AccentBrush = new SolidBrush(Accent);
        public static readonly SolidBrush TextBrush = new SolidBrush(Text);
        public static readonly SolidBrush MutedBrush = new SolidBrush(Muted);
        public static readonly Pen BorderPen = new Pen(Border);
        public static readonly Pen AccentPen = new Pen(Accent);
        public static readonly SolidBrush BadBrush = new SolidBrush(Bad);
    }

    public class BufferedTable : TableLayoutPanel
    {
        public BufferedTable() { DoubleBuffered = true; }
    }

    public class DoubleBufferedPanel : Panel
    {
        public DoubleBufferedPanel()
        {
            DoubleBuffered = true;
            ResizeRedraw = true;
        }
    }

    // Flat, rounded, hover-aware button. Hand-painted so it stays crisp.
    public class FlatButton : Control
    {
        public Color Fill = Palette.PanelAlt;
        public Color Hover = Color.FromArgb(38, 38, 45);
        public Color TextColor = Palette.Text;
        public int Radius = 7;
        public bool Accent;

        bool _hover;

        public FlatButton()
        {
            SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer |
                     ControlStyles.UserPaint | ControlStyles.ResizeRedraw, true);
            Cursor = Cursors.Hand;
            Font = Palette.Body;
            Height = 30;
        }

        protected override void OnMouseEnter(EventArgs e) { _hover = true; Invalidate(); base.OnMouseEnter(e); }
        protected override void OnMouseLeave(EventArgs e) { _hover = false; Invalidate(); base.OnMouseLeave(e); }
        protected override void OnEnabledChanged(EventArgs e) { Invalidate(); base.OnEnabledChanged(e); }
        protected override void OnTextChanged(EventArgs e) { Invalidate(); base.OnTextChanged(e); }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.SmoothingMode = SmoothingMode.AntiAlias;

            Color baseFill = Accent ? Palette.Accent : Fill;
            if (!Enabled) baseFill = Palette.Panel;
            else if (_hover) baseFill = Accent ? Blend(Palette.Accent, Color.White, 0.15f) : Hover;

            using (GraphicsPath path = Round(new Rectangle(0, 0, Width - 1, Height - 1), Radius))
            using (SolidBrush b = new SolidBrush(baseFill))
            {
                g.FillPath(b, path);
                if (!Accent) g.DrawPath(Palette.BorderPen, path);
            }

            TextRenderer.DrawText(g, Text, Font, ClientRectangle,
                Enabled ? TextColor : Palette.Muted,
                TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter |
                TextFormatFlags.EndEllipsis);
        }

        public static GraphicsPath Round(Rectangle r, int radius)
        {
            // inset by half a pixel: anti-aliased strokes otherwise leave a 1px fringe
            return Round(new RectangleF(r.X + 0.5f, r.Y + 0.5f, r.Width - 1f, r.Height - 1f), radius);
        }

        public static GraphicsPath Round(RectangleF r, int radius)
        {
            GraphicsPath p = new GraphicsPath();
            float d = radius * 2f;
            if (d <= 1f) { p.AddRectangle(r); return p; }
            p.AddArc(r.X, r.Y, d, d, 180, 90);
            p.AddArc(r.Right - d, r.Y, d, d, 270, 90);
            p.AddArc(r.Right - d, r.Bottom - d, d, d, 0, 90);
            p.AddArc(r.X, r.Bottom - d, d, d, 90, 90);
            p.CloseFigure();
            return p;
        }

        public static Color Blend(Color a, Color b, float t)
        {
            return Color.FromArgb(
                (int)(a.R + (b.R - a.R) * t),
                (int)(a.G + (b.G - a.G) * t),
                (int)(a.B + (b.B - a.B) * t));
        }
    }

    // Small status chip: dot + text, colour driven by state.
    public class StatusPill : Control
    {
        Color _dot = Palette.Muted;
        string _label = "idle";

        public StatusPill()
        {
            SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer |
                     ControlStyles.UserPaint | ControlStyles.ResizeRedraw, true);
            Height = 26;
            Font = Palette.Small;
        }

        public void Set(string text, Color dot)
        {
            _label = text;
            _dot = dot;
            Invalidate();
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.SmoothingMode = SmoothingMode.AntiAlias;
            using (GraphicsPath path = FlatButton.Round(new Rectangle(0, 0, Width - 1, Height - 1), 12))
            g.FillPath(Palette.PanelAltBrush, path);

            using (SolidBrush dot = new SolidBrush(_dot))
                g.FillEllipse(dot, 10, Height / 2 - 4, 8, 8);

            TextRenderer.DrawText(g, _label, Font,
                new Rectangle(26, 0, Width - 30, Height), Palette.Text,
                TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis);
        }
    }

    // Borderless draggable title bar with min/close.
    public class TitleBar : Control
    {
        [DllImport("user32.dll")] static extern bool ReleaseCapture();
        [DllImport("user32.dll")] static extern IntPtr SendMessage(IntPtr hWnd, int msg, IntPtr w, IntPtr l);
        const int WM_NCLBUTTONDOWN = 0xA1;
        const int HT_CAPTION = 0x2;

        readonly Form _form;
        int _hot = 0; // 1 min, 2 close

        public TitleBar(Form form, string title)
        {
            _form = form;
            Text = title;
            Height = 40;
            Dock = DockStyle.Top;
            SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer |
                     ControlStyles.UserPaint | ControlStyles.ResizeRedraw, true);
        }

        int ButtonWidth { get { return Dpi.Scale(this, 46); } }

        protected override void OnMouseDown(MouseEventArgs e)
        {
            base.OnMouseDown(e);
            if (e.Button != MouseButtons.Left || e.Y > Height) return;
            if (e.X > Width - ButtonWidth * 2) return; // buttons handle their own clicks
            ReleaseCapture();
            SendMessage(_form.Handle, WM_NCLBUTTONDOWN, (IntPtr)HT_CAPTION, IntPtr.Zero);
        }

        protected override void OnMouseMove(MouseEventArgs e)
        {
            base.OnMouseMove(e);
            int bw = ButtonWidth;
            int hot = e.X > Width - bw ? 2 : (e.X > Width - bw * 2 ? 1 : 0);
            if (hot != _hot) { _hot = hot; Invalidate(); }
        }

        protected override void OnMouseLeave(EventArgs e)
        {
            _hot = 0;
            Invalidate();
            base.OnMouseLeave(e);
        }

        protected override void OnMouseClick(MouseEventArgs e)
        {
            base.OnMouseClick(e);
            if (e.Button != MouseButtons.Left) return;   // right/middle must not fire these
            int bw = ButtonWidth;
            if (e.Clicks == 2 && e.X <= Width - bw * 2)
            {
                _form.WindowState = _form.WindowState == FormWindowState.Maximized
                    ? FormWindowState.Normal : FormWindowState.Maximized;
                return;
            }
            if (e.X > Width - bw) _form.Close();
            else if (e.X > Width - bw * 2) _form.WindowState = FormWindowState.Minimized;
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            // subtle violet wash instead of a flat bar
            using (LinearGradientBrush bg = new LinearGradientBrush(
                       new Rectangle(0, 0, Math.Max(1, Width), Height),
                       Color.FromArgb(26, 20, 40), Palette.Bg, 90f))
                g.FillRectangle(bg, 0, 0, Width, Height);

            using (SolidBrush glow = new SolidBrush(Color.FromArgb(60, Palette.Accent)))
                g.FillEllipse(glow, 8, Height / 2 - 11, 22, 22);
            g.FillEllipse(Palette.AccentBrush, 14, Height / 2 - 5, 10, 10);

            TextRenderer.DrawText(g, Text, Palette.BodyBold,
                new Rectangle(32, 0, Width - 140, Height), Palette.Text,
                TextFormatFlags.VerticalCenter);

            // window controls
            int bw = ButtonWidth;
            int midY = Height / 2;
            int glyph = Dpi.Scale(this, 6);

            Color minC = _hot == 1 ? Palette.Text : Palette.Muted;
            Color closeC = _hot == 2 ? Color.White : Palette.Muted;
            if (_hot == 2)
                g.FillRectangle(Palette.BadBrush, Width - bw, 0, bw, Height);

            int minCx = Width - bw - bw / 2;
            using (Pen p = new Pen(minC, Math.Max(1f, Dpi.Scale(this, 1))))
                g.DrawLine(p, minCx - glyph, midY, minCx + glyph, midY);

            int closeCx = Width - bw / 2;
            using (Pen p = new Pen(closeC, Math.Max(1.4f, Dpi.Scale(this, 2) * 0.8f)))
            {
                g.DrawLine(p, closeCx - glyph, midY - glyph, closeCx + glyph, midY + glyph);
                g.DrawLine(p, closeCx + glyph, midY - glyph, closeCx - glyph, midY + glyph);
            }

            g.DrawLine(Palette.BorderPen, 0, Height - 1, Width, Height - 1);
        }
    }

    // Sidebar nav entry. Highlight is animated by the form (0..1) so selection
    // glides between items instead of snapping.
    public class NavButton : Control
    {
        public bool Selected;
        public float Highlight;
        bool _hover;

        public NavButton(string text)
        {
            Text = text;
            Height = 36;
            Font = Palette.Body;
            SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer |
                     ControlStyles.UserPaint | ControlStyles.ResizeRedraw, true);
            Cursor = Cursors.Hand;
        }

        protected override void OnMouseEnter(EventArgs e) { _hover = true; Invalidate(); base.OnMouseEnter(e); }
        protected override void OnMouseLeave(EventArgs e) { _hover = false; Invalidate(); base.OnMouseLeave(e); }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.Clear(Palette.Panel);

            float h = Math.Max(0f, Math.Min(1f, Highlight));
            if (h > 0.01f)
            {
                using (SolidBrush b = new SolidBrush(FlatButton.Blend(Palette.Panel, Palette.PanelAlt, h)))
                    g.FillRectangle(b, 0, 0, Width, Height);
            }
            else if (_hover)
            {
                using (SolidBrush b = new SolidBrush(Color.FromArgb(24, 24, 29)))
                    g.FillRectangle(b, 0, 0, Width, Height);
            }

            Color text = FlatButton.Blend(Palette.Muted, Palette.Text, h);
            TextRenderer.DrawText(g, Text, h > 0.5f ? Palette.BodyBold : Palette.Body,
                new Rectangle(20, 0, Width - 24, Height), text,
                TextFormatFlags.VerticalCenter);
        }
    }
}
