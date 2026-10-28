// Flow Code: VS1-NET-ERROR-MESSAGING
// Story: 3.4.1 - Connection Error Messaging & Graceful Degradation
//
// AC-4 reserved message template (not triggered in this story):
//   "Server handshake failed. Check OpenMU version compatibility."
// AC-5 reserved message template (not triggered in this story):
//   "Login failed. Check credentials."

#include "stdafx.h"
#include <map>

#include "Connection.h"
#include "DotNetMessageFormat.h"
#include "Core/Utilities/Log/MuLogger.h"

// Full definitions required: Connection.cpp allocates these types (new PacketFunctions_*()).
// Connection.h uses only forward declarations to avoid include-order failures in TUs
// that pull it in transitively through WSclient.h.
#include "PacketFunctions_ChatServer.h"
#include "PacketFunctions_ConnectServer.h"
#include "PacketFunctions_ClientToServer.h"

// MEDIUM-4 fix: g_dotnetLibPath defined here (not in anonymous namespace in header) to prevent
// per-TU copies if Connection.h is ever included by a second translation unit.
// Declaration (extern) remains in Connection.h; only Connection.cpp includes Connection.h today.
#ifdef __EMSCRIPTEN__
const std::string g_dotnetLibPath = "wasm-network";
const mu::platform::LibraryHandle munique_client_library_handle = nullptr;
#else
const std::string g_dotnetLibPath = ManagedLibraryPath();

const mu::platform::LibraryHandle munique_client_library_handle =
    mu::platform::Load(g_dotnetLibPath.c_str());
#endif

namespace
{
enum class ManagedLogLevel : BYTE
{
    Debug,
    Info,
    Warning,
    Error,
    Critical,
};

void CORECLR_DELEGATE_CALLTYPE WriteManagedLog(BYTE level, const char* message)
{
    const auto logger = mu::log::Get("dotnet");
    const char* safeMessage = message != nullptr ? message : "<null managed log message>";
    switch (static_cast<ManagedLogLevel>(level))
    {
    case ManagedLogLevel::Debug:
        logger->debug("{}", safeMessage);
        break;
    case ManagedLogLevel::Info:
        logger->info("{}", safeMessage);
        break;
    case ManagedLogLevel::Warning:
        logger->warn("{}", safeMessage);
        break;
    case ManagedLogLevel::Error:
        logger->error("{}", safeMessage);
        break;
    case ManagedLogLevel::Critical:
        logger->critical("{}", safeMessage);
        break;
    }
}

using ManagedLogCallback = void(CORECLR_DELEGATE_CALLTYPE*)(BYTE, const char*);
using SetManagedLogCallback = void(CORECLR_DELEGATE_CALLTYPE*)(ManagedLogCallback);

} // anonymous namespace

void InitializeDotNetBridge()
{
#ifdef __EMSCRIPTEN__
    mu::log::Get("dotnet")->info("NET: InitializeDotNetBridge -- WASM WebSocket bridge active");
#else
    if (!munique_client_library_handle)
    {
        mu::log::Get("dotnet")->error("NET: InitializeDotNetBridge -- library not loaded, skipping");
        return;
    }

    const auto setManagedLogCallback =
        LoadManagedSymbol<SetManagedLogCallback>("ConnectionManager_SetLogCallback");
    if (setManagedLogCallback != nullptr)
    {
        setManagedLogCallback(&WriteManagedLog);
    }
#endif
}

std::map<int32_t, Connection*> connections;

namespace DotNetBridge
{
bool g_dotnetErrorDisplayed = false;

// AC-1 + AC-2 + AC-7: Structured error reporting for DotNet bridge failures.
// Distinguishes library-not-found vs symbol-not-found via DotNetErrorKind.
// Writes to BOTH spdlog (persistent MuError.log) AND MessageBoxW dialog
// (mapped to SDL_ShowSimpleMessageBox via PlatformCompat.h shim).
// AC-STD-NFR-1: Dialog shown at most ONCE per session via g_dotnetErrorDisplayed guard.
// AC-STD-NFR-2: Called from main game thread only (single-threaded game loop).
void ReportDotNetError(const char* detail, DotNetErrorKind kind)
{
    if (g_dotnetErrorDisplayed)
    {
        return;
    }
    g_dotnetErrorDisplayed = true;

    // Determine platform name for AC-1 message (compile-time, impl file only — acceptable
    // per Dev Notes §Key Design Decisions: diagnostic string in implementation file).
    const char* platformName =
#if defined(__linux__)
        "Linux";
#elif defined(__APPLE__)
        "macOS";
#else
        "Windows";
#endif

    std::string msg;
    if (kind == DotNetErrorKind::LibraryNotFound)
    {
        // AC-1: Library not found — include resolved path and platform
        msg = FormatLibraryNotFoundMessage(g_dotnetLibPath, platformName);
    }
    else
    {
        // AC-2: Symbol not found — include function name
        msg = FormatSymbolNotFoundMessage(detail);
    }

    // Write to MuError.log (persistent diagnostic — spdlog)
    mu::log::Get("dotnet")->error("NET: {}", msg);

    // Show user-visible dialog via MessageBoxW shim → SDL_ShowSimpleMessageBox (PlatformCompat.h)
    // ASCII-safe conversion: diagnostic messages contain only ASCII characters
    std::wstring wideMsg(msg.begin(), msg.end());
    MessageBoxW(nullptr, wideMsg.c_str(), L"Network Error", MB_ICONERROR | MB_OK);
}

bool IsManagedLibraryAvailable()
{
#ifdef __EMSCRIPTEN__
    return true;
#else
    if (munique_client_library_handle)
    {
        return true;
    }

    ReportDotNetError(nullptr, DotNetErrorKind::LibraryNotFound);
    return false;
#endif
}
} // namespace DotNetBridge

