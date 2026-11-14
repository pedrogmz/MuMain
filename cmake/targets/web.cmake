# The browser: Emscripten, WebGPU through XDL_wgpu, and the network over a WebSocket to openmu-browser-stack.
# What a target file sets is described in docs/build/README.md (Targets).

set(MU_PLATFORM_SOURCES "posix")
# No saved logins, shop downloads or CPU usage in the browser.
set(MU_TARGET_ADAPTERS
  "Core/Platform/Adapters/CredentialsUnavailable.cpp"
  "GameShop/FileDownloader/Adapters/ShopDownloadUnavailable.cpp"
  "Core/Utilities/Adapters/CpuUsageUnavailable.cpp"
  "Render/Renderer/Adapters/GpuDeviceSdlChoice.cpp")
# JPEG textures decode through stb_image (Core/Platform/TurboJpegShim.cpp).
set(MU_TARGET_DEPENDENCIES Cryptopp)

# No Crypto++ port for the browser: version 14 BMD models stay unreadable (Render/Models/BmdModulusCipher.cpp).
add_library(MuDep_Cryptopp INTERFACE)
add_library(MuDep::Cryptopp ALIAS MuDep_Cryptopp)
target_compile_definitions(MuDep_Cryptopp INTERFACE MU_NO_CRYPTOPP=1)

# No NativeAOT library: the connection's exports come from the WebSocket bridge, which also skips building it.
set(MU_MANAGED_SYMBOL_SOURCE "websocket")
set(MU_TARGET_SYMBOL_ADAPTER "${CMAKE_CURRENT_LIST_DIR}/../../src/source/Dotnet/SymbolSources/WebSocketSource.cpp")
