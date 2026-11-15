#include "console.h"

#include "hook.h"
#include "logbuf.h"
#include "lua_bridge.h"
#include "mem.h"
#include "prologue.h"

#include <cstdio>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

namespace {

HMODULE g_self = nullptr;
size_t g_patchLen = kHookMinLen;

std::string Trim(const std::string& s) {
    size_t a = s.find_first_not_of(" \t\r\n");
    if (a == std::string::npos) return {};
    size_t b = s.find_last_not_of(" \t\r\n");
    return s.substr(a, b - a + 1);
}

std::vector<std::string> Split(const std::string& s) {
    std::vector<std::string> out;
    std::istringstream in(s);
    std::string tok;
    while (in >> tok) out.push_back(tok);
    return out;
}

std::wstring ModuleDir() {
    wchar_t buf[MAX_PATH]{};
    GetModuleFileNameW(g_self, buf, MAX_PATH);
    std::wstring p(buf);
    size_t cut = p.find_last_of(L"\\/");
    return cut == std::wstring::npos ? std::wstring() : p.substr(0, cut + 1);
}

std::string Narrow(const std::wstring& w) {
    if (w.empty()) return {};
    int n = WideCharToMultiByte(CP_UTF8, 0, w.c_str(), -1, nullptr, 0, nullptr, nullptr);
    std::string out(static_cast<size_t>(n > 0 ? n - 1 : 0), '\0');
    if (n > 1) {
        WideCharToMultiByte(CP_UTF8, 0, w.c_str(), -1, &out[0], n, nullptr, nullptr);
    }
    return out;
}

std::string Hex(uintptr_t v) {
    std::ostringstream o;
    o << "0x" << std::hex << std::uppercase << v;
    return o.str();
}

// Accepts "rva:0x1234", "abs:0x7FF6...", or a bare number.
// Bare values below 256 MB are treated as an RVA of the main module
// (that is how offset dumps are usually published); anything larger as absolute.
uintptr_t ResolveAddress(const std::string& value) {
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

void Help() {
    std::cout <<
        "general:\n"
        "  help                      this text\n"
        "  mods                      list loaded modules (base / size)\n"
        "  base                      main module base / size\n"
        "  scan <pattern>            pattern scan, e.g. scan 48 8B ?? ?? 0F\n"
        "  read <addr> <len>         hex dump memory (len <= 4096)\n"
        "  write <addr> <hexbytes>   patch memory, e.g. write 0x7FF6.. 90 90\n"
        "  hook <addr> [len]         install inline hook (len default "
        << kHookMinLen << ", minimum " << kHookMinLen << ")\n"
        "  hookpcall                 unhook, then hook bound lua_pcall\n"
        "  prologue <addr> [len]     decode bytes without patching\n"
        "  unhook                    restore original bytes\n"
        "  hits [secs]               hook call count, or hits/sec over <secs>\n"
        "  dump [path]               write the unpacked main module (packed clients)\n"
        "\n"
        "lua (works for any Lua 5.1/5.3/LuaJIT host, e.g. a Roblox revival):\n"
        "  luaver                    fingerprint the Lua build by version strings\n"
        "  lua-init                  hook lua_gettop and capture the state\n"
        "  luaapi <name> <addr>      luau_load|loadbuffer|pcall|tostring|gettop|settop|pushcclosure|setfield\n"
        "  loadstring                register global loadstring (needs pushcclosure+setfield)\n"
        "  capture                   take lua_State* from the next hook hit\n"
        "  luastate [addr]           show / set lua_State*\n"
        "  luainfo                   show state + bound API addresses\n"
        "  exec <lua code>           load + call the code on the captured state\n"
        "\n"
        "  quit                      close console (hook stays installed)\n"
        "\n"
        "revival recipe:\n"
        "  1) scan/luaapi the client's luaL_loadbuffer + lua_pcall\n"
        "  2) hook <lua_pcall addr>   (any Lua call, e.g. a timer)\n"
        "  3) capture                 -> luastate shows the state\n"
        "  4) exec print('hi')\n";
}

void CommandMods() {
    auto mods = ListModules();
    std::cout << mods.size() << " modules\n";
    for (auto& [name, range] : mods) {
        std::cout << "  " << Hex(range.base) << "  " << Hex(range.size) << "  "
                  << Narrow(name) << "\n";
    }
}

void CommandBase() {
    ModuleRange m = MainModule();
    std::cout << "base " << Hex(m.base) << "  size " << Hex(m.size) << "\n";
}

void CommandScan(const std::vector<std::string>& args) {
    std::string pattern;
    for (size_t i = 1; i < args.size(); ++i) {
        if (!pattern.empty()) pattern += ' ';
        pattern += args[i];
    }
    std::vector<uint8_t> bytes;
    std::vector<bool> wild;
    if (!PatternToBytes(pattern, bytes, wild)) {
        std::cout << "bad pattern\n";
        return;
    }
    ModuleRange m = MainModule();
    uintptr_t hit = ScanModule(m, bytes, wild);
    if (!hit) {
        std::cout << "not found in " << Hex(m.base) << " .. "
                  << Hex(m.base + m.size) << "\n";
        return;
    }
    std::cout << "found at " << Hex(hit) << "\n";
}

void CommandRead(const std::vector<std::string>& args) {
    if (args.size() < 3) {
        std::cout << "usage: read <addr> <len>\n";
        return;
    }
    uintptr_t addr = 0;
    if (!ParseHex(args[1], addr)) {
        std::cout << "bad address\n";
        return;
    }
    unsigned long long len = 0;
    try {
        len = std::stoull(args[2], nullptr, 0);
    } catch (...) {
        std::cout << "bad length\n";
        return;
    }
    if (len == 0 || len > 4096) {
        std::cout << "length must be 1..4096\n";
        return;
    }
    std::vector<uint8_t> buf(static_cast<size_t>(len));
    if (!SafeRead(addr, buf.data(), buf.size())) {
        std::cout << "unreadable\n";
        return;
    }
    std::cout << HexDump(buf.data(), buf.size());
}

void CommandWrite(const std::vector<std::string>& args) {
    if (args.size() < 3) {
        std::cout << "usage: write <addr> <hexbytes>\n";
        return;
    }
    uintptr_t addr = 0;
    if (!ParseHex(args[1], addr)) {
        std::cout << "bad address\n";
        return;
    }
    std::string blob;
    for (size_t i = 2; i < args.size(); ++i) blob += args[i];
    std::vector<uint8_t> bytes = ParseBytes(blob);
    if (bytes.empty()) {
        std::cout << "bad bytes\n";
        return;
    }
    if (!SafeWrite(addr, bytes.data(), bytes.size())) {
        std::cout << "unwritable (try an .rdata / .text address or hook instead)\n";
        return;
    }
    std::cout << "wrote " << bytes.size() << " bytes at " << Hex(addr) << "\n";
}

void CommandHook(const std::vector<std::string>& args) {
    if (args.size() < 2) {
        std::cout << "usage: hook <addr> [len]\n";
        return;
    }
    uintptr_t addr = 0;
    if (!ParseHex(args[1], addr)) {
        std::cout << "bad address\n";
        return;
    }
    size_t len = g_patchLen;
    if (args.size() >= 3) {
        try {
            len = static_cast<size_t>(std::stoull(args[2], nullptr, 0));
        } catch (...) {
            std::cout << "bad length\n";
            return;
        }
    }
    if (len < kHookMinLen) {
        std::cout << "len must be >= " << kHookMinLen << "\n";
        return;
    }
    if (IsHooked()) {
        std::cout << "already hooked at " << Hex(HookTarget()) << "\n";
        return;
    }
    HookPlanInfo plan = PlanHook(addr, len);
    std::cout << "hooked-target " << Hex(addr) << " patch len " << plan.patchLen << "\n";
    if (!plan.text.empty()) std::cout << "  " << plan.text << "\n";
    if (!plan.ok) {
        std::cout << "refused: " << plan.reason << "\n";
        return;
    }
    if (!InstallInlineHook(addr, len)) {
        std::cout << "hook failed\n";
        return;
    }
    std::cout << "hooked " << Hex(addr) << " len " << HookPatchLen() << "\n";
}

void CommandPrologue(const std::vector<std::string>& args) {
    if (args.size() < 2) {
        std::cout << "usage: prologue <addr> [len]\n";
        return;
    }
    uintptr_t addr = 0;
    if (!ParseHex(args[1], addr)) {
        std::cout << "bad address\n";
        return;
    }
    size_t len = kHookMinLen;
    if (args.size() >= 3) {
        try {
            len = static_cast<size_t>(std::stoull(args[2], nullptr, 0));
        } catch (...) {
            std::cout << "bad length\n";
            return;
        }
    }
    if (len < kHookMinLen) len = kHookMinLen;
    uint8_t raw[32] = {};
    if (SafeRead(addr, raw, sizeof(raw))) {
        std::cout << HexDump(raw, 24);
    }
    PrologueInfo p = DecodePrologue(addr, len);
    if (!p.decoded) {
        std::cout << "decode: " << p.error << "\n";
        return;
    }
    std::cout << "decoded len " << p.length << ": " << p.text << "\n";
    std::cout << "relative=" << (p.hasRelative ? "yes" : "no")
              << " terminal=" << (p.hasTerminal ? "yes" : "no")
              << " => " << (p.hasRelative ? "UNSAFE to copy" : "safe detour") << "\n";
}

void CommandHookPcall() {
    uintptr_t addr = LuaPcallAddress();
    if (addr == 0) {
        std::cout << "pcall not bound - 'luaapi pcall <addr>' or payload.cfg\n";
        return;
    }
    if (IsHooked()) {
        std::cout << "unhooked " << Hex(HookTarget()) << " after " << HookHits()
                  << " hits\n";
        RemoveInlineHook();
    }
    HookPlanInfo plan = PlanHook(addr, kHookMinLen);
    std::cout << "pcall " << Hex(addr) << " patch len " << plan.patchLen << "\n";
    if (!plan.text.empty()) std::cout << "  " << plan.text << "\n";
    if (!plan.ok) {
        std::cout << "refused: " << plan.reason << "\n";
        return;
    }
    if (!InstallInlineHook(addr, kHookMinLen)) {
        std::cout << "hook failed\n";
        return;
    }
    if (LuaState() == 0) {
        LuaArmCapture();
        std::cout << "capture armed\n";
    }
    std::cout << "hooked lua_pcall, hits " << HookHits() << "\n";
}

void CommandHits(const std::vector<std::string>& args) {
    if (!IsHooked()) {
        std::cout << "not hooked\n";
        return;
    }
    if (args.size() < 2) {
        std::cout << "target " << Hex(HookTarget()) << "  len " << HookPatchLen()
                  << "  hits " << HookHits() << "  first tick "
                  << HookFirstHitTick() << "\n";
        return;
    }
    unsigned secs = 3;
    try {
        secs = static_cast<unsigned>(std::stoul(args[1], nullptr, 0));
    } catch (...) {
        std::cout << "bad seconds\n";
        return;
    }
    if (secs < 1) secs = 1;
    if (secs > 60) secs = 60;
    uint64_t before = HookHits();
    Sleep(secs * 1000);
    uint64_t after = HookHits();
    std::cout << "hits " << before << " -> " << after << "  delta " << (after - before)
              << " over " << secs << "s\n";
}

void CommandDump(const std::vector<std::string>& args) {
    std::wstring path;
    if (args.size() >= 2) {
        path.assign(args[1].begin(), args[1].end());
    } else {
        path = ModuleDir() + L"dump.exe";
    }
    if (DumpMainModule(path)) {
        std::cout << "dumped main module to " << Narrow(path) << "\n";
        std::cout << "  open it in IDA/Ghidra to get RVAs\n";
    } else {
        std::cout << "dump failed\n";
    }
}

void OnHookHit(SavedRegs* regs) {
    if (LuaCaptureFrom(regs)) {
        std::cout << "captured from hook\n";
    }
    LuaRunPendingOnLuaThread();
}

void ApplyConfig() {
    std::wstring path = ModuleDir() + L"payload.cfg";
    std::ifstream in(path);
    if (!in) {
        std::cout << "[cfg] no payload.cfg (optional)\n";
        return;
    }

    std::string scanPattern;
    bool autohook = true;
    std::vector<std::pair<std::string, std::string>> luaKeys;
    std::string line;
    while (std::getline(in, line)) {
        line = Trim(line);
        if (line.empty() || line[0] == ';' || line[0] == '#') continue;
        size_t eq = line.find('=');
        if (eq == std::string::npos) continue;
        std::string key = Trim(line.substr(0, eq));
        std::string value = Trim(line.substr(eq + 1));
        if (key == "scan") {
            scanPattern = value;
        } else if (key == "len" || key == "hooklen") {
            try {
                g_patchLen = static_cast<size_t>(std::stoull(value, nullptr, 0));
            } catch (...) {
            }
        } else if (key == "autohook") {
            autohook = (value != "0");
        } else if (key == "loadbuffer" || key == "luau_load" || key == "pcall" ||
                   key == "tostring" || key == "gettop" || key == "settop" ||
                   key == "pushcclosure" || key == "setfield") {
            luaKeys.emplace_back(key, value);
        }
    }

    for (auto& [name, value] : luaKeys) {
        uintptr_t addr = ResolveAddress(value);
        if (addr) {
            LuaSetApi(name, addr);
        } else {
            std::cout << "[cfg] bad address for " << name << ": " << value << "\n";
        }
    }

    if (scanPattern.empty() || !autohook) {
        std::cout << "[cfg] loaded, no autohook\n";
        return;
    }

    std::vector<uint8_t> bytes;
    std::vector<bool> wild;
    if (!PatternToBytes(scanPattern, bytes, wild)) {
        std::cout << "[cfg] bad scan pattern\n";
        return;
    }
    ModuleRange m = MainModule();
    uintptr_t hit = ScanModule(m, bytes, wild);
    if (!hit) {
        std::cout << "[cfg] pattern not found\n";
        return;
    }
    std::cout << "[cfg] pattern at " << Hex(hit) << ", hooking...\n";
    if (g_patchLen < kHookMinLen) g_patchLen = kHookMinLen;
    if (InstallInlineHook(hit, g_patchLen)) {
        std::cout << "[cfg] hooked\n";
    } else {
        std::cout << "[cfg] hook failed\n";
    }
}

void Banner() {
    ModuleRange m = MainModule();
    std::cout << "\n=== payload ===\n";
#if defined(_WIN64)
    std::cout << "arch x64\n";
#else
    std::cout << "arch x86\n";
#endif
    std::cout << "main module " << Hex(m.base) << " .. " << Hex(m.base + m.size) << "\n";
}

}  // namespace

// Reads a 0/1 flag from payload.cfg. Default keeps the payload silent.
static bool ConfigFlag(const char* key, bool def) {
    std::wstring path = ModuleDir() + L"payload.cfg";
    std::ifstream in(path);
    if (!in) return def;
    std::string line;
    while (std::getline(in, line)) {
        line = Trim(line);
        if (line.empty() || line[0] == ';' || line[0] == '#') continue;
        size_t eq = line.find('=');
        if (eq == std::string::npos) continue;
        if (Trim(line.substr(0, eq)) == key) return Trim(line.substr(eq + 1)) != "0";
    }
    return def;
}

void RunConsole(HMODULE self) {
    g_self = self;

    // Default: invisible. Output goes to the ring buffer the UI polls over the pipe.
    bool wantConsole = ConfigFlag("console", false);
    if (wantConsole) {
        AllocConsole();
        SetConsoleTitleW(L"payload");
        SetConsoleOutputCP(CP_UTF8);
        SetConsoleCP(CP_UTF8);

        FILE* dummy = nullptr;
        freopen_s(&dummy, "CONOUT$", "w", stdout);
        freopen_s(&dummy, "CONOUT$", "w", stderr);
        freopen_s(&dummy, "CONIN$", "r", stdin);
        std::ios::sync_with_stdio();
    } else {
        LogInit();
    }

    SetHookCallback(OnHookHit);

    Banner();
    ApplyConfig();

    if (!wantConsole) return;   // headless: driven through the pipe only

    std::string line;
    while (true) {
        std::cout << "> " << std::flush;
        if (!std::getline(std::cin, line)) {
            Sleep(50);
            continue;
        }
        line = Trim(line);
        if (line.empty()) continue;

        std::vector<std::string> args = Split(line);
        const std::string& cmd = args[0];

        if (cmd == "help" || cmd == "?") {
            Help();
        } else if (cmd == "mods") {
            CommandMods();
        } else if (cmd == "base") {
            CommandBase();
        } else if (cmd == "scan") {
            CommandScan(args);
        } else if (cmd == "read") {
            CommandRead(args);
        } else if (cmd == "write") {
            CommandWrite(args);
        } else if (cmd == "hook") {
            CommandHook(args);
        } else if (cmd == "hookpcall") {
            CommandHookPcall();
        } else if (cmd == "prologue") {
            CommandPrologue(args);
        } else if (cmd == "unhook") {
            std::cout << (RemoveInlineHook() ? "unhooked\n" : "not hooked\n");
        } else if (cmd == "dump") {
            CommandDump(args);
        } else if (cmd == "hits") {
            CommandHits(args);
        } else if (cmd == "lua-init") {
            uintptr_t entry = LuaGetTopAddress();
            if (entry == 0) {
                std::cout << "gettop address not bound - set luaapi gettop <addr>\n";
            } else {
                if (IsHooked()) RemoveInlineHook();
                HookPlanInfo plan = PlanHook(entry, kHookMinLen);
                if (!plan.ok) {
                    std::cout << "refused: " << plan.reason << "\n";
                } else if (InstallInlineHook(entry, kHookMinLen)) {
                    LuaArmCapture();
                    std::cout << "hooked lua_gettop at " << Hex(entry) << " len "
                              << HookPatchLen() << ", capture armed\n";
                } else {
                    std::cout << "hook failed\n";
                }
            }
        } else if (cmd == "luaver") {
            LuaPrintVersion();
        } else if (cmd == "luaapi") {
            if (args.size() < 3) {
                std::cout << "usage: luaapi <name> <addr>\n";
            } else {
                uintptr_t addr = 0;
                if (!ParseHex(args[2], addr)) {
                    std::cout << "bad address\n";
                } else {
                    LuaSetApi(args[1], addr);
                }
            }
        } else if (cmd == "luainfo") {
            LuaPrintApi();
        } else if (cmd == "loadstring") {
            if (!LuaLoadstringReady()) {
                std::cout << "bind first: luaapi pushcclosure <addr> ; luaapi setfield <addr>\n";
            } else if (LuaRegisterLoadstring()) {
                std::cout << "global loadstring installed\n";
            } else {
                std::cout << "registration failed (no state, or the call faulted)\n";
            }
        } else if (cmd == "luastate") {
            if (args.size() >= 2) {
                uintptr_t addr = 0;
                if (!ParseHex(args[1], addr)) {
                    std::cout << "bad address\n";
                } else {
                    LuaSetState(addr);
                }
            } else if (LuaState()) {
                std::cout << "lua_State* = " << Hex(LuaState()) << "\n";
            } else {
                std::cout << "no state captured\n";
            }
        } else if (cmd == "capture") {
            LuaArmCapture();
            std::cout << "capture armed";
            if (!IsHooked()) std::cout << " (hook something first: hook <lua entry> [len])";
            std::cout << "\n";
        } else if (cmd == "exec") {
            std::string code;
            for (size_t i = 1; i < args.size(); ++i) {
                if (!code.empty()) code += ' ';
                code += args[i];
            }
            if (code.empty()) {
                std::cout << "usage: exec <lua code>\n";
            } else {
                LuaExec(code);
            }
        } else if (cmd == "quit" || cmd == "exit") {
            std::cout << "console closed; hook left as-is\n";
            FreeConsole();
            return;
        } else {
            std::cout << "unknown command: " << cmd << "\n";
        }
    }
}
