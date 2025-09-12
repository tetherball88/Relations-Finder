Scriptname TTRF_MainController extends Quest  

Actor Property PlayerRef  Auto  

Int Function GetVersion()
    return 1
EndFunction

Event OnInit()
    Maintenance()
EndEvent

Function Maintenance()
    TTRF_Store.ImportInitialData()    
EndFunction


