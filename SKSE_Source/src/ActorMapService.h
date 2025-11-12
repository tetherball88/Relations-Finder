#pragma once

#include "RE/Skyrim.h"

namespace ActorMapService {

    // Build or rebuild the map from ActorBase (TESNPC*) to live Actor instance.
    void RebuildBaseToActorMap();

    // Lookup a live Actor by its base (TESNPC*). Returns nullptr if not found or handle stale.
    RE::Actor* GetActorByBase(RE::TESNPC* base) noexcept;

}  // namespace ActorMapService
