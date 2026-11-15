# Dump a live 32-bit process image to a PE that a disassembler can open.
# The on-disk OctanePlayer.exe is VMProtect-packed; its sections in memory are
# the real, unpacked code. This rebuilds a file with VA-aligned raw sections so
# RVA == file offset, matching what pefind.exe expects.
#
#   powershell -File tools\dump-live-module.ps1 [-Process OctanePlayer] [-Out path]
param(
    [string]$Process = 'OctanePlayer',
    [string]$Out = "$env:TEMP\Octane_live.exe"
)
$ErrorActionPreference = 'Stop'

$p = Get-Process -Name $Process -ErrorAction Stop | Select-Object -First 1
$pidTarget = $p.Id

Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices;
public static class ReaDump {
  [DllImport("kernel32.dll", SetLastError=true)] public static extern IntPtr OpenProcess(int a,bool b,int p);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool ReadProcessMemory(IntPtr h,IntPtr a,byte[] b,int s,out IntPtr r);
  [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
}
'@

$h = [ReaDump]::OpenProcess(0x0410, $false, $pidTarget)   # QUERY_INFORMATION | VM_READ
if ($h -eq [IntPtr]::Zero) { throw "OpenProcess failed" }

function ReadChunk([uint32]$addr, [uint32]$size) {
    $dst = New-Object byte[] $size
    $off = 0
    while ($off -lt $size) {
        $n = [Math]::Min([uint32]0x1000, $size - $off)
        $tmp = New-Object byte[] $n
        $r = [IntPtr]::Zero
        if ([ReaDump]::ReadProcessMemory($h, [IntPtr][int64]($addr + $off), $tmp, $n, [ref]$r)) {
            [Array]::Copy($tmp, 0, $dst, $off, $n)
        } elseif ([int64]$r -gt 0 -and [int64]$r -le $n) {
            [Array]::Copy($tmp, 0, $dst, $off, [int]$r)
        }
        $off += $n
    }
    return ,$dst
}

# Locate the main module base via the PE header at a candidate. Use the process
# main module base from Toolhelp is unavailable from 64-bit PS; scan down from a
# few likely bases is unsafe, so use the known load rule: main exe is the first
# module and on x86 32-bit WOW64 it is typically 0x400000 (observed for Octane).
# Read the DOS header there and validate; else fail loudly.
$base = [uint32]0x400000
$hdr = ReadChunk $base 0x1000
if ([BitConverter]::ToUInt16($hdr, 0) -ne 0x5A4D) { throw "no MZ at 0x400000; pass -Base" }

$e = [BitConverter]::ToInt32($hdr, 0x3C)
if ([BitConverter]::ToUInt32($hdr, $e) -ne 0x00004550) { throw "no PE at e_lfanew" }
$numsec  = [BitConverter]::ToUInt16($hdr, $e + 6)
$optSize = [BitConverter]::ToUInt16($hdr, $e + 20)
$opt     = $e + 24
$sizeOfImage   = [BitConverter]::ToUInt32($hdr, $opt + 0x38)
$sizeOfHeaders = [BitConverter]::ToUInt32($hdr, $opt + 0x3C)
$secTab  = $e + 24 + $optSize

$kAlign = 0x1000
function RoundUp([uint32]$v) { return [uint32](($v + $kAlign - 1) -band (-bnot ($kAlign - 1))) }

$secs = @()
for ($i = 0; $i -lt $numsec; $i++) {
    $o = $secTab + $i * 40
    $secs += [pscustomobject]@{
        off  = $o
        va   = [BitConverter]::ToUInt32($hdr, $o + 12)
        vs   = [BitConverter]::ToUInt32($hdr, $o + 8)
        name = [Text.Encoding]::ASCII.GetString($hdr, $o, 8).Trim([char]0)
    }
}

$headers = RoundUp $sizeOfHeaders
$total = $headers
foreach ($s in $secs) { $total += (RoundUp $s.vs) }

$img = New-Object byte[] $total
[Array]::Copy($hdr, 0, $img, 0, [Math]::Min([int]$sizeOfHeaders, $hdr.Length))
[BitConverter]::GetBytes([uint32]$kAlign).CopyTo($img, $opt + 0x24)     # FileAlignment
[BitConverter]::GetBytes([uint32]$headers).CopyTo($img, $opt + 0x3C)    # SizeOfHeaders

$ptr = [uint32]$headers
foreach ($s in $secs) {
    $raw = RoundUp $s.vs
    if ($s.vs -gt 0) {
        $d = ReadChunk ([uint32]($base + $s.va)) $s.vs
        [Array]::Copy($d, 0, $img, $ptr, $s.vs)
    }
    [BitConverter]::GetBytes([uint32]$ptr).CopyTo($img, $s.off + 20)
    [BitConverter]::GetBytes([uint32]$raw).CopyTo($img, $s.off + 16)
    $ptr += $raw
}

[ReaDump]::CloseHandle($h) | Out-Null
[IO.File]::WriteAllBytes($Out, $img)
Write-Output ("wrote {0} bytes={1} imageSize=0x{2:X} sections={3}" -f $Out, $total, $sizeOfImage, $numsec)
$secs | ForEach-Object { "  {0,-8} va=0x{1:X} vs=0x{2:X}" -f $_.name, $_.va, $_.vs }
