Scriptname TTRF_SpellDebugMagicEffect extends activemagiceffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
    if(akTarget)
        string content = akTarget.GetDisplayName() + " has:"
        Actor spouse = TTRF_Store.GetSpouse(akTarget)
        Actor courting = TTRF_Store.GetCourting(akTarget)
        Form[] lovers = TTRF_Store.GetLovers(akTarget)

        content = content + "\nspouse: "

        if(spouse) 
            content = content + spouse.GetDisplayName()
        else
            content = content + "None"
        endif

        content = content + "\ncourting: "

        if(courting) 
            content = content + courting.GetDisplayName()
        else
            content = content + "None"
        endif

        int i = 0

        content = content + "\nother lovers: "

        while(i < lovers.Length)
            content = content + (lovers[i] as Actor).GetDisplayName() + ", "
            i += 1
        endwhile

        Debug.MessageBox(content)
    endif
EndEvent