#include "PapyrusRelations.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <string>
#include <unordered_map>
#include <vector>

#include "ActorMapService.h"

namespace PapyrusRelations {

    namespace {
        constexpr auto PAPYRUS_CLASS = "TTRF_RelationsFinder";
        constexpr std::int32_t kUnsetRelationshipRank = -999;  // Sentinel value for "not set"

        // Optimized ToLower - operates directly on string_view, returns lowercase string only when needed
        static bool EqualsIgnoreCase(std::string_view a, std::string_view b) noexcept {
            return std::ranges::equal(a, b, [](char ca, char cb) {
                return std::tolower(static_cast<unsigned char>(ca)) == std::tolower(static_cast<unsigned char>(cb));
            });
        }

        bool MatchesAssociationType(const RE::BGSRelationship* rel, std::string_view assocFilter) noexcept {
            if (assocFilter.empty() || EqualsIgnoreCase(assocFilter, "any")) {
                return true;
            }

            if (!rel->assocType) {
                return false;
            }

            // Map association type names to their FormIDs
            static const std::unordered_map<std::string_view, std::uint32_t> assocTypeMap = {
                {"siblings", 0x000142C5},
                {"parentchild", 0x000142C6},
                {"auntuncle", 0x000142C7},
                {"cousins", 0x000142C8},
                {"spouse", 0x000142CA},
                {"masterassistant", 0x0001E74F},
                {"jarlsteward", 0x0001E75A},
                {"jarlhousecarl", 0x0001E75D},
                {"inlawbrothersister", 0x0001E764},
                {"grandparentgrandchild", 0x0001E803},
                {"grandauntuncle", 0x0001E80B},
                {"inlawauntuncle", 0x0001E80D},
                {"bossemployee", 0x0001E817},
                {"inlawgrandparentgrandchild", 0x0001E90A},
                {"greatgrandparentgreatgrandchild", 0x0001E90B},
                {"inlawparentchild", 0x0001E917},
                {"businesspartners", 0x0001EDFD},
                {"courting", 0x0001EE23},
                {"favortarget", 0x0003F4DA},
                {"conspirators", 0x000806D9}};

            const auto formID = rel->assocType->GetFormID();

            // Try to find the filter in our map (case-insensitive search)
            for (const auto& [typeName, typeFormID] : assocTypeMap) {
                if (EqualsIgnoreCase(assocFilter, typeName)) {
                    return formID == typeFormID;
                }
            }

            // Filter doesn't match any known type
            SKSE::log::info("Unknown association filter '{}' used (rel has FormID: {:08X})", std::string(assocFilter),
                            formID);
            return false;
        }

        bool MatchesHierarchy(bool otherIsPrimary, std::string_view hierarchyFilter) noexcept {
            if (hierarchyFilter.empty() || EqualsIgnoreCase(hierarchyFilter, "any")) {
                return true;
            }

            if (EqualsIgnoreCase(hierarchyFilter, "primary")) {
                return otherIsPrimary;
            }

            if (EqualsIgnoreCase(hierarchyFilter, "secondary")) {
                return !otherIsPrimary;
            }

            return true;
        }

        int CalculateRelationshipRank(const RE::BGSRelationship* rel) noexcept {
            // Remap enum -> signed rank where kLover (0) -> +4 and kArchnemesis (8) -> -4
            const int levelVal = static_cast<int>(rel->level.underlying());
            return 4 - levelVal;
        }
    }

