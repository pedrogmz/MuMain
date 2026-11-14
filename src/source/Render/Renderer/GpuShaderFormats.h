#pragma once

#include <SDL3/SDL_gpu.h>
#ifdef __EMSCRIPTEN__
#include <XDL_wgpu.h>
#endif

#include <array>
#include <string>

namespace Render
{

// One shader format the build ships: how the device is asked for it, the blob file extension and the entry point.
struct ShaderFormat
{
    SDL_GPUShaderFormat format;
    const char* createProperty;
    const char* extension;
    const char* entrypoint;
};

// In order of preference: a device that accepts several of these gets the first.
inline constexpr std::array kShaderFormats{
#ifdef __EMSCRIPTEN__
    // The browser's WebGPU backend (XDL_wgpu) takes WGSL source.
    ShaderFormat{SDL_GPU_SHADERFORMAT_WGSL, SDL_PROP_GPU_DEVICE_CREATE_SHADERS_WGSL_BOOLEAN, "wgsl", "main"},
#endif
    ShaderFormat{SDL_GPU_SHADERFORMAT_SPIRV, SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN, "spv", "main"},
    ShaderFormat{SDL_GPU_SHADERFORMAT_DXIL, SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN, "dxil", "main"},
    // spirv-cross renames "main" to "main0" in MSL because Metal reserves "main".
    ShaderFormat{SDL_GPU_SHADERFORMAT_MSL, SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN, "msl", "main0"},
};

// The first shipped format among `accepted` (SDL_GetGPUShaderFormats), or nullptr when the device takes none.
[[nodiscard]] inline const ShaderFormat* PickShaderFormat(SDL_GPUShaderFormat accepted)
{
    for (const ShaderFormat& entry : kShaderFormats)
    {
        if (accepted & entry.format)
        {
            return &entry;
        }
    }
    return nullptr;
}

// The shipped extensions, "spv, dxil, msl", for error messages.
[[nodiscard]] inline std::string ShaderFormatNames()
{
    std::string names;
    for (const ShaderFormat& entry : kShaderFormats)
    {
        names += names.empty() ? "" : ", ";
        names += entry.extension;
    }
    return names;
}

} // namespace Render
