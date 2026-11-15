#pragma once
#include <string>

// The payload is invisible: no console window. Everything it would have printed
// goes to an in-memory ring buffer that the host UI pulls with the LOG command.
void LogInit();
std::string LogTake();     // returns buffered text and clears it
size_t LogPending();       // bytes waiting (cheap check)
