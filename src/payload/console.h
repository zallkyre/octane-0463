#pragma once
#include <windows.h>

// Opens a console inside the host process and runs the command loop.
// Blocks until the user types `quit` or the console input ends.
void RunConsole(HMODULE self);
