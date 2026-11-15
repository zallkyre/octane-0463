# Builds the WinForms shell from ui\src\*.cs.
# In-box csc only speaks C# 5: no `?.`, no string interpolation, no `nameof`.
param(
    [string]$Out = (Join-Path $PSScriptRoot "..\ui\OctaneExecutor.exe")
)

$ErrorActionPreference = "Stop"
$csc = Join-Path $env:WINDIR "Microsoft.NET\Framework\v4.0.30319\csc.exe"
if (-not (Test-Path $csc)) { throw "csc.exe not found at $csc" }

$src = Get-ChildItem (Join-Path $PSScriptRoot "..\ui\src\*.cs") | ForEach-Object { $_.FullName }
$icon = Join-Path $PSScriptRoot "..\ui\assets\octane.ico"

& $csc /nologo /target:winexe /platform:x86 /optimize+ /out:$Out `
    /win32icon:$icon `
    /r:System.dll /r:System.Drawing.dll /r:System.Windows.Forms.dll $src

if ($LASTEXITCODE -ne 0) { throw "csc failed with $LASTEXITCODE" }
Write-Host ("built " + (Resolve-Path $Out) + "  " + (Get-Item $Out).Length + " bytes")
