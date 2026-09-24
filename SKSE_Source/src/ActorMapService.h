#pragma once

#include "RE/Skyrim.h"

namespace ActorMapService {

    // Build or rebuild the map from ActorBase (TESNPC*) to live Actor instance.
    void RebuildBaseToActorMap();

    // Incrementally scan the high and middle-high process lists and insert any actors with
    // relationships that are not yet in the map. Also prunes entries whose handles have gone stale.
    // Call this whenever a new cell finishes loading.
    void UpdateMapFromHighActors();

    // Lookup a live Actor by its base (TESNPC*). Returns nullptr if not found or handle stale.
    RE::Actor* GetActorByBase(RE::TESNPC* base) noexcept;

}  // namespace ActorMapService
