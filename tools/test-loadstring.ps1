# One-command check for the moment the client is running again:
#   powershell -File tools\test-loadstring.ps1
# Injects the current payload, attaches, and probes the globals table for
# `loadstring`. Prints whether the host exposes it.
param(
    [string]$Dll = "C:\Users\zallkyre _3\Desktop\injector-base\ui\payload.dll",
    [string]$Injector = "C:\Users\zallkyre _3\Desktop\injector-base\build32\bin\injector.exe",
    [string]$Seed = "AQABAAAAAQJBAAAAFgABAAAAAAAAAA=="   # 'return' bytecode, opt0/dbg0
)

$ErrorActionPreference = "Stop"

function Send([string]$cmd, [int]$ms = 1500) {
    try {
        $p = New-Object IO.Pipes.NamedPipeClientStream(".", "octane_exec", [IO.Pipes.PipeDirection]::InOut)
        $p.Connect($ms)
        $b = [Text.Encoding]::ASCII.GetBytes($cmd + "`n")
        $p.Write($b, 0, $b.Length); $p.Flush()
        $r = New-Object IO.StreamReader($p, [Text.Encoding]::ASCII)
        $s = $r.ReadToEnd(); $r.Dispose(); $p.Dispose()
        try { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s)) } catch { $s }
    } catch { "ERR " + $_.Exception.Message }
}

$proc = Get-Process -Name OctanePlayer -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $proc) { throw "OctanePlayer is not running" }
Write-Host "client pid=$($proc.Id)"

if ((Send "PING" 400) -ne "PONG") {
    & $Injector $proc.Id $Dll | ForEach-Object { Write-Host $_ }
    Start-Sleep -Seconds 3
    if ((Send "PING" 800) -ne "PONG") { throw "payload did not answer after injection" }
}

Write-Host ("INIT:   " + (Send "INIT"))
for ($i = 0; $i -lt 12; $i++) {
    if ((Send "STATUS" 600) -eq "attached") { break }
    Start-Sleep -Seconds 1
}
Write-Host ("STATUS: " + (Send "STATUS"))

$payload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("loadstring|" + $Seed))
Write-Host "--- probing globals for 'loadstring' ---"
Write-Host (Send ("FIELD " + $payload) 3000)
Write-Host ""
Write-Host "delta +1 with tt=0x106 => loadstring exists and is callable (executor path is viable)"
Write-Host "delta  0 or -1            => candidate is a setter, or the name is absent"
