@echo off
setlocal
cd /d "%~dp0"

set "CMAKE="
for /f "delims=" %%i in ('where cmake 2^>nul') do if not defined CMAKE set "CMAKE=%%i"
if not defined CMAKE call :find_bundled_cmake

if not defined CMAKE (
    echo [build] CMake not found.
    echo         Install Visual Studio 2022 Build Tools with "Desktop development with C++",
    echo         or put cmake.exe on PATH.
    exit /b 1
)

echo [build] cmake: %CMAKE%

call :build_one x64 build64
if errorlevel 1 exit /b 1
call :build_one Win32 build32
if errorlevel 1 exit /b 1

echo.
echo [build] done:
echo   64-bit client:  build64\bin\injector.exe  +  build64\bin\payload.dll
echo   32-bit client:  build32\bin\injector.exe  +  build32\bin\payload.dll
echo   self-test:      build64\bin\hook_test.exe  /  build32\bin\hook_test.exe
exit /b 0

:build_one
echo [build] %~1 -^> %~2
"%CMAKE%" -S . -B "%~2" -A %~1
if errorlevel 1 exit /b 1
"%CMAKE%" --build "%~2" --config Release
if errorlevel 1 exit /b 1
exit /b 0

:find_bundled_cmake
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" exit /b 0
set "VSROOT="
for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSROOT=%%i"
if not defined VSROOT exit /b 0
set "BUNDLED=%VSROOT%\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
if exist "%BUNDLED%" set "CMAKE=%BUNDLED%"
exit /b 0
