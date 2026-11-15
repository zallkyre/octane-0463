// Tiny PE scanner for the 0.463 client. Keeps every lookup under a second so the
// opcode-table work can iterate quickly.
//   pefind.exe <exe> find "8B 04 85 ?? ?? ?? ??"
//   pefind.exe <exe> switch
//   pefind.exe <exe> hex 0xF56DFD 64
//   pefind.exe <exe> rva 0xF56DFD
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;

class Scan
{
    static byte[] d;
    static uint imageBase;
    static readonly List<Sec> secs = new List<Sec>();

    class Sec { public string Name; public uint VA, VSize, Raw, RawSize; }

    static void Main(string[] args)
    {
        if (args.Length < 2) { Usage(); return; }
        d = File.ReadAllBytes(args[0]);
        Parse();

        switch (args[1])
        {
            case "find": Find(args[2]); break;
            case "switch": Switch(); break;
            case "hex": Hex(U(args[2]), int.Parse(args[3])); break;
            case "rva": Console.WriteLine("0x{0:X}", U(args[2]) - imageBase); break;
            case "table": Table(U(args[2]), int.Parse(args[3])); break;
            case "calls": Calls(U(args[2])); break;
            case "func": Func(U(args[2]), int.Parse(args.Length > 3 ? args[3] : "512")); break;
            case "stack": StackScan(U(args[2]), int.Parse(args[3], NumberStyles.HexNumber)); break;
            default: Usage(); break;
        }
    }

    // Lua stack slot is 16 bytes: getters do `add dword [L+0x10], 0x10`,
    // setters do `sub dword [L+0x10], 0x10`. Scan for `83 /0|/5 [reg+0x10], 0x10`.
    static void StackScan(uint va, int len)
    {
        long o = Off(va);
        if (o < 0) { Console.WriteLine("not mapped"); return; }
        string[] regs = { "eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi" };
        int n = 0;
        for (int i = 0; i + 4 <= len; i++)
        {
            if (d[o + i] != 0x83) continue;
            byte m = d[o + i + 1];
            if ((m & 0xC0) != 0x40) continue;          // mod = disp8
            if ((m & 0x07) == 0x04) continue;          // SIB, not a plain register
            if (d[o + i + 2] != 0x10 || d[o + i + 3] != 0x10) continue;
            int reg = (m >> 3) & 7;
            if (reg != 0 && reg != 5) continue;
            n++;
            Console.WriteLine("rva=0x{0:X}  {1} dword [{2}+0x10], 0x10",
                va - imageBase + (uint)i, reg == 0 ? "ADD (push)" : "SUB (pop)", regs[m & 7]);
        }
        Console.WriteLine("{0} stack adjust(s)", n);
    }

    // Walks back from an address to the nearest function prologue (55 8B EC after padding/CC).
    static void Func(uint va, int back)
    {
        long o = Off(va);
        if (o < 0) { Console.WriteLine("not mapped"); return; }
        for (int k = 0; k < back; k++)
        {
            long q = o - k;
            if (q - 1 < 0) break;
            if (d[q] == 0x55 && d[q + 1] == 0x8B && d[q + 2] == 0xEC)
            {
                byte prev = d[q - 1];
                if (prev == 0xCC || prev == 0x90 || prev == 0xC3 || prev == 0x00)
                {
                    Console.WriteLine("entry rva=0x{0:X} (va 0x{1:X}) back={2}","?","?",k);
                    Console.WriteLine("entry va=0x{0:X}", va - (uint)k);
                    return;
                }
            }
        }
        Console.WriteLine("no prologue within {0} bytes", back);
    }

    static void Calls(uint target)
    {
        Sec t = secs.Find(x => x.Name == ".text");
        int hits = 0;
        for (uint i = 0; i + 5 < t.RawSize; i++)
        {
            long o = t.Raw + i;
            if (d[o] != 0xE8) continue;
            uint next = imageBase + t.VA + i + 5;
            int rel = BitConverter.ToInt32(d, (int)o + 1);
            if ((uint)(next + rel) != target) continue;
            hits++;
            Console.WriteLine("call site rva=0x{0:X}", t.VA + i);
        }
        Console.WriteLine("{0} call(s) to 0x{1:X}", hits, target);
    }

    static void Table(uint va, int n)
    {
        var v = new uint[n];
        for (int i = 0; i < n; i++) v[i] = U32(Off(va + (uint)(i * 4)));
        uint min = uint.MaxValue, max = 0;
        int mono = 0;
        for (int i = 0; i < n; i++)
        {
            if (v[i] < min) min = v[i];
            if (v[i] > max) max = v[i];
            if (i > 0 && v[i] > v[i - 1]) mono++;
        }
        Console.WriteLine("entries={0} min=0x{1:X} max=0x{2:X} span=0x{3:X} monotonic={4}/{5}",
            n, min, max, max - min, mono, n - 1);
        for (int i = 0; i < Math.Min(n, 12); i++)
            Console.WriteLine("  [{0}] 0x{1:X}", i, v[i]);
    }

    static void Usage()
    {
        Console.WriteLine("usage: pefind <exe> find \"AA BB ?? ...\" | switch | hex <va> <n> | rva <va> | table <va> <n>");
    }

