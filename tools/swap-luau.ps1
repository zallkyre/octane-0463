# Swap the vendored Luau for another revision and rebuild.
#
#   powershell -File tools\swap-luau.ps1 -Source "C:\path\to\luau"
#
# -Source may be a Luau source root (containing Ast\, Compiler\, VM\) or a .zip.
# Prints the candidate's LBC_VERSION before touching anything, keeps a backup,
# then rebuilds both architectures.
param(
    [Parameter(Mandatory = $true)][string]$Source,
    [switch]$NoBuild
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$dest = Join-Path $root "third_party\luau"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Fail($msg) { Write-Host "[swap] ERROR: $msg" -ForegroundColor Red; exit 1 }

function Check-Tree($path) {
    $need = @(
        "Ast\include\Luau\Ast.h",
        "Compiler\include\Luau\Bytecode.h",
        "Compiler\src\BytecodeBuilder.cpp",
        "VM\src\lvmload.cpp"
    )
    foreach ($n in $need) {
        if (-not (Test-Path (Join-Path $path $n))) { return "missing $n" }
    }
    return $null
}

$work = $Source
if ($Source -like "*.zip") {
    if (-not (Test-Path $Source)) { Fail "zip not found: $Source" }
    $work = Join-Path $env:TEMP ("luau-swap-" + $stamp)
    Expand-Archive -LiteralPath $Source -DestinationPath $work -Force
    # a GitHub zip has a single top folder
    $dirs = Get-ChildItem $work -Directory
    if ($dirs.Count -eq 1) { $work = $dirs[0].FullName }
}

# Accept a repo root that nests the sources under a subfolder.
if (Check-Tree $work) {
    $cand = Get-ChildItem $work -Directory -Recurse -Depth 2 |
            Where-Object { -not (Check-Tree $_.FullName) } |
            Select-Object -First 1
    if ($cand) { $work = $cand.FullName }
}
$problem = Check-Tree $work
if ($problem) { Fail "not a Luau source tree ($problem): $work" }

$bytecode = Join-Path $work "Compiler\include\Luau\Bytecode.h"
$lbc = (Select-String -Path $bytecode -Pattern "LBC_VERSION\s*=\s*(\d+)").Matches.Groups[1].Value
$ops = (Select-String -Path $bytecode -Pattern "LOP__COUNT").Count
Write-Host "[swap] candidate : $work"
Write-Host "[swap] LBC_VERSION: $lbc"
Write-Host "[swap] opcode list present: $([bool]$ops)"

if ($lbc -ne "1") {
    Write-Host "[swap] WARNING: the client checks 'cmp al,1', so a non-1 version cannot load." -ForegroundColor Yellow
}

$backup = "$dest.old-$stamp"
if (Test-Path $dest) {
    Move-Item -LiteralPath $dest -Destination $backup
    Write-Host "[swap] backup: $backup"
}
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item -Path (Join-Path $work "*") -Destination $dest -Recurse -Force
Write-Host "[swap] copied into $dest"

if ($NoBuild) { Write-Host "[swap] -NoBuild, stopping"; exit 0 }

Push-Location $root
try {
    cmd /c build.bat | Select-Object -Last 12
    if ($LASTEXITCODE -ne 0) { Write-Host "[swap] BUILD FAILED" -ForegroundColor Red; exit 1 }
} finally {
    Pop-Location
}

$dll = Join-Path $root "build32\bin\payload.dll"
if (Test-Path $dll) {
    Write-Host ("[swap] built: " + $dll + "  " + (Get-Item $dll).Length + " bytes")
}
Write-Host "[swap] done. Restart the client; the GUI auto-injects."
