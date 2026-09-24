#pragma once
#include <cstdint>
#include <windows.h>

// Forward declaration — consumers only need the pointer type; no CommonLibSSE-NG header required.
namespace RE { class Actor; }

/**
 * RelationsFinder Public API — resolved at runtime via GetModuleHandle + GetProcAddress.
 *
 * Drop this header into your SKSE plugin project (requires CommonLibSSE-NG).
 * Call FindFunctions() once during your SKSE kDataLoaded handler. If it returns
 * true, all function pointers below are ready to use.
 *
 * ## Quick start
 *
 * @code
 *   // In your kDataLoaded handler:
 *   void OnDataLoaded() {
 *       if (!RelationsFinderAPI::FindFunctions()) {
 *           logger::warn("RelationsFinder not found — relationship queries unavailable");
 *           return;
 *       }
 *       logger::info("RelationsFinder API v{}", RelationsFinderAPI::GetVersion());
 *   }
 *
 *   // Later, to find all relatives of an NPC:
 *   void PrintRelatives(RE::Actor* npc) {
 *       if (!RelationsFinderAPI::GetNpcRelationships) return;
 *
 *       RelationsFinderAPI::GetNpcRelationships(
 *           npc,
 *           "",          // associationType — empty = any
 *           "",          // hierarchy       — empty = any
 *           -4,          // minRelationshipRank — INT32_MIN disables; -4 = any rank
 *           INT32_MIN,   // exactRelationshipRank — INT32_MIN = disabled
 *           [](RE::Actor* relative, void* userData) {
 *               logger::info("Found relative: {}", relative->GetName());
 *           },
 *           nullptr      // userData forwarded to every callback call
 *       );
 *   }
 * @endcode
 *
 * ## Parameters for GetNpcRelationships
 *
 * associationType       — keyword name filter, e.g. "PotentialMarriageFaction" (empty = any).
 * hierarchy             — relationship role, e.g. "Parent", "Child", "Sibling" (empty = any).
 * minRelationshipRank   — minimum relationship rank in the range [-4, 4].
 *                         Ignored when exactRelationshipRank is not INT32_MIN.
 * exactRelationshipRank — exact relationship rank to match, or INT32_MIN to disable
 *                         exact-match and use minRelationshipRank instead.
 * callback              — invoked once per matching Actor*. Must not be null.
 * userData              — arbitrary pointer forwarded to every callback call.
 *
 * ## ABI notes
 *
 * Both plugins must be compiled with MSVC and link the same CRT (/MD or /MT).
 * All CommonLibSSE-NG SKSE plugins satisfy this constraint.
 * The callback is invoked on the caller's thread — no extra synchronisation needed.
 */

namespace RelationsFinderAPI {

    // Invoked once per actor matching the query.
    // actor    — the live RE::Actor* with the matching relationship.
    // userData — the pointer you passed to GetNpcRelationships.
    using RelationshipCallbackFn = void (*)(RE::Actor* actor, void* userData);

    // Invoked once per matching actor's name.
    // name     — the display name of the matching actor (valid only during the call).
    // userData — the pointer you passed to GetNpcRelationshipNames.
    using RelationshipNameCallbackFn = void (*)(const char* name, void* userData);

    // v1: Returns the API version compiled into RelationsFinder.dll (currently 1).
    inline int (*GetVersion)() = nullptr;

    // v1: Find all live actors related to `npc` that satisfy the given filters and
    //     invoke `callback` once per match. Safe to call across DLL boundaries.
    inline void (*GetNpcRelationships)(RE::Actor* npc,
                                       const char* associationType,
                                       const char* hierarchy,
                                       std::int32_t minRelationshipRank,
                                       std::int32_t exactRelationshipRank,
                                       RelationshipCallbackFn callback,
                                       void* userData) = nullptr;

    // v1: Same as GetNpcRelationships but delivers only the display name of each
    //     matching actor. Useful when you only need names and want to avoid
    //     holding RE::Actor* pointers beyond the callback.
    inline void (*GetNpcRelationshipNames)(RE::Actor* npc,
                                           const char* associationType,
                                           const char* hierarchy,
                                           std::int32_t minRelationshipRank,
                                           std::int32_t exactRelationshipRank,
                                           RelationshipNameCallbackFn callback,
                                           void* userData) = nullptr;

    // Resolves all function pointers above by locating RelationsFinder.dll.
    // Call once during SKSE kDataLoaded. Returns true if all pointers resolved.
    inline bool FindFunctions() {
        // Prefer already-loaded module (no refcount bump) before trying LoadLibrary.
        HMODULE hModule = GetModuleHandleA("RelationsFinder.dll");
        if (!hModule) {
            hModule = LoadLibraryA("RelationsFinder.dll");
        }
        if (!hModule) {
            return false;
        }

        GetVersion = reinterpret_cast<decltype(GetVersion)>(
            GetProcAddress(hModule, "RF_GetVersion"));

        GetNpcRelationships = reinterpret_cast<decltype(GetNpcRelationships)>(
            GetProcAddress(hModule, "RF_GetNpcRelationships"));

        GetNpcRelationshipNames = reinterpret_cast<decltype(GetNpcRelationshipNames)>(
            GetProcAddress(hModule, "RF_GetNpcRelationshipNames"));

        return GetVersion != nullptr && GetNpcRelationships != nullptr && GetNpcRelationshipNames != nullptr;
    }

}  // namespace RelationsFinderAPI
