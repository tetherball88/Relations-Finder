Scriptname TTRF_PlayerScript extends ReferenceAlias

Event OnPlayerLoadGame()
    TTRF_MainController mainController = self.GetOwningQuest() as TTRF_MainController
    mainController.Maintenance()
EndEvent