#include "doctest.h"
#include "GameLogic/Character/CharacterStatCaps.h"

using GameLogic::Character::AddStatValue;
using GameLogic::Character::ClampStatValue;
using GameLogic::Character::MaxStatValue;

TEST_CASE("stat caps keep the client's 16-bit attributes from wrapping")
{
    CHECK(MaxStatValue == 0xFFFF);
    CHECK(ClampStatValue(0) == 0);
    CHECK(ClampStatValue(65534) == 65534);
    CHECK(ClampStatValue(65535) == 65535);
    CHECK(ClampStatValue(65536) == 65535);
    CHECK(ClampStatValue(100000) == 65535);
}

TEST_CASE("adding a stat point saturates at the 16-bit maximum instead of wrapping to zero")
{
    CHECK(AddStatValue(0, 1) == 1);
    CHECK(AddStatValue(65534, 1) == 65535);
    CHECK(AddStatValue(65535, 1) == 65535);
    CHECK(AddStatValue(65535, 100) == 65535);
    CHECK(AddStatValue(65534, 100) == 65535);
}
