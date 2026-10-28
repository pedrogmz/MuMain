# Toolchain for WebAssembly builds via Emscripten

if(NOT DEFINED EMSDK AND DEFINED ENV{EMSDK})
    file(TO_CMAKE_PATH "$ENV{EMSDK}" EMSDK)
endif()

if(NOT DEFINED EMSDK)
    file(TO_CMAKE_PATH "$ENV{USERPROFILE}/emsdk" EMSDK)
endif()

set(EMSCRIPTEN_TOOLCHAIN "${EMSDK}/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake")
if(EXISTS "${EMSCRIPTEN_TOOLCHAIN}")
    include("${EMSCRIPTEN_TOOLCHAIN}")
else()
    message(FATAL_ERROR "Emscripten toolchain file not found at ${EMSCRIPTEN_TOOLCHAIN}. Make sure EMSDK is set.")
endif()

set(CMAKE_SYSTEM_NAME Emscripten)
set(CMAKE_SYSTEM_PROCESSOR wasm32)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
