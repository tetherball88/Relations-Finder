
#include "ActorMapService.h"

#include <chrono>
#include <shared_mutex>

#include "../PCH.h"  // for SKSE::log

using BaseToActorMap = std::unordered_map<RE::TESNPC*, RE::ActorHandle>;
static BaseToActorMap g_baseToActor;
static std::shared_mutex g_baseToActorMutex;

namespace ActorMapService {

    static bool HasRelationships(const RE::TESNPC* npc) noexcept {
        if (!npc) {
            return false;
        }

        const auto* relArray = npc->relationships;
        if (!relArray || relArray->empty()) {
            return false;
        }

        // Check if any relationship is non-null
        for (const auto* rel : *relArray) {
            if (rel) {
                return true;
            }
        }

        return false;
    }

    void RebuildBaseToActorMap() {
        std::size_t addedCount = 0;
        std::size_t scannedCount = 0;

        // Scoped timer will log elapsed time when this function exits (even on early return)
        struct ScopedTimer {
            const char* name;
            std::size_t* addedPtr;
            std::size_t* scannedPtr;
            std::chrono::steady_clock::time_point start;
            ScopedTimer(const char* n, std::size_t* a, std::size_t* s) noexcept
                : name(n), addedPtr(a), scannedPtr(s), start(std::chrono::steady_clock::now()) {}
            ~ScopedTimer() noexcept {
                using ms = std::chrono::duration<double, std::milli>;
                const auto dur = std::chrono::steady_clock::now() - start;
                const double elapsed = std::chrono::duration_cast<ms>(dur).count();
                const std::size_t added = addedPtr ? *addedPtr : 0;
                const std::size_t scanned = scannedPtr ? *scannedPtr : 0;
                SKSE::log::info("{} took {:.3f} ms (scanned {} actors, added {} with relationships)", name, elapsed,
                                scanned, added);
            }
        } timer("RebuildBaseToActorMap", &addedCount, &scannedCount);

        // Acquire exclusive lock for writing
        std::unique_lock lock(g_baseToActorMutex);
        g_baseToActor.clear();

        const auto* pl = RE::ProcessLists::GetSingleton();
        if (!pl) {
            SKSE::log::warn("RebuildBaseToActorMap: ProcessLists singleton is null");
            return;
        }

        for (const auto* actorHandles : pl->allProcesses) {
            if (!actorHandles) {
                continue;
            }

            for (const auto& actorHandle : *actorHandles) {
                const auto actorPtr = actorHandle.get();
                if (!actorPtr) {
                    continue;
                }

                auto* actor = actorPtr.get();
                if (!actor) {
                    continue;
                }

                ++scannedCount;

                auto* base = actor->GetActorBase();
                if (!base) {
                    continue;
                }

                auto* npc = base->As<RE::TESNPC>();
                if (!npc) {
                    continue;
                }

                // Only track bases that actually have relationships
                if (!HasRelationships(npc)) {
                    continue;
                }

                // Insert or update the mapping
                g_baseToActor.insert_or_assign(npc, actorHandle);
                ++addedCount;
            }
        }
    }

    RE::Actor* GetActorByBase(RE::TESNPC* base) noexcept {
        if (!base) {
            return nullptr;
        }

        // Acquire shared lock for reading
        std::shared_lock lock(g_baseToActorMutex);

        const auto it = g_baseToActor.find(base);
        if (it == g_baseToActor.end()) {
            return nullptr;
        }

        const auto& handle = it->second;
        const auto actorPtr = handle.get();
        return actorPtr ? actorPtr.get() : nullptr;
    }

}  // namespace ActorMapService