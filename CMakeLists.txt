cmake_minimum_required(VERSION 3.16)
project(injector-base LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(injector src/injector/main.cpp)
target_compile_definitions(injector PRIVATE UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN)
if (MSVC)
    target_compile_options(injector PRIVATE /W4 /EHsc /utf-8)
endif()

add_library(payload SHARED
    src/payload/dllmain.cpp
    src/payload/console.cpp
    src/payload/hook.cpp
    src/payload/logbuf.cpp
    src/payload/prologue.cpp
    src/payload/mem.cpp
    src/payload/lua_bridge.cpp
    src/payload/pipe.cpp
    src/payload/exports.cpp
)
target_compile_definitions(payload PRIVATE UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN)
if (MSVC)
    target_compile_options(payload PRIVATE /W4 /EHsc /utf-8)
target_link_libraries(payload PRIVATE luau_compiler)
endif()

set(PAYLOAD_OUTPUT_NAME "payload" CACHE STRING "base name of the injected DLL (payload -> payload.dll)")

set_target_properties(payload PROPERTIES
    PREFIX ""
    OUTPUT_NAME "${PAYLOAD_OUTPUT_NAME}"
    SUFFIX ".dll"
)

# both artifacts land in one folder next to each other
set_target_properties(injector PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/bin"
)
set_target_properties(payload PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/bin"
)

# self-test for the inline hook (not part of injector/payload)
add_executable(hook_test
    tests/hook_test.cpp
    src/payload/hook.cpp
    src/payload/logbuf.cpp
    src/payload/prologue.cpp
    src/payload/mem.cpp
)
target_include_directories(hook_test PRIVATE src/payload)
target_compile_definitions(hook_test PRIVATE UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN)
if (MSVC)
    target_compile_options(hook_test PRIVATE /W4 /EHsc /utf-8)
endif()
set_target_properties(hook_test PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
)

add_executable(lua_stub_test
    tests/lua_stub_test.cpp
    src/payload/lua_bridge.cpp
    src/payload/mem.cpp
    src/payload/hook.cpp
    src/payload/logbuf.cpp
    src/payload/prologue.cpp
)
target_include_directories(lua_stub_test PRIVATE src/payload)
target_link_libraries(lua_stub_test PRIVATE luau_compiler)
target_compile_definitions(lua_stub_test PRIVATE UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN)
if (MSVC)
    target_compile_options(lua_stub_test PRIVATE /W4 /EHsc /utf-8)
endif()
set_target_properties(lua_stub_test PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
)

add_executable(dump_test
    tests/dump_test.cpp
    src/payload/mem.cpp
)
target_include_directories(dump_test PRIVATE src/payload)
target_compile_definitions(dump_test PRIVATE UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN)
if (MSVC)
    target_compile_options(dump_test PRIVATE /W4 /EHsc /utf-8)
endif()
add_executable(prologue_test
    tests/prologue_test.cpp
    src/payload/prologue.cpp
    src/payload/mem.cpp
)
target_include_directories(prologue_test PRIVATE src/payload)
target_compile_definitions(prologue_test PRIVATE UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN)
if (MSVC)
    target_compile_options(prologue_test PRIVATE /W4 /EHsc /utf-8)
endif()
set_target_properties(prologue_test PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
)

set_target_properties(dump_test PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
)

# ---- Luau compiler (bytecode generation for exec) ----
file(GLOB LUAU_COMPILER_SOURCES
    "${CMAKE_SOURCE_DIR}/third_party/luau/Ast/src/*.cpp"
    "${CMAKE_SOURCE_DIR}/third_party/luau/Compiler/src/*.cpp"
)
add_library(luau_compiler STATIC ${LUAU_COMPILER_SOURCES})
target_include_directories(luau_compiler PUBLIC
    "${CMAKE_SOURCE_DIR}/third_party/luau/Ast/include"
    "${CMAKE_SOURCE_DIR}/third_party/luau/Compiler/include"
    "${CMAKE_SOURCE_DIR}/third_party/luau/VM/include"
)
target_compile_features(luau_compiler PUBLIC cxx_std_17)
if (MSVC)
    target_compile_options(luau_compiler PRIVATE /EHsc /O2 /utf-8 /wd4996)
endif()

add_executable(bcgen tests/bcgen.cpp)
target_link_libraries(bcgen PRIVATE luau_compiler)
target_compile_definitions(bcgen PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
if (MSVC)
    target_compile_options(bcgen PRIVATE /EHsc /utf-8)
endif()
set_target_properties(bcgen PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
)

add_executable(compile_test tests/compile_test.cpp)
target_link_libraries(compile_test PRIVATE luau_compiler)
target_compile_definitions(compile_test PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
if (MSVC)
    target_compile_options(compile_test PRIVATE /EHsc /utf-8)
endif()
set_target_properties(compile_test PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
)

# ---- reference Luau VM (opcode handler fingerprinting only) ----
file(GLOB LUAU_VM_SOURCES "${CMAKE_SOURCE_DIR}/third_party/luau/VM/src/*.cpp")
add_library(luau_vm STATIC ${LUAU_VM_SOURCES})
target_include_directories(luau_vm PUBLIC "${CMAKE_SOURCE_DIR}/third_party/luau/VM/include" PRIVATE "${CMAKE_SOURCE_DIR}/third_party/luau/VM/src")
target_compile_features(luau_vm PUBLIC cxx_std_17)
if (MSVC)
  target_compile_options(luau_vm PRIVATE /O2 /utf-8 /wd4996)
endif()

add_executable(vmref tools/vmref.cpp)
target_link_libraries(vmref PRIVATE luau_vm)
target_compile_definitions(vmref PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
set_target_properties(vmref PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin")