    static uint U(string s)
    {
        s = s.Trim();
        if (s.StartsWith("0x", StringComparison.OrdinalIgnoreCase)) s = s.Substring(2);
        return uint.Parse(s, NumberStyles.HexNumber);
    }

    static void Parse()
    {
        int e = BitConverter.ToInt32(d, 0x3C);
        int n = BitConverter.ToUInt16(d, e + 6);
        int optSize = BitConverter.ToUInt16(d, e + 20);
        int opt = e + 24;
        imageBase = BitConverter.ToUInt32(d, opt + 28);
        int s = opt + optSize;
        for (int i = 0; i < n; i++)
        {
            int o = s + i * 40;
            secs.Add(new Sec
            {
                Name = System.Text.Encoding.ASCII.GetString(d, o, 8).TrimEnd('\0'),
                VSize = BitConverter.ToUInt32(d, o + 8),
                VA = BitConverter.ToUInt32(d, o + 12),
                RawSize = BitConverter.ToUInt32(d, o + 16),
                Raw = BitConverter.ToUInt32(d, o + 20)
            });
        }
        Sec t = secs.Find(x => x.Name == ".text");
        Console.WriteLine("imageBase=0x{0:X} .text VA=0x{1:X} size=0x{2:X}", imageBase, t.VA, t.VSize);
    }

    static Sec For(uint va)
    {
        if (va < imageBase) return null;
        uint rva = va - imageBase;
        foreach (Sec s in secs)
            if (rva >= s.VA && rva < s.VA + Math.Max(s.VSize, s.RawSize)) return s;
        return null;
    }

    static long Off(uint va)
    {
        Sec s = For(va);
        if (s == null) return -1;
        return (long)s.Raw + ((long)va - imageBase - s.VA);
    }

    static uint U32(long off)
    {
        if (off < 0 || off + 4 > d.Length) return 0;
        return BitConverter.ToUInt32(d, (int)off);
    }

    static void Hex(uint va, int n)
    {
        long off = Off(va);
        if (off < 0) { Console.WriteLine("not mapped"); return; }
        for (int i = 0; i < n; i += 16)
        {
            Console.Write("0x{0:X}: ", va + (uint)i);
            for (int j = 0; j < 16 && i + j < n; j++)
                Console.Write("{0:X2} ", d[off + i + j]);
            Console.WriteLine();
        }
    }

    // "AA BB ?? CC" -> bytes + wildcards
    static void ParsePattern(string p, out byte[] pat, out bool[] wild)
    {
        string[] parts = p.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        pat = new byte[parts.Length];
        wild = new bool[parts.Length];
        for (int i = 0; i < parts.Length; i++)
        {
            if (parts[i] == "??" || parts[i] == "?") { wild[i] = true; continue; }
            pat[i] = byte.Parse(parts[i], NumberStyles.HexNumber);
        }
    }

    static void Find(string text)
    {
        byte[] pat; bool[] wild;
        ParsePattern(text, out pat, out wild);
        Sec t = secs.Find(x => x.Name == ".text");
        int hits = 0;
        for (uint i = 0; i + pat.Length <= t.RawSize; i++)
        {
            bool ok = true;
            for (int j = 0; j < pat.Length; j++)
            {
                if (wild[j]) continue;
                if (d[t.Raw + i + j] != pat[j]) { ok = false; break; }
            }
            if (!ok) continue;
            hits++;
            Console.WriteLine("rva=0x{0:X}", t.VA + i);
            if (hits >= 40) { Console.WriteLine("..."); break; }
        }
        Console.WriteLine("{0} hit(s)", hits);
    }

    // switch dispatch: FF 24 85 <table>  (jmp [eax*4+abs]) and 8B 04 85 <table> ... FF E0
    static void Switch()
    {
        Sec t = secs.Find(x => x.Name == ".text");
        uint lo = imageBase + t.VA, hi = lo + t.VSize;
        var rows = new List<Tuple<uint, uint, int>>();

        for (uint i = 0; i + 8 < t.RawSize; i++)
        {
            long o = t.Raw + i;
            // jmp/mov eax,[reg*4 + disp32]: modrm 0x24 (rm=SIB), SIB base=101 (disp32), index != esp
            // FF 24 <sib> disp32 (jmp [reg*4+disp]) or 8B 04 <sib> disp32 (mov eax,[reg*4+disp])
            bool jmpForm = d[o] == 0xFF && d[o + 1] == 0x24;
            bool movForm = d[o] == 0x8B && d[o + 1] == 0x04;
            if (!jmpForm && !movForm) continue;
            byte sib = d[o + 2];
            if ((sib & 0x07) != 0x05) continue;      // base = disp32
            if (((sib >> 3) & 0x07) == 0x04) continue; // index = esp is invalid

            uint tbl = U32(o + 3);
            int n = 0;
            while (n < 512)
            {
                uint p = U32(Off(tbl + (uint)(n * 4)));
                if (p < lo || p >= hi) break;
                n++;
            }
            if (n >= 2) rows.Add(Tuple.Create(t.VA + i, tbl, n));
        }

        rows.Sort((a, b) => b.Item3.CompareTo(a.Item3));
        Console.WriteLine("{0} candidate dispatch tables", rows.Count);
        foreach (var r in rows)
            Console.WriteLine("  site rva=0x{0:X} table VA=0x{1:X} entries={2}", r.Item1, r.Item2, r.Item3);
    }
}