    std::vector<RE::Actor*> GetNpcRelationships(RE::StaticFunctionTag*, RE::Actor* npc,
                                                RE::BSFixedString associationType, RE::BSFixedString hierarchy,
                                                std::int32_t minRelationshipRank, std::int32_t exactRelationshipRank) {
        const auto startTime = std::chrono::steady_clock::now();

        if (!npc) {
            SKSE::log::warn("GetNpcRelationships: npc is null");
            return {};
        }

        // Resolve actor base
        const auto* base = npc->GetActorBase();
        if (!base) {
            SKSE::log::warn("GetNpcRelationships: actor has no base form");
            return {};
        }

        const auto* npcBase = base->As<RE::TESNPC>();
        if (!npcBase) {
            SKSE::log::warn("GetNpcRelationships: actor base is not a TESNPC");
            return {};
        }

        // Normalize filters
        const std::string_view assocFilter{associationType.c_str()};
        const std::string_view hierarchyFilter{hierarchy.c_str()};

        SKSE::log::info(
            "GetNpcRelationships called for '{}' (FormID: {:08X}) - Filters: assoc='{}', hierarchy='{}', minRank={}, "
            "exactRank={}",
            npc->GetName(), npc->GetFormID(), std::string(assocFilter), std::string(hierarchyFilter),
            minRelationshipRank, exactRelationshipRank);

        std::vector<RE::Actor*> results;
        std::size_t totalRels = 0;
        std::size_t filteredByAssoc = 0;
        std::size_t filteredByHierarchy = 0;
        std::size_t filteredByRank = 0;
        std::size_t actorNotFound = 0;

        const auto* relArray = npcBase->relationships;
        if (!relArray) {
            return results;
        }

        // Don't pre-allocate - most relationships get filtered out
        results.reserve(std::min<std::size_t>(relArray->size(), 32));

        for (const auto* rel : *relArray) {
            if (!rel) {
                continue;
            }

            ++totalRels;

            // Determine the 'other' base relative to npcBase
            RE::TESNPC* otherBase = nullptr;
            bool otherIsPrimary = false;  // primary == member index 0 (npc1)

            if (rel->npc1 == npcBase) {
                otherBase = rel->npc2;
                otherIsPrimary = false;  // other is secondary
            } else if (rel->npc2 == npcBase) {
                otherBase = rel->npc1;
                otherIsPrimary = true;  // other is primary
            } else {
                // Relationship doesn't involve this base
                continue;
            }

            if (!otherBase) {
                continue;
            }

            // Apply filters
            if (!MatchesAssociationType(rel, assocFilter)) {
                ++filteredByAssoc;
                continue;
            }

            if (!MatchesHierarchy(otherIsPrimary, hierarchyFilter)) {
                ++filteredByHierarchy;
                continue;
            }

            const int relationshipRank = CalculateRelationshipRank(rel);

            // exactRelationshipRank takes priority if provided (non-default value)
            if (exactRelationshipRank != kUnsetRelationshipRank) {
                if (relationshipRank != exactRelationshipRank) {
                    ++filteredByRank;
                    continue;
                }
            } else if (relationshipRank < minRelationshipRank) {
                ++filteredByRank;
                continue;
            }

            // Get live actor for other base
            if (auto* actor = ActorMapService::GetActorByBase(otherBase)) {
                results.push_back(actor);
            } else {
                ++actorNotFound;
                SKSE::log::debug("Could not find live actor for base FormID {:08X}", otherBase->GetFormID());
            }
        }

        const auto endTime = std::chrono::steady_clock::now();
        const auto duration = std::chrono::duration_cast<std::chrono::microseconds>(endTime - startTime);
        const double ms = duration.count() / 1000.0;

        SKSE::log::info(
            "GetNpcRelationships results: {} matches from {} total relationships "
            "(filtered: {} by assoc, {} by hierarchy, {} by rank, {} actor not found) - took {:.3f} ms",
            results.size(), totalRels, filteredByAssoc, filteredByHierarchy, filteredByRank, actorNotFound, ms);

        return results;
    }

    bool RegisterPapyrus(RE::BSScript::Internal::VirtualMachine* a_vm) {
        if (!a_vm) {
            SKSE::log::error("RegisterPapyrus called with null vm");
            return false;
        }

        // Explicitly cast to the BSFixedString overload for Papyrus registration
        using GetNpcRelationshipsFn = std::vector<RE::Actor*> (*)(RE::StaticFunctionTag*, RE::Actor*, RE::BSFixedString,
                                                                  RE::BSFixedString, std::int32_t, std::int32_t);
        a_vm->RegisterFunction("GetNpcRelationships", PAPYRUS_CLASS,
                               static_cast<GetNpcRelationshipsFn>(GetNpcRelationships));

        SKSE::log::info("Registered {} RelationsFinder Papyrus functions", 1);
        return true;
    }

    // C API-friendly overload that accepts const char*
    std::vector<RE::Actor*> GetNpcRelationships(RE::StaticFunctionTag* tag, RE::Actor* npc, const char* associationType,
                                                const char* hierarchy, std::int32_t minRelationshipRank,
                                                std::int32_t exactRelationshipRank) {
        return GetNpcRelationships(tag, npc, RE::BSFixedString(associationType), RE::BSFixedString(hierarchy),
                                   minRelationshipRank, exactRelationshipRank);
    }

}  // namespace PapyrusRelations
