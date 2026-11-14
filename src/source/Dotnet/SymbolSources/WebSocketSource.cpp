// The web target's network library adapter (cmake/targets/web.cmake): the browser has no NativeAOT library, so the
// connection's exports are implemented here over a WebSocket to the openmu-browser-stack proxy, which forwards the
// bytes to the server's TCP port. The packet senders build their packets themselves (Connection_SendRaw).
#include "stdafx.h"

#include "Dotnet/ManagedSymbols.h"
#include "Core/Utilities/Log/MuLogger.h"

#include <coreclr_delegates.h>
#include <emscripten/websocket.h>

#include <cstring>
#include <map>
#include <string>
#include <vector>

namespace
{
using onPacketReceived = void(int32_t, int32_t, BYTE*);
using onHandle = void(int32_t);

// The openmu-browser-stack proxy listens here, whatever server port the client asks for.
constexpr int kProxyPort = 7100;

struct WebSocketConnection
{
    EMSCRIPTEN_WEBSOCKET_T socket = 0;
    bool open = false;
    onPacketReceived* packetCallback = nullptr;
    onHandle* disconnectCallback = nullptr;
    onHandle* openCallback = nullptr;
    // Sends made while connecting, sent once the socket opens.
    std::vector<std::vector<BYTE>> pending;
};

// The browser runs the callbacks on the main thread, between frames, so no lock is needed.
std::map<int32_t, WebSocketConnection> g_connections;
int32_t g_nextHandle = 1;

int32_t HandleOf(void* userData)
{
    return static_cast<int32_t>(reinterpret_cast<intptr_t>(userData));
}

EM_BOOL OnOpen(int, const EmscriptenWebSocketOpenEvent*, void* userData)
{
    const int32_t handle = HandleOf(userData);
    mu::log::Get("dotnet")->info("NET [WASM]: WebSocket opened, handle={}", handle);
    const auto found = g_connections.find(handle);
    if (found == g_connections.end())
    {
        return EM_TRUE;
    }

    WebSocketConnection& connection = found->second;
    connection.open = true;
    for (auto& packet : connection.pending)
    {
        emscripten_websocket_send_binary(connection.socket, packet.data(), static_cast<uint32_t>(packet.size()));
    }
    connection.pending.clear();
    if (connection.openCallback != nullptr)
    {
        connection.openCallback(handle);
    }
    return EM_TRUE;
}

EM_BOOL OnClose(int, const EmscriptenWebSocketCloseEvent* event, void* userData)
{
    const int32_t handle = HandleOf(userData);
    mu::log::Get("dotnet")->info("NET [WASM]: WebSocket closed, handle={}, code={}, reason={}", handle, event->code,
                                 event->reason);
    const auto found = g_connections.find(handle);
    if (found == g_connections.end())
    {
        return EM_TRUE;
    }

    onHandle* const disconnected = found->second.disconnectCallback;
    g_connections.erase(found);
    if (disconnected != nullptr)
    {
        disconnected(handle);
    }
    return EM_TRUE;
}

EM_BOOL OnError(int, const EmscriptenWebSocketErrorEvent*, void* userData)
{
    mu::log::Get("dotnet")->error("NET [WASM]: WebSocket error on handle={}", HandleOf(userData));
    return EM_TRUE;
}

EM_BOOL OnMessage(int, const EmscriptenWebSocketMessageEvent* event, void* userData)
{
    if (event->isText || event->numBytes == 0)
    {
        return EM_TRUE;
    }

    const int32_t handle = HandleOf(userData);
    const auto found = g_connections.find(handle);
    if (found != g_connections.end() && found->second.packetCallback != nullptr)
    {
        found->second.packetCallback(handle, static_cast<int32_t>(event->numBytes), event->data);
    }
    return EM_TRUE;
}

int32_t CORECLR_DELEGATE_CALLTYPE BeginConnect(const char16_t* host, int32_t port, BYTE, onPacketReceived onReceived,
                                               onHandle onDisconnected, onHandle onOpened)
{
    if (!emscripten_websocket_is_supported())
    {
        mu::log::Get("dotnet")->error("NET [WASM]: this browser has no WebSockets");
        return -1;
    }

    std::string hostName;
    for (const char16_t* character = host; character != nullptr && *character != u'\0'; ++character)
    {
        hostName += static_cast<char>(*character);
    }
    if (hostName.empty() || hostName == "localhost")
    {
        hostName = "127.0.0.1";
    }
    const std::string url = "ws://" + hostName + ":" + std::to_string(kProxyPort);

    EmscriptenWebSocketCreateAttributes attributes;
    emscripten_websocket_init_create_attributes(&attributes);
    attributes.url = url.c_str();

    const int32_t handle = g_nextHandle++;
    mu::log::Get("dotnet")->info("NET [WASM]: connecting WebSocket to {} (handle={}, server port={})", url, handle,
                                 port);
    const EMSCRIPTEN_WEBSOCKET_T socket = emscripten_websocket_new(&attributes);
    if (socket <= 0)
    {
        mu::log::Get("dotnet")->error("NET [WASM]: could not create a WebSocket for {}", url);
        return -1;
    }

    WebSocketConnection& connection = g_connections[handle];
    connection.socket = socket;
    connection.packetCallback = onReceived;
    connection.disconnectCallback = onDisconnected;
    connection.openCallback = onOpened;

    void* const userData = reinterpret_cast<void*>(static_cast<intptr_t>(handle));
    emscripten_websocket_set_onopen_callback(socket, userData, OnOpen);
    emscripten_websocket_set_onclose_callback(socket, userData, OnClose);
    emscripten_websocket_set_onerror_callback(socket, userData, OnError);
    emscripten_websocket_set_onmessage_callback(socket, userData, OnMessage);
    return handle;
}

void CORECLR_DELEGATE_CALLTYPE Send(int32_t handle, const BYTE* data, int32_t size)
{
    const auto found = g_connections.find(handle);
    if (found == g_connections.end() || size <= 0)
    {
        return;
    }

    WebSocketConnection& connection = found->second;
    if (!connection.open)
    {
        connection.pending.emplace_back(data, data + size);
        return;
    }
    emscripten_websocket_send_binary(connection.socket, const_cast<BYTE*>(data), static_cast<uint32_t>(size));
}

// Closed by the client itself: Connection already treats it as closed, so no disconnect callback follows.
void CORECLR_DELEGATE_CALLTYPE Disconnect(int32_t handle)
{
    const auto found = g_connections.find(handle);
    if (found == g_connections.end())
    {
        return;
    }

    const EMSCRIPTEN_WEBSOCKET_T socket = found->second.socket;
    g_connections.erase(found);
    emscripten_websocket_close(socket, 1000, "Normal closure");
    emscripten_websocket_delete(socket);
}

// The socket delivers what arrives from the start.
void CORECLR_DELEGATE_CALLTYPE BeginReceive(int32_t) {}

void* FindExport(const char* name)
{
    const std::string_view wanted = name;
    if (wanted == "ConnectionManager_BeginConnect")
    {
        return reinterpret_cast<void*>(&BeginConnect);
    }
    if (wanted == "ConnectionManager_Disconnect")
    {
        return reinterpret_cast<void*>(&Disconnect);
    }
    if (wanted == "ConnectionManager_BeginReceive")
    {
        return reinterpret_cast<void*>(&BeginReceive);
    }
    if (wanted == "ConnectionManager_Send")
    {
        return reinterpret_cast<void*>(&Send);
    }
    return nullptr;
}
} // namespace

DotNetBridge::ManagedSymbolSource DotNetBridge::TargetManagedSymbolSource()
{
    return {"browser WebSocket bridge", &FindExport};
}
