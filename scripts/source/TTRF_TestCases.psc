scriptname TTRF_TestCases

Function Maintenance() global
    bool turnTestsOff = true
    if(turnTestsOff)
        return
    endif
    TTRF_Store.Clear()
    float time = Utility.GetCurrentRealTime()
    TTRF_Store.ExportData("cleaned_before_test.json")
    MiscUtil.PrintConsole("[TTRF]: TESTS STARTED")
    CheckSingleNpcWithCourting()
    CheckSingleNpcWithSpouse()
    CheckSingleNpcWithLover()
    CheckMultipleNpcs()
    MiscUtil.PrintConsole("[TTRF]: TESTS ENDED. Time to finish - " + (Utility.GetCurrentRealTime() - time))
    TTRF_Store.ExportData("after_all_tests.json")
EndFunction

Function CheckSingleNpcWithSpouse() global
    Actor boti = Game.GetFormFromFile(0x19E05, "Skyrim.esm") as Actor
    Actor jofthor = Game.GetFormFromFile(0x19E04, "Skyrim.esm") as Actor

    Actor courting = TTRF_Store.GetCourting(boti)
    Actor spouse = TTRF_Store.GetSpouse(boti)
    Form[] lovers = TTRF_Store.GetLovers(boti)

    string result = "[CheckSingleNpcWithSpouse] tested Boti/Jofthor."
    if(courting == none)
        result += " Success: Boti doesn't have courting;"
    else
        result += " Error: "+courting.GetDisplayName()+" was incorrectly identified as Boti's courting;"
    endif
    if(spouse == jofthor)
        result += " Success: Jofthor was identified as spouse;"
    else
        result += " Error: Jofthor wasn't identified as spouse;"
    endif
    if(lovers.Length == 0)
        result += " Success: Boti doesn't have lovers(even Jfothor);"
    else
        result += " Error: Found "+lovers.Length+" lovers for Boti when it should be 0;"
    endif

    MiscUtil.PrintConsole(result)
EndFunction

Function CheckSingleNpcWithCourting() global
    Actor tekla = Game.GetFormFromFile(0x1981C, "Skyrim.esm") as Actor
    Actor solaf = Game.GetFormFromFile(0x1981E, "Skyrim.esm") as Actor

    Actor courting = TTRF_Store.GetCourting(tekla)
    Actor spouse = TTRF_Store.GetSpouse(tekla)
    Form[] lovers = TTRF_Store.GetLovers(tekla)

    string result = "[CheckSingleNpcWithCourting] tested Tekla/Solaf."
    if(courting == solaf)
        result += " Success: Solaf was identified as courting;"
    else
        result += " Error: Solaf wasn't identified as courting;"
    endif
    if(spouse == none)
        result += " Success: Takla doesn't have spouse;"
    else
        result += " Error: "+spouse.GetDisplayName()+" was incorrectly identified as Tekla's spouse;"
    endif
    if(lovers.Length == 0)
        result += " Success: Takla doesn't have lovers(even Solaf);"
    else
        result += " Error: Found "+lovers.Length+" lovers for Tekla when it should be 0;"
    endif

    MiscUtil.PrintConsole(result)
EndFunction

Function CheckSingleNpcWithLover() global
    Actor fastred = Game.GetFormFromFile(0x19E06, "Skyrim.esm") as Actor
    Actor bassianus = Game.GetFormFromFile(0x19E08, "Skyrim.esm") as Actor

    Actor courting = TTRF_Store.GetCourting(fastred)
    Actor spouse = TTRF_Store.GetSpouse(fastred)
    Form[] lovers = TTRF_Store.GetLovers(fastred)

    string result = "[CheckSingleNpcWithLover] tested Fastred/Bassianus."
    if(courting == none)
        result += " Success: Fastred doesn't have officially courting(even Bassianus);"
    else
        result += " Error: "+courting.GetDisplayName()+" was incorrectly identified as Fastred's courting;"
    endif
    if(spouse == none)
        result += " Success: Fastred doesn't have spouse;"
    else
        result += " Error: "+spouse.GetDisplayName()+" was incorrectly identified as Fastred's spouse;"
    endif
    bool isBassianusLover = (lovers[0] as Actor) == bassianus
    if(isBassianusLover)
        result += " Success: Fastred has lover Bassianus;"
    else
        result += " Error: Bassianus wasn't identified as lover;"
    endif

    MiscUtil.PrintConsole(result)
EndFunction


Function CheckMultipleNpcs() global
    Actor jala = Game.GetFormFromFile(0x198AF, "Skyrim.esm") as Actor
    Actor ahtar = Game.GetFormFromFile(0x198B0, "Skyrim.esm") as Actor
    Actor gerdur = Game.GetFormFromFile(0x13489, "Skyrim.esm") as Actor
    Actor hod = Game.GetFormFromFile(0x1348A, "Skyrim.esm") as Actor
    Actor alva = Game.GetFormFromFile(0x1AA5C, "Skyrim.esm") as Actor
    Actor hroggar = Game.GetFormFromFile(0x1AA5D, "Skyrim.esm") as Actor

    MiscUtil.PrintConsole("[CheckMultipleNpcs]: START")
    Actor jalaCourting = TTRF_Store.GetCourting(jala)
    if(CheckPairs(jalaCourting, ahtar))
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Success: Jala's courting is Ahtar")
    else
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Error: Jala's courting isn't Ahtar")
    endif
    Utility.Wait(0)
    Actor alvaLover = TTRF_Store.GetLovers(alva)[0] as Actor
    Actor ahtarCourting = TTRF_Store.GetCourting(ahtar)
    if(CheckPairs(alvaLover, hroggar))
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Success: Alva's lover is Hroggar")
    else
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Error: Alva's lover isn't Hroggar")
    endif
    if(CheckPairs(ahtarCourting, jala))
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Success: Ahtar's courting is Jala")
    else
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Error: Ahtar's courting isn't Jala")
    endif
    Utility.Wait(0.5)
    Actor gerdurSpouse = TTRF_Store.GetSpouse(gerdur)
    if(CheckPairs(gerdurSpouse, hod))
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Success: Gerdur's spouse is Hod")
    else
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Error: Gerdur's spouse isn't Hod")
    endif
    Utility.Wait(2)
    Actor hodSpouse = TTRF_Store.GetSpouse(hod)
    if(CheckPairs(hodSpouse, gerdur))
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Success: Hod's spouse is Gerdur")
    else
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Error: Hod's spouse isn't Gerdur")
    endif
    Utility.Wait(0.3)
    Actor hroggarLover = TTRF_Store.GetLovers(hroggar)[0] as Actor
    if(CheckPairs(hroggarLover, alva))
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Success: Hroggar's lover is Alva")
    else
        MiscUtil.PrintConsole("[CheckMultipleNpcs]: Error: Hroggar's lover isn't Alva")
    endif
    MiscUtil.PrintConsole("[CheckMultipleNpcs]: END")

EndFunction

bool Function CheckPairs(Actor act1, Actor act2) global
    int tries = 5

    while(tries > 0 && act1 == act2)
        if(act1 == act2)
            return true
        endif
        tries += -1
    endwhile

    return false
EndFunction