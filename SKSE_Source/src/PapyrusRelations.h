#pragma once

#include "../PCH.h"

namespace PapyrusRelations {

    bool RegisterPapyrus(RE::BSScript::Internal::VirtualMachine* a_vm);

    // Papyrus-exposed function (overloaded to accept both BSFixedString and const char*)
    std::vector<RE::Actor*> GetNpcRelationships(RE::StaticFunctionTag*, RE::Actor* npc,
                                                RE::BSFixedString associationType, RE::BSFixedString hierarchy,
                                                std::int32_t minRelationshipRank, std::int32_t exactRelationshipRank);

    // C API-friendly overload
    std::vector<RE::Actor*> GetNpcRelationships(RE::StaticFunctionTag*, RE::Actor* npc, const char* associationType,
                                                const char* hierarchy, std::int32_t minRelationshipRank,
                                                std::int32_t exactRelationshipRank);

    // Returns names sourced directly from TESNPC base forms (no live actor required).
    // Safe to call even when actors are not loaded in the current cell.
    void GetNpcRelationshipNames(RE::Actor* npc, const char* associationType, const char* hierarchy,
                                 std::int32_t minRelationshipRank, std::int32_t exactRelationshipRank,
                                 void (*callback)(const char* name, void* userData), void* userData) noexcept;

}  // namespace PapyrusRelations
