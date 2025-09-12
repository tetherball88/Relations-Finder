Scriptname TTRF_RelationsFinderQST extends Quest  

ReferenceAlias Property tmpNpc  Auto  

ReferenceAlias Property TmpNpcCourting  Auto  

ReferenceAlias Property TmpNpcLover001  Auto  

ReferenceAlias Property TmpNpcLover002  Auto  

ReferenceAlias Property TmpNpcLover003  Auto  

ReferenceAlias Property TmpNpcLover004  Auto  

ReferenceAlias Property TmpNpcLover005  Auto  

ReferenceAlias Property TmpNpcSpouse  Auto  

Function OnInit()
    Actor npc = tmpNpc.GetActorRef()
    Actor spouse = TmpNpcSpouse.GetActorRef()
    Actor courting = TmpNpcCourting.GetActorRef()
    Actor lover01 = TmpNpcLover001.GetActorRef()
    Actor lover02 = TmpNpcLover002.GetActorRef()
    Actor lover03 = TmpNpcLover003.GetActorRef()
    Actor lover04 = TmpNpcLover004.GetActorRef()
    Actor lover05 = TmpNpcLover005.GetActorRef()

    if(spouse)
        TTRF_Store.SetSpouse(npc, spouse)
    endif
    if(courting)
        TTRF_Store.SetCourting(npc, courting)
    endif
    
    CheckLover(npc, lover01)
    CheckLover(npc, lover02)
    CheckLover(npc, lover03)
    CheckLover(npc, lover04)
    CheckLover(npc, lover05)

    npc.RemoveFromFaction(TTRF_Store.GetRelationsFinderFaction())
    self.Stop()
EndFunction

Function CheckLover(Actor npc, Actor lover)
    bool isSpouse = TmpNpcSpouse.GetActorRef() == lover
    bool isCourting = TmpNpcCourting.GetActorRef() == lover
    ; spouse and courting already processed at this point
    if(!lover || isSpouse || isCourting)
        return
    endif
    TTRF_Store.AddLover(npc, lover)
EndFunction