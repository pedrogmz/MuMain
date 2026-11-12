// The client's entry point on every platform. SDL runs the loop and calls these once each: init, then an event or
// a frame at a time, then quit, even after a failed init. The browser and Android drive it the same way.
#define SDL_MAIN_USE_CALLBACKS
#include <SDL3/SDL_main.h>

#include "App/Platform/ClientMain.h"

#include <cstdio>
#include <exception>
#include <string>

namespace
{
// An exception that leaves a callback ends the client with its message on stderr (the browser's console on the web
// build, where an uncaught one only shows as a pointer).
template <typename Callback> SDL_AppResult GuardCallback(const char* name, Callback&& callback)
{
    try
    {
        return callback();
    }
    catch (const std::exception& exception)
    {
        std::fprintf(stderr, "[MuMain FATAL EXCEPTION] %s: %s\n", name, exception.what());
    }
    catch (...)
    {
        std::fprintf(stderr, "[MuMain FATAL UNKNOWN EXCEPTION] %s\n", name);
    }
    std::fflush(stderr);
    return SDL_APP_FAILURE;
}
} // namespace

SDL_AppResult SDL_AppInit(void** /*appState*/, int argc, char* argv[])
{
    std::string commandLine;
    for (int index = 1; index < argc; ++index)
    {
        if (!commandLine.empty())
            commandLine += ' ';
        commandLine += argv[index];
    }
    return GuardCallback("init",
                         [&] { return StartClient(commandLine.data()) ? SDL_APP_CONTINUE : SDL_APP_FAILURE; });
}

SDL_AppResult SDL_AppEvent(void* /*appState*/, SDL_Event* event)
{
    return GuardCallback("event", [&] { return HandleClientEvent(*event) ? SDL_APP_CONTINUE : SDL_APP_SUCCESS; });
}

SDL_AppResult SDL_AppIterate(void* /*appState*/)
{
    return GuardCallback("frame", [] { return IterateClient() ? SDL_APP_CONTINUE : SDL_APP_SUCCESS; });
}

void SDL_AppQuit(void* /*appState*/, SDL_AppResult /*result*/)
{
    ShutdownClient();
}
