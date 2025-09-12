scriptname TTRF_Store

import TTRF_JCDomain

;/
{
    initialData: {
        "findPartnersQst": "TT_LoversLedger.esp|0xe89",
        "findPartnersFaction": "__formData|TT_LoversLedger.esp|0xe8a",
    }    
    originalRelationships: { // map of all tracked npcs
        [Actor]: { // npc key
            [relationshipKey]: Actor | Actor[] 
        }
    }
}
/;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Main Data Structure Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;/
  Helper to get a JFormMap object, creating it if it doesn't exist.
  @param parentMap The parent JMap object
  @param k         The key to look up or create
  @return          The JFormMap object
/;
int Function _GetOrCreateJFormMap(int parentMap, string k) global
    int res = JMap_getObj(parentMap, k)
    if (!res)
        res = JFormMap_object()
        JMap_setObj(parentMap, k, res)
    endif
    return res
EndFunction

;/
  Returns the namespace key for TT_RelationsFinder data in JContainers.
/;
string Function GetNamespaceKey() global
    return ".TT_RelationsFinder"
EndFunction

; Clear the main tracking object
Function Clear() global
    JDB_solveObjSetter(GetNamespaceKey(), 0)
EndFunction

;/**
* Exports the main NPCs JMap object to a file.
*/;
Function ExportData() global
    JValue_writeToFile(JDB_solveObj(GetNamespaceKey()), JContainers.userDirectory() + "RelationsFinder/store.json")
EndFunction

;/**
* Imports the main NPCs JMap object from a file.
*/;
Function ImportData() global
    int JObj = JValue_readFromFile(JContainers.userDirectory() + "RelationsFinder/store.json")
    JDB_solveObjSetter(GetNamespaceKey(), JObj)
EndFunction

string Function GetInitialDataKey() global
    return GetNamespaceKey() + ".initialData"
EndFunction

Function ImportInitialData() global
    JDB_solveObjSetter(GetInitialDataKey(), JValue_readFromFile("Data/SKSE/Plugins/RelationsFinder/initialData.json"), true)
EndFunction

int Function GetRoot() global
    return JDB_solveObj(GetNamespaceKey())
EndFunction

Actor Function GetPlayerRef() global
    return JDB_solveForm(GetInitialDataKey() + ".playerRef") as Actor
EndFunction

Spell Function GetDebugSpell() global
    return JDB_solveForm(GetInitialDataKey() + ".debugSpell") as Spell
EndFunction

Quest Function GetRelationsFinderQST() global
    string questId = JDB_solveStr(GetInitialDataKey() + ".relationsFinderQst")
    return JString.decodeFormStringToForm("__formData|"+questId) as Quest
EndFunction

Faction Function GetRelationsFinderFaction() global
    return JDB_solveForm(GetInitialDataKey() + ".relationsFinderFaction") as Faction
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; NPC Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Get the npcs object
int Function GetOriginalRelationships() global
    return _GetOrCreateJFormMap(GetRoot(), "originalRelationships")
EndFunction

; Get NPC data object
int Function GetNpcRelationships(Actor npc) global
    if(!npc)
        return 0
    endif
    int JRelationships = GetOriginalRelationships()
    int JNpcObj = JFormMap_getObj(JRelationships, npc)
    if JNpcObj == 0
        ; Create new NPC entry if it doesn't exist
        JNpcObj = JMap_object()
         
        ; Initialize basic properties
        JMap_setForm(JNpcObj, "spouse", none)
        JMap_setForm(JNpcObj, "courting", none)
        JMap_setObj(JNpcObj, "lovers", JArray_object())

        JFormMap_setObj(JRelationships, npc, JNpcObj)

        
        Quest findPartnersQst = GetRelationsFinderQST()

        ; find for npc any existing relationships it should be done once per new npc
        if(npc != GetPlayerRef())
            npc.AddToFaction(GetRelationsFinderFaction())
            findPartnersQst.Start()
        endif

        int wait = 5
        while(wait != 0 && findPartnersQst.IsRunning())
            Utility.Wait(0.3)
            wait = wait - 1
        endwhile

        ; if after 2.5 seconds quest is still running then something went wrong and we need to terminate it so other npcs can be added
        if(findPartnersQst.IsRunning())
            npc.RemoveFromFaction(GetRelationsFinderFaction()) ; in case if quest script didn't handle removing Faction
            findPartnersQst.Stop()
        endif
    endif

    return JNpcObj
EndFunction

Function SetSpouse(Actor npc, Actor spouse) global
    JMap_setForm(GetNpcRelationships(npc), "spouse", spouse)
EndFunction

Actor Function GetSpouse(Actor npc) global
    return JMap_getForm(GetNpcRelationships(npc), "spouse") as Actor
EndFunction

Function SetCourting(Actor npc, Actor courting) global
    JMap_setForm(GetNpcRelationships(npc), "courting", courting)
EndFunction

Actor Function GetCourting(Actor npc) global
    return JMap_getForm(GetNpcRelationships(npc), "courting") as Actor
EndFunction

Function AddLover(Actor npc, Actor lover) global
    int JLovers = JMap_getObj(GetNpcRelationships(npc), "lovers")

    JArray_addForm(JLovers, lover)
EndFunction

Form[] Function GetLovers(Actor npc) global
    int JLovers = JMap_getObj(GetNpcRelationships(npc), "lovers")

    return JArray_asFormArray(JLovers)
EndFunction