namespace
{
using onPacketReceived = void(int32_t, int32_t, BYTE*);
using onDisconnected = void(int32_t);

typedef int32_t(CORECLR_DELEGATE_CALLTYPE* Connect)(const char16_t*, int32_t, BYTE, onPacketReceived, onDisconnected);
typedef void(CORECLR_DELEGATE_CALLTYPE* Disconnect)(int32_t);
typedef void(CORECLR_DELEGATE_CALLTYPE* BeginReceive)(int32_t);
typedef void(CORECLR_DELEGATE_CALLTYPE* Send)(int32_t, const BYTE*, int32_t);

#ifdef __EMSCRIPTEN__
#include <emscripten/websocket.h>

namespace
{
struct WasmConnectionState
{
    int32_t handle = 0;
    EMSCRIPTEN_WEBSOCKET_T ws = 0;
    bool isConnected = false;
    onPacketReceived* packetCallback = nullptr;
    onDisconnected* disconnectCallback = nullptr;
};

std::map<int32_t, WasmConnectionState> g_wasmConnections;
int32_t g_nextWasmHandle = 1;

EM_BOOL OnWsOpen(int eventType, const EmscriptenWebSocketOpenEvent* websocketEvent, void* userData)
{
    const int32_t handle = static_cast<int32_t>(reinterpret_cast<intptr_t>(userData));
    mu::log::Get("dotnet")->info("NET [WASM]: WebSocket opened, handle={}", handle);
    auto it = g_wasmConnections.find(handle);
    if (it != g_wasmConnections.end())
    {
        it->second.isConnected = true;
    }
    return EM_TRUE;
}

EM_BOOL OnWsClose(int eventType, const EmscriptenWebSocketCloseEvent* websocketEvent, void* userData)
{
    const int32_t handle = static_cast<int32_t>(reinterpret_cast<intptr_t>(userData));
    mu::log::Get("dotnet")->info("NET [WASM]: WebSocket closed, handle={}, code={}, reason={}",
                                 handle, websocketEvent->code, websocketEvent->reason);
    auto it = g_wasmConnections.find(handle);
    if (it != g_wasmConnections.end())
    {
        it->second.isConnected = false;
        if (it->second.disconnectCallback)
        {
            it->second.disconnectCallback(handle);
        }
        g_wasmConnections.erase(it);
    }
    return EM_TRUE;
}

EM_BOOL OnWsError(int eventType, const EmscriptenWebSocketErrorEvent* websocketEvent, void* userData)
{
    const int32_t handle = static_cast<int32_t>(reinterpret_cast<intptr_t>(userData));
    mu::log::Get("dotnet")->error("NET [WASM]: WebSocket error on handle={}", handle);
    return EM_TRUE;
}

EM_BOOL OnWsMessage(int eventType, const EmscriptenWebSocketMessageEvent* websocketEvent, void* userData)
{
    const int32_t handle = static_cast<int32_t>(reinterpret_cast<intptr_t>(userData));
    if (!websocketEvent->isText && websocketEvent->numBytes > 0)
    {
        auto it = g_wasmConnections.find(handle);
        if (it != g_wasmConnections.end() && it->second.packetCallback)
        {
            it->second.packetCallback(handle, websocketEvent->numBytes, const_cast<BYTE*>(websocketEvent->data));
        }
    }
    return EM_TRUE;
}

int32_t CORECLR_DELEGATE_CALLTYPE Wasm_Connect(const char16_t* host, int32_t port, BYTE isEncrypted,
                                              onPacketReceived onReceived, onDisconnected onDisc)
{
    if (!emscripten_websocket_is_supported())
    {
        mu::log::Get("dotnet")->error("NET [WASM]: WebSockets not supported in browser!");
        return -1;
    }

    const int32_t handle = g_nextWasmHandle++;

    std::string hostStr;
    if (host)
    {
        for (const char16_t* p = host; *p; ++p)
        {
            hostStr += static_cast<char>(*p);
        }
    }
    if (hostStr.empty() || hostStr == "localhost")
    {
        hostStr = "127.0.0.1";
    }

    // openmu-browser-stack proxy is on port 7100
    std::string wsUrl = "ws://" + hostStr + ":7100";

    EmscriptenWebSocketCreateAttributes wsAttrs;
    emscripten_websocket_init_create_attributes(&wsAttrs);
    wsAttrs.url = wsUrl.c_str();

    mu::log::Get("dotnet")->info("NET [WASM]: Connecting WebSocket to {} (handle={}, targetPort={})",
                                 wsUrl, handle, port);

    EMSCRIPTEN_WEBSOCKET_T ws = emscripten_websocket_new(&wsAttrs);
    if (ws <= 0)
    {
        mu::log::Get("dotnet")->error("NET [WASM]: Failed to create WebSocket for {}", wsUrl);
        return -1;
    }

    void* userData = reinterpret_cast<void*>(static_cast<intptr_t>(handle));
    emscripten_websocket_set_onopen_callback(ws, userData, OnWsOpen);
    emscripten_websocket_set_onclose_callback(ws, userData, OnWsClose);
    emscripten_websocket_set_onerror_callback(ws, userData, OnWsError);
    emscripten_websocket_set_onmessage_callback(ws, userData, OnWsMessage);

    WasmConnectionState state;
    state.handle = handle;
    state.ws = ws;
    state.isConnected = true;
    state.packetCallback = onReceived;
    state.disconnectCallback = onDisc;

    g_wasmConnections[handle] = state;
    return handle;
}

void CORECLR_DELEGATE_CALLTYPE Wasm_Send(int32_t handle, const BYTE* data, int32_t size)
{
    auto it = g_wasmConnections.find(handle);
    if (it != g_wasmConnections.end() && it->second.ws > 0)
    {
        emscripten_websocket_send_binary(it->second.ws, const_cast<void*>(static_cast<const void*>(data)), size);
    }
}

void CORECLR_DELEGATE_CALLTYPE Wasm_Disconnect(int32_t handle)
{
    auto it = g_wasmConnections.find(handle);
    if (it != g_wasmConnections.end() && it->second.ws > 0)
    {
        emscripten_websocket_close(it->second.ws, 1000, "Normal closure");
        it->second.ws = 0;
        it->second.isConnected = false;
        g_wasmConnections.erase(it);
    }
}

void CORECLR_DELEGATE_CALLTYPE Wasm_BeginReceive(int32_t handle)
{
}
} // namespace

Connect GetConnect() { return &Wasm_Connect; }
Disconnect GetDisconnect() { return &Wasm_Disconnect; }
BeginReceive GetBeginReceive() { return &Wasm_BeginReceive; }
Send GetSend() { return &Wasm_Send; }
#else
Connect GetConnect()
{
    static const auto function = LoadManagedSymbol<Connect>("ConnectionManager_Connect");
    return function;
}

Disconnect GetDisconnect()
{
    static const auto function = LoadManagedSymbol<Disconnect>("ConnectionManager_Disconnect");
    return function;
}

BeginReceive GetBeginReceive()
{
    static const auto function = LoadManagedSymbol<BeginReceive>("ConnectionManager_BeginReceive");
    return function;
}

Send GetSend()
{
    static const auto function = LoadManagedSymbol<Send>("ConnectionManager_Send");
    return function;
}
#endif
} // anonymous namespace

void Connection::OnPacketReceivedS(const int32_t handle, const int32_t size, BYTE* data)
{
    const auto it = connections.find(handle);
    if (it == connections.end())
    {
        return;
    }

    if (Connection* connection = it->second)
    {
        connection->OnPacketReceived(data, size);
    }
}

void Connection::OnDisconnectedS(const int32_t handle)
{
    const auto it = connections.find(handle);
    if (it == connections.end())
    {
        return;
    }

    if (Connection* connection = it->second)
    {
        connection->OnDisconnected();
    }
}

Connection::Connection(const char16_t* host, int32_t port, bool isEncrypted,
                       void (*packetHandler)(int32_t, const BYTE*, int32_t))
{
    this->_packetHandler = packetHandler;
    const auto connect = GetConnect();
    if (!connect)
    {
        this->_handle = 0;
        return;
    }

    this->_handle = connect(host, port, isEncrypted ? 1 : 0, &OnPacketReceivedS, &OnDisconnectedS);

    mu::log::Get("dotnet")->info("NET: dotnet_connect returned handle={} (encrypted={})",
                                this->_handle, isEncrypted ? 1 : 0);

    if (IsConnected())
    {
        connections[this->_handle] = this;
        if (const auto beginReceive = GetBeginReceive())
        {
            beginReceive(this->_handle);
            mu::log::Get("dotnet")->info("NET: BeginReceive started for handle={}", this->_handle);
        }

        // cppcheck-suppress [noCopyConstructor, noOperatorEq]
        _chatServer = new PacketFunctions_ChatServer();
        _connectServer = new PacketFunctions_ConnectServer();
        _gameServer = new PacketFunctions_ClientToServer();

        _chatServer->SetHandle(this->_handle);
        _connectServer->SetHandle(this->_handle);
        _gameServer->SetHandle(this->_handle);
    }
}

