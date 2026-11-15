using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Octane.UI
{
    // Thin wrapper over the payload pipe. Never throws and never blocks forever.
    public static class Pipe
    {
        public const string Name = "octane_exec";
        const string Frame = "b64:";

        public static string Send(string command, int timeoutMs = 2500)
        {
            try
            {
                // Asynchronous: overlapped I/O means disposing the stream cancels a
                // pending read instead of deadlocking inside CloseHandle.
                using (NamedPipeClientStream pipe =
                       new NamedPipeClientStream(".", Name, PipeDirection.InOut, PipeOptions.Asynchronous))
                {
                    pipe.Connect(timeoutMs);

                    byte[] bytes = Encoding.UTF8.GetBytes(command + "\n");
                    pipe.Write(bytes, 0, bytes.Length);
                    pipe.Flush();

                    using (StreamReader reader = new StreamReader(pipe, Encoding.UTF8))
                    {
                        Task<string> read = reader.ReadToEndAsync();
                        read.ContinueWith(t => { GC.KeepAlive(t.Exception); },
                                          TaskContinuationOptions.OnlyOnFaulted);

                        if (!read.Wait(timeoutMs)) return "ERR timeout waiting for reply";
                        return Decode(read.Result);
                    }
                }
            }
            catch (Exception e)
            {
                return "ERR " + e.Message;
            }
        }

        public static void SendAsync(string command, Action<string> done, int timeoutMs = 2500)
        {
            Task.Run(() =>
            {
                string reply = Send(command, timeoutMs);
                if (done != null) done(reply);
            });
        }

        // UI-safe: callback always runs on the form's thread.
        public static void SendAsync(string command, Control ui, Action<string> done,
                                     int timeoutMs = 2500)
        {
            Task.Run(() =>
            {
                string reply = Send(command, timeoutMs);
                if (done == null) return;
                if (ui == null || ui.IsDisposed || !ui.IsHandleCreated) return;
                try { ui.BeginInvoke((MethodInvoker)delegate { done(reply); }); }
                catch (ObjectDisposedException) { }
                catch (InvalidOperationException) { }
            });
        }

        public static string Encode(string text)
        {
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(text));
        }

        // Replies are framed "b64:<base64>". A bare reply is taken as plaintext,
        // which keeps older payload builds working.
        public static string Decode(string text)
        {
            if (text == null) return "";
            string body = text.Trim();

            if (body.StartsWith(Frame, StringComparison.Ordinal))
                return FromBase64(body.Substring(Frame.Length)) ?? "";   // never null

            // Legacy payload: base64, but "PONG"/"FAIL" are also valid base64 and
            // would decode to mojibake, so only accept clean UTF-8 round-trips.
            string decoded = FromBase64(body);
            if (decoded == null) return body;
            string reencoded = Convert.ToBase64String(Encoding.UTF8.GetBytes(decoded)).TrimEnd('=');
            if (reencoded == body.TrimEnd('=') && decoded.IndexOf('\uFFFD') < 0) return decoded;
            return body;
        }

        static string FromBase64(string s)
        {
            try { return Encoding.UTF8.GetString(Convert.FromBase64String(s)); }
            catch { return null; }
        }
    }
}
