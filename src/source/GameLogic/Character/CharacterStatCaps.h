#pragma once

#include <algorithm>
#include <cstdint>

namespace GameLogic::Character
{
    // Base attributes are stored in 16-bit fields, both in CHARACTER_ATTRIBUTE and in the
    // stat packets. 65535 is therefore the largest value the client can hold and display.
    inline constexpr std::uint16_t MaxStatValue = 0xFFFF;

    inline std::uint16_t ClampStatValue(std::uint32_t value)
    {
        return static_cast<std::uint16_t>(std::min<std::uint32_t>(value, MaxStatValue));
    }

    inline std::uint16_t AddStatValue(std::uint16_t current, std::uint32_t added)
    {
        return ClampStatValue(static_cast<std::uint32_t>(current) + added);
    }
} // namespace GameLogic::Character