Connection::~Connection()
{
    if (!IsConnected())
    {
        return;
    }

    if (const auto disconnect = GetDisconnect())
    {
        disconnect(_handle);
    }

    SAFE_DELETE(_chatServer);
    SAFE_DELETE(_connectServer);
    SAFE_DELETE(_gameServer);
}

bool Connection::IsConnected()
{
    return this->_handle > 0;
}

void Connection::Send(const BYTE* data, const int32_t size)
{
    if (!IsConnected())
    {
        return;
    }

    const auto send = GetSend();
    if (!send)
    {
        return;
    }

    send(this->_handle, data, size);
}

void Connection::Close()
{
    if (!IsConnected())
    {
        return;
    }

    if (const auto disconnect = GetDisconnect())
    {
        disconnect(this->_handle);
    }
}

void Connection::OnDisconnected()
{
    if (!IsConnected())
    {
        mu::log::Get("dotnet")->info("NET: OnDisconnected called but already disconnected");
        return;
    }

    mu::log::Get("dotnet")->info("NET: OnDisconnected -- handle={}, erasing from connection map", this->_handle);
    connections.erase(this->_handle);
    this->_handle = 0;
}

void Connection::OnPacketReceived(const BYTE* data, const int32_t size)
{
    if (!this->_firstPacketLogged)
    {
        mu::log::Get("dotnet")->info("NET: First packet received -- handle={} size={} (callback path working)",
                                    this->_handle, size);
        this->_firstPacketLogged = true;
    }
    this->_packetHandler(this->_handle, data, size);
}


void Connection_SendRaw(int32_t handle, const BYTE* data, int32_t size)
{
    const auto it = connections.find(handle);
    if (it != connections.end() && it->second != nullptr)
    {
        it->second->Send(data, size);
    }
#ifdef __EMSCRIPTEN__
    else
    {
        Wasm_Send(handle, data, size);
    }
#endif
}


#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#include "UI/Windows/ServerSelWin.h"
#include "UI/Windows/LoginWin.h"
#include "Scenes/CharacterScene.h"
#include "Scenes/SceneCommon.h"

extern int CurrentProtocolState;
extern int SelectedCharacter;

namespace Scenes {
    bool StartGameWithSlot(int slot);
}

extern "C" {

EMSCRIPTEN_KEEPALIVE
int MuWeb_GetProtocolState()
{
    return CurrentProtocolState;
}

EMSCRIPTEN_KEEPALIVE
bool MuWeb_SelectServer(int serverIndex)
{
    mu::log::Get("dotnet")->info("NET [WASM]: MuWeb_SelectServer called, index={}", serverIndex);
    return g_ServerSelWin.SelectServer(nullptr, serverIndex);
}

EMSCRIPTEN_KEEPALIVE
bool MuWeb_SubmitLogin(const char* username, const char* password)
{
    mu::log::Get("dotnet")->info("NET [WASM]: MuWeb_SubmitLogin called for user={}", username ? username : "null");
    if (!username || !password) return false;
    std::wstring wUser(username, username + strlen(username));
    std::wstring wPass(password, password + strlen(password));
    g_LoginWin.SubmitCredentials(wUser.c_str(), wPass.c_str());
    return true;
}

EMSCRIPTEN_KEEPALIVE
bool MuWeb_EnterWorld(int heroIndex)
{
    mu::log::Get("dotnet")->info("NET [WASM]: MuWeb_EnterWorld called, heroIndex={}", heroIndex);
    SelectedCharacter = heroIndex;
    SelectedHero = heroIndex;
    return Scenes::StartGameWithSlot(heroIndex);
}

} // extern "C"
#endif
