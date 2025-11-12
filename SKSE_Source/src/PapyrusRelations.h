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

}  // namespace PapyrusRelations
