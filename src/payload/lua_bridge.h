#pragma once
#include <cstdint>
#include <string>

// Thin bridge to the host's Luau/Lua state.
// API to bind: luau_load (or loadbuffer), pcall, tostring, gettop, settop.
void LuaSetApi(const std::string& name, uintptr_t addr);
void LuaPrintApi();
void LuaSetState(uintptr_t state);
uintptr_t LuaState();
uintptr_t LuaGetTopAddress();
uintptr_t LuaPcallAddress();
void LuaPrintVersion();
bool LuaExec(const std::string& source);  // compile (Luau) + load + call
bool LuaSubmit(const std::string& source, std::string& output, unsigned timeoutMs);
// Runs a pre-built bytecode blob through the same Lua-thread dispatch (for
// probing the host's loader/VM format without recompiling).
bool LuaSubmitBytecode(const std::string& bytecode, std::string& output, unsigned timeoutMs);
void LuaRunPendingOnLuaThread();          // called from the hook callback
int LuaLoadRaw(const std::string& bytes);  // guarded luau_load probe, returns status
std::string LuaProbeStructures(const std::string& bytecode);  // diagnostic dump
std::string LuaProbeField(const std::string& name, const std::string& seedBytecode);
void LuaArmCapture();                    // take state from next hook hit

// Installs a global `loadstring(source)` implemented with our Luau compiler.
// Needs lua_pushcclosure and lua_setfield bound; returns false without them.
bool LuaRegisterLoadstring();
bool LuaLoadstringReady();

// Bytecode shape used for compile(): optimization level 0..2, debug level 0/1/2.
void LuaSetCompileOptions(int optimizationLevel, int debugLevel);
void LuaGetCompileOptions(int& optimizationLevel, int& debugLevel);
struct SavedRegs;
bool LuaCaptureFrom(SavedRegs* regs);
