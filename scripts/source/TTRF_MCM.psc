scriptname TTRF_MCM extends SKI_ConfigBase  

import TTRF_JCDomain


int property oid_SettingsClearData auto
int property oid_SettingsExportData auto
int property oid_SettingsImportData auto
int property oid_SettingsToggleDebugSpell auto

Event OnConfigInit()
    ModName = "Relations Finder"
    Pages = new string[2]

    Pages[0] = "Settings"
EndEvent

Event OnPageReset(string page)
    if(page == "Settings")
        RenderPage()
    endif
EndEvent

Function RenderPage()
    SetCursorFillMode(TOP_TO_BOTTOM)
    RenderLeftColumn()
    SetCursorPosition(1)
EndFunction

Function RenderLeftColumn()
    AddHeaderOption("Settings")
    oid_SettingsExportData = AddTextOption("", "Export data to file")
    oid_SettingsImportData = AddTextOption("", "Import data from file")
    oid_SettingsClearData = AddTextOption("", "Clear whole data")

    AddHeaderOption("Debug")
    oid_SettingsToggleDebugSpell = AddTextOption("", "Add/remove debug spell")
EndFunction

event OnOptionSelect(int option)
    if (oid_SettingsClearData == option)
        bool yes = ShowMessage("Are you sure you want to clear all data?")
        if(yes)
            TTRF_Store.Clear()
        endif
    elseif (oid_SettingsExportData == option)
        TTRF_Store.ExportData() 
    elseif (oid_SettingsImportData == option)
        TTRF_Store.ImportData()
    elseif (oid_SettingsToggleDebugSpell)
        Actor PlayerRef = TTRF_Store.GetPlayerRef()
        Spell debugSpell = TTRF_Store.GetDebugSpell()
        if(PlayerRef.HasSpell(debugSpell))
            PlayerRef.RemoveSpell(debugSpell)
        else
            PlayerRef.AddSpell(debugSpell)
            PlayerRef.EquipSpell(debugSpell, 0)
        endif
    endif
endevent

; Highlight
event OnOptionHighlight(int option)
    if(option == oid_SettingsClearData)
        SetInfoText("Clears whole data from save")
    elseif(option == oid_SettingsExportData)
        SetInfoText("Exports json data to file in Documents\\My Games\\Skyrim Special Edition\\JCUser\\RelationsFinder\\store.json")
    elseif(option == oid_SettingsClearData)
        SetInfoText("Imports data from file in Documents\\My Games\\Skyrim Special Edition\\JCUser\\RelationsFinder\\store.json")
    endif
endevent