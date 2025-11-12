Scriptname TTRF_RelationsFinder

;============================================================================
; MARAS - Relations Finder
;============================================================================

; Retrieves an array of NPCs that have a specified relationship with the given NPC.
; Parameters:
;   npc - The NPC to find relationships for.
;   associationType - The type of relationship. Use an empty string for any type. "AuntUncle", "BossEmployee", "BusinessPartners", "Conspirators", "Courting", "Cousins", "FavorTarget", "GrandAuntUncle", "GrandparentGrandchild", "GreatGrandparentGreatgrandchild", "InLawAuntUncle", "InLawBrotherSister", "InLawGrandparentGrandchild", "InLawParentChild", "JarlHousecarl", "JarlSteward", "MasterAssistant", "ParentChild", "Siblings", "Spouse", etc.). 
;   hierarchy - The hierarchy of the relationship ("primary", "secondary", or "any"). Where is primary "parent" and secondary is "child".
;   minRelationshipRank - The minimum relationship rank (from -4 to +4).
;   exactRelationshipRank - The exact relationship rank to match (from -4 to +4). Takes priority over minRelationshipRank if set to anything other than -999.
; Returns:
;   An array of NPCs that match the specified relationship criteria.
Actor[] Function GetNpcRelationships(Actor npc, string associationType = "", string hierarchy = "any", int minRelationshipRank = -4, int exactRelationshipRank = -999) Global Native

