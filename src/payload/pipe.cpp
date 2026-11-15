#include "pipe.h"

#include "Luau/Compiler.h"

#include "hook.h"
#include "lua_bridge.h"
#include "logbuf.h"
#include "mem.h"
#include "prologue.h"

#include <windows.h>
#include <iostream>
#include <sstream>
#include <string>

namespace {

std::string HexU(uintptr_t v) {
    std::ostringstream o;
    o << "0x" << std::hex << std::uppercase << v;
    return o.str();
}

// "rva:0x1234", "abs:0x7F...", or bare (below 256 MB == RVA of the main module).
uintptr_t ResolvePipeAddress(const std::string& value) {
    std::string s = value;
    bool absolute = false;
    if (s.rfind("abs:", 0) == 0) {
        absolute = true;
        s = s.substr(4);
    } else if (s.rfind("rva:", 0) == 0) {
        s = s.substr(4);
    }
    uintptr_t raw = 0;
    if (!ParseHex(s, raw) || raw == 0) return 0;
    if (absolute || raw >= 0x10000000ull) return raw;
    return MainModule().base + raw;
}

// Replaces any existing hook with one at `addr`; reply says exactly what happened.
std::string HookAt(uintptr_t addr) {
    if (addr == 0) return "failed: bad address";
    if (IsHooked()) RemoveInlineHook();
    HookPlanInfo plan = PlanHook(addr, kHookMinLen);
    if (!plan.ok) return "failed: " + plan.reason;
    if (!InstallInlineHook(addr, kHookMinLen)) return "failed: install";
    if (LuaState() == 0) LuaArmCapture();
    return "hooked rva=" + HexU(addr - MainModule().base) + " abs=" + HexU(addr) +
           " len=" + std::to_string(HookPatchLen()) + " hits=" +
           std::to_string(HookHits());
}

const char* kB64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

std::string B64Encode(const std::string& in) {
    std::string out;
    int val = 0, valb = -6;
    for (unsigned char c : in) {
        val = (val << 8) + c;
        valb += 8;
        while (valb >= 0) {
            out.push_back(kB64[(val >> valb) & 0x3F]);
            valb -= 6;
        }
    }
    if (valb > -6) out.push_back(kB64[((val << 8) >> (valb + 8)) & 0x3F]);
    while (out.size() % 4) out.push_back('=');
    return out;
}

int B64Val(char c) {
    if (c >= 'A' && c <= 'Z') return c - 'A';
    if (c >= 'a' && c <= 'z') return c - 'a' + 26;
    if (c >= '0' && c <= '9') return c - '0' + 52;
    if (c == '+') return 62;
    if (c == '/') return 63;
    return -1;
}

std::string B64Decode(const std::string& in) {
    std::string out;
    int val = 0, valb = -8;
    for (char c : in) {
        int d = B64Val(c);
        if (d < 0) break;
        val = (val << 6) + d;
        valb += 6;
        if (valb >= 0) {
            out.push_back(static_cast<char>((val >> valb) & 0xFF));
            valb -= 8;
        }
    }
    return out;
}



int DoInit() {
    uintptr_t entry = LuaGetTopAddress();
    if (entry == 0) return 0;
    if (!IsHooked() && !InstallInlineHook(entry, kHookMinLen)) return 0;
    LuaArmCapture();
    return 1;
}

DWORD WINAPI ServerProc(LPVOID) {
    for (;;) {
        HANDLE h = CreateNamedPipeW(L"\\\\.\\pipe\\octane_exec", PIPE_ACCESS_DUPLEX,
                                    PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT, 1,
                                    1 << 20, 1 << 20, 0, nullptr);
        if (h == INVALID_HANDLE_VALUE) {
            Sleep(250);
            continue;
        }
        if (ConnectNamedPipe(h, nullptr) || GetLastError() == ERROR_PIPE_CONNECTED) {
            std::string request;
            char chunk[4096];
            DWORD got = 0;
            while (ReadFile(h, chunk, sizeof(chunk), &got, nullptr) && got > 0) {
                request.append(chunk, got);
                if (request.find('\n') != std::string::npos) break;
            }
            size_t nl = request.find('\n');
            if (nl != std::string::npos) request.resize(nl);
            while (!request.empty() && (request.back() == '\r' || request.back() == ' ')) request.pop_back();

            std::string reply;
            if (request == "PING") {
                reply = "PONG";
            } else if (request == "INIT") {
                reply = DoInit() ? "OK" : "FAIL";
            } else if (request == "HOOKPCALL") {
                uintptr_t addr = LuaPcallAddress();
                if (addr == 0) addr = MainModule().base + 0xF41980;
                reply = HookAt(addr);
            } else if (request.rfind("HOOK ", 0) == 0) {
                reply = HookAt(ResolvePipeAddress(request.substr(5)));
            } else if (request == "UNHOOK") {
                reply = RemoveInlineHook() ? "unhooked" : "not hooked";
            } else if (request.rfind("OPT ", 0) == 0) {
                std::istringstream in(request.substr(4));
                int opt = 0, dbg = 0;
                in >> opt >> dbg;
                LuaSetCompileOptions(opt, dbg);
                LuaGetCompileOptions(opt, dbg);
                reply = "opt=" + std::to_string(opt) + " dbg=" + std::to_string(dbg);
            } else if (request == "LOADSTRING") {
                if (!LuaLoadstringReady()) {
                    reply = "missing pushcclosure/setfield (payload.cfg)";
                } else {
                    reply = LuaRegisterLoadstring() ? "registered" : "failed";
                }
            } else if (request.rfind("PROLOGUE ", 0) == 0) {
                uintptr_t addr = ResolvePipeAddress(request.substr(9));
                if (addr == 0) {
                    reply = "bad address";
                } else {
                    PrologueInfo p = DecodePrologue(addr, kHookMinLen);
                    if (!p.decoded) {
                        reply = "decode: " + p.error;
                    } else {
                        reply = "rva=" + HexU(addr - MainModule().base) + " len=" +
                                std::to_string(p.length) + " | " + p.text + " | " +
                                (p.hasRelative ? "UNSAFE relative" : "safe");
                    }
                }
            } else if (request == "LOG") {
                reply = LogTake();
                if (reply.empty()) reply = "-";
            } else if (request == "HITS") {
                reply = "hits=" + std::to_string(HookHits()) +
                        " target=" + HexU(HookTarget()) +
                        " len=" + std::to_string(HookPatchLen());
            } else if (request == "STATUS") {
                reply = LuaState() ? "attached" : (IsHooked() ? "hooked" : "idle");
            } else if (request.rfind("STATE", 0) == 0) {
                reply = "state=" + HexU(LuaState());
            } else if (request.rfind("PROBE ", 0) == 0) {
                std::string src = B64Decode(request.substr(6));
                try {
                    std::string bc = Luau::compile(src);
                    int rc = LuaLoadRaw(bc);
                    reply = "compile=" + std::to_string(bc.size()) +
                            " load_status=" + std::to_string(rc);
                } catch (const std::exception& e) {
                    reply = std::string("compile error: ") + e.what();
                }
            } else if (request.rfind("LOADTEST ", 0) == 0) {
                int rc = LuaLoadRaw(B64Decode(request.substr(9)));
                reply = "load_status=" + std::to_string(rc);
            } else if (request.rfind("EXEC ", 0) == 0) {
                std::string out;
                if (LuaSubmit(B64Decode(request.substr(5)), out, 5000))
                    reply = out;
                else
                    reply = "timeout - no Lua call happened (state busy or not in game)";
            } else if (request == "PING") {
                reply = "PONG";
            } else if (request == "INIT") {
                reply = DoInit() ? "OK" : "FAIL";
            } else if (request == "STATUS") {
                reply = LuaState() ? "attached" : (IsHooked() ? "hooked" : "idle");
            } else if (request.rfind("STATE", 0) == 0) {
                reply = "state=" + HexU(LuaState());
            } else if (request == "HITS") {
                reply = "hits=" + std::to_string(HookHits()) +
                        " target=" + HexU(HookTarget()) +
                        " len=" + std::to_string(HookPatchLen());
            } else if (request == "LOG") {
                reply = LogTake();
                if (reply.empty()) reply = "-";
            } else if (request == "HOOKPCALL") {
                uintptr_t addr = LuaPcallAddress();
                if (addr == 0) addr = MainModule().base + 0xF41980;
                reply = HookAt(addr);
            } else if (request.rfind("HOOK ", 0) == 0) {
                reply = HookAt(ResolvePipeAddress(request.substr(5)));
            } else if (request == "UNHOOK") {
                reply = RemoveInlineHook() ? "unhooked" : "not hooked";
            } else if (request.rfind("PROLOGUE ", 0) == 0) {
                uintptr_t addr = ResolvePipeAddress(request.substr(9));
                if (addr == 0) {
                    reply = "bad address";
                } else {
                    PrologueInfo p = DecodePrologue(addr, kHookMinLen);
                    if (!p.decoded) {
                        reply = "decode: " + p.error;
                    } else {
                        reply = "rva=" + HexU(addr - MainModule().base) + " len=" +
                                std::to_string(p.length) + " | " + p.text + " | " +
                                (p.hasRelative ? "UNSAFE relative" : "safe");
                    }
                }
            } else if (request.rfind("OPT ", 0) == 0) {
                std::istringstream in(request.substr(4));
                int opt = 0, dbg = 0;
                in >> opt >> dbg;
                LuaSetCompileOptions(opt, dbg);
                LuaGetCompileOptions(opt, dbg);
                reply = "opt=" + std::to_string(opt) + " dbg=" + std::to_string(dbg);
            } else if (request == "LOADSTRING") {
                if (!LuaLoadstringReady()) {
                    reply = "missing pushcclosure/setfield (payload.cfg)";
                } else {
                    reply = LuaRegisterLoadstring() ? "registered" : "failed";
                }
            } else if (request.rfind("STRUCT ", 0) == 0) {
                reply = LuaProbeStructures(B64Decode(request.substr(7)));
            } else if (request.rfind("FIELD ", 0) == 0) {
                std::string out;
                std::string name = B64Decode(request.substr(6));
                if (LuaSubmitBytecode(std::string("\x01PROBE:") + name, out, 5000)) reply = out;
                else reply = "timeout - no Lua call happened";
            } else if (request == "GLOBALS") {
                std::string out;
                if (LuaSubmitBytecode(std::string("\x01GLOBALS"), out, 5000)) reply = out;
                else reply = "timeout - no Lua call happened";
            } else if (request.rfind("PROBE ", 0) == 0) {
                std::string src = B64Decode(request.substr(6));
                try {
                    std::string bc = Luau::compile(src);
                    int rc = LuaLoadRaw(bc);
                    reply = "compile=" + std::to_string(bc.size()) +
                            " load_status=" + std::to_string(rc);
                } catch (const std::exception& e) {
                    reply = std::string("compile error: ") + e.what();
                }
            } else if (request.rfind("LOADTEST ", 0) == 0) {
                int rc = LuaLoadRaw(B64Decode(request.substr(9)));
                reply = "load_status=" + std::to_string(rc);
            } else if (request.rfind("BC ", 0) == 0) {
                std::string out;
                if (LuaSubmitBytecode(B64Decode(request.substr(3)), out, 5000)) reply = out;
                else reply = "timeout - no Lua call happened";
            } else if (request.rfind("EXEC ", 0) == 0) {
                std::string out;
                if (LuaSubmit(B64Decode(request.substr(5)), out, 5000)) reply = out;
                else reply = "timeout - no Lua call happened (state busy or not in game)";
            } else {
                reply = "unknown command";
            }

            // Prefix so a 4-letter plaintext like "PONG" is never mistaken for base64.
            std::string out = "b64:" + B64Encode(reply);
            DWORD written = 0;
            WriteFile(h, out.data(), static_cast<DWORD>(out.size()), &written, nullptr);
            FlushFileBuffers(h);
        }
        DisconnectNamedPipe(h);
        CloseHandle(h);
    }
    return 0;
}

}  // namespace

void StartPipeServer() {
    CreateThread(nullptr, 0, ServerProc, nullptr, 0, nullptr);
}
