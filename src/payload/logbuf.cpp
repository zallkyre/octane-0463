#include "logbuf.h"

#include <iostream>
#include <mutex>

namespace {

constexpr size_t kCap = 64 * 1024;  // keep the tail only; the UI polls often

class LogBuf : public std::streambuf {
public:
    std::string take() {
        std::lock_guard<std::mutex> lock(_m);
        std::string out;
        out.swap(_buf);
        return out;
    }

    size_t pending() {
        std::lock_guard<std::mutex> lock(_m);
        return _buf.size();
    }

protected:
    int_type overflow(int_type c) override {
        if (c == traits_type::eof()) return traits_type::not_eof(c);
        append(&c, 1);
        return c;
    }

    std::streamsize xsputn(const char* s, std::streamsize n) override {
        append(s, static_cast<size_t>(n));
        return n;
    }

private:
    void append(const void* data, size_t n) {
        std::lock_guard<std::mutex> lock(_m);
        _buf.append(static_cast<const char*>(data), n);
        if (_buf.size() > kCap) _buf.erase(0, _buf.size() - kCap);
    }

    std::string _buf;
    std::mutex _m;
};

LogBuf g_log;

}  // namespace

void LogInit() {
    std::cout.rdbuf(&g_log);
    std::cout << std::unitbuf;   // flush every insertion into the ring
    std::cerr.rdbuf(&g_log);
}

std::string LogTake() { return g_log.take(); }

size_t LogPending() { return g_log.pending(); }