; Shortcuts for common relationship types
; Parent-Child
Actor[] Function GetParentChildren(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "ParentChild", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetParents(Actor npc, int minRelationshipRank = -4) Global
    return GetParentChildren(npc, "primary", minRelationshipRank)
EndFunction
Actor[] Function GetChildren(Actor npc, int minRelationshipRank = -4) Global
    return GetParentChildren(npc, "secondary", minRelationshipRank)
EndFunction

; Spouse and Courting
Actor Function GetSpouse(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    Actor[] spouses = GetNpcRelationships(npc, "Spouse", hierarchy, minRelationshipRank)
    if(spouses.Length > 0)
        return spouses[0]
    endif
    return None
EndFunction
Actor Function GetCourting(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    Actor[] courting = GetNpcRelationships(npc, "Courting", hierarchy, minRelationshipRank)
    if(courting.Length > 0)
        return courting[0]
    endif
    return None
EndFunction

; Extended family relationships
; Uncle/Aunt - Niece/Nephew
Actor[] Function GetUncleAuntNieceNephew(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "ParentChild", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetAuntUncle(Actor npc, int minRelationshipRank = -4) Global
    return GetUncleAuntNieceNephew(npc, "primary", minRelationshipRank)
EndFunction
Actor[] Function GetNiecesNephews(Actor npc, int minRelationshipRank = -4) Global
    return GetUncleAuntNieceNephew(npc, "secondary", minRelationshipRank)
EndFunction

; Grandparent - Grandchild
Actor[] Function GetGrandParentChild(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "GrandParentGrandchild", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetGrandparents(Actor npc, int minRelationshipRank = -4) Global
    return GetGrandParentChild(npc, "primary", minRelationshipRank)
EndFunction
Actor[] Function GetGrandchildren(Actor npc, int minRelationshipRank = -4) Global
    return GetGrandParentChild(npc, "secondary", minRelationshipRank)
EndFunction

; Great Grandparent - Great Grandchild
Actor[] Function GetGreatGrandparentChild(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "GreatGrandparentGreatgrandchild", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetGreatGrandparents(Actor npc, int minRelationshipRank = -4) Global
    return GetGreatGrandparentChild(npc, "primary", minRelationshipRank)
EndFunction
Actor[] Function GetGreatGrandchildren(Actor npc, int minRelationshipRank = -4) Global
    return GetGreatGrandparentChild(npc, "secondary", minRelationshipRank)
EndFunction

; Grand Aunt/Uncle - Grand Niece/Nephew
Actor[] Function GetGrandAuntUncleNieceNephew(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "GrandAuntUncle", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetGrandAuntUncle(Actor npc, int minRelationshipRank = -4) Global
    return GetGrandAuntUncleNieceNephew(npc, "primary", minRelationshipRank)
EndFunction
Actor[] Function GetGrandNiecesNephews(Actor npc, int minRelationshipRank = -4) Global
    return GetGrandAuntUncleNieceNephew(npc, "secondary", minRelationshipRank)
EndFunction

; Siblings/cousins
Actor[] Function GetSiblings(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "Siblings", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetCousins(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "Cousins", hierarchy, minRelationshipRank)
EndFunction

; In law relationships
Actor[] Function GetInLawSiblings(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "InLawBrotherSister", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetInLawParentChild(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "InLawParentChild", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetInLawParents(Actor npc, int minRelationshipRank = -4) Global
    return GetInLawParentChild(npc, "primary", minRelationshipRank)
EndFunction
Actor[] Function GetInLawChildren(Actor npc, int minRelationshipRank = -4) Global
    return GetInLawParentChild(npc, "secondary", minRelationshipRank)
EndFunction
Actor[] Function GetInLawAuntUncleNieceNephew(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "InLawAuntUncle", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetInLawAuntUncle(Actor npc, int minRelationshipRank = -4) Global
    return GetInLawAuntUncleNieceNephew(npc, "primary", minRelationshipRank)
EndFunction
Actor[] Function GetInLawNiecesNephews(Actor npc, int minRelationshipRank = -4) Global
    return GetInLawAuntUncleNieceNephew(npc, "secondary", minRelationshipRank)
EndFunction
Actor[] Function GetInLawGrandParentChild(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "InLawGrandparentGrandchild", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetInLawGrandparents(Actor npc, int minRelationshipRank = -4) Global
    return GetInLawGrandParentChild(npc, "primary", minRelationshipRank)
EndFunction
Actor[] Function GetInLawGrandchildren(Actor npc, int minRelationshipRank = -4) Global
    return GetInLawGrandParentChild(npc, "secondary", minRelationshipRank)
EndFunction

; Work relationships
Actor[] Function GetBusinessPartners(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "BusinessPartners", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetConspirators(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "Conspirators", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetFavorTargets(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "FavorTarget", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetJarlHousecarl(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "JarlHousecarl", hierarchy, minRelationshipRank)
EndFunction
Actor Function GetJarlSteward(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "JarlSteward", hierarchy, minRelationshipRank)[0]
EndFunction
Actor[] Function GetMasterAssistants(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "MasterAssistant", hierarchy, minRelationshipRank)
EndFunction
Actor[] Function GetBossEmployees(Actor npc, string hierarchy = "any", int minRelationshipRank = -4) Global
    return GetNpcRelationships(npc, "BossEmployee", hierarchy, minRelationshipRank)
EndFunction

; Relationship ranks

Actor[] Function GetAllArchnemesises(Actor npc) Global
    return GetNpcRelationships(npc, ExactRelationshipRank = -4)
EndFunction

Actor[] Function GetAllEnemies(Actor npc) Global
    return GetNpcRelationships(npc, ExactRelationshipRank = -3)
EndFunction

Actor[] Function GetAllFoes(Actor npc) Global
    return GetNpcRelationships(npc, ExactRelationshipRank = -2)
EndFunction

Actor[] Function GetAllRivals(Actor npc) Global
    return GetNpcRelationships(npc, ExactRelationshipRank = -1)
EndFunction

Actor[] Function GetAllAcquaintances(Actor npc) Global
    return GetNpcRelationships(npc, ExactRelationshipRank = 0)
EndFunction

Actor[] Function GetAllFriends(Actor npc) Global
    return GetNpcRelationships(npc, ExactRelationshipRank = 1)
EndFunction

Actor[] Function GetAllConfidants(Actor npc) Global
    return GetNpcRelationships(npc, ExactRelationshipRank = 2)
EndFunction

Actor[] Function GetAllAllies(Actor npc) Global
    return GetNpcRelationships(npc, ExactRelationshipRank = 3)
EndFunction

Actor[] Function GetAllLovers(Actor npc) Global
    return GetNpcRelationships(npc, ExactRelationshipRank = 4)
EndFunction

