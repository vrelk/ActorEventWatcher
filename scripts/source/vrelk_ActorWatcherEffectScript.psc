Scriptname vrelk_ActorWatcherEffectScript Extends ActiveMagicEffect

vrelk_ActorWatcherQuestScript Property ActorWatcherQuest Auto

Actor ThisActor = None
Race LastActorRace = None

; Logging toggle
Bool enableLogging = true
String logPrefix = "ActorWatcherActorScript-1.07"


Event OnEffectStart(Actor akTarget, Actor akCaster)
    Log("OnEffectStart: " + GetActorName(akTarget))
    
    If ActorWatcherQuest == None
        ActorWatcherQuest = Game.GetFormFromFile(0x801, "vrelk_ActorEventWatcher.esp") As vrelk_ActorWatcherQuestScript
    EndIf

    ThisActor = akTarget
    LastActorRace = ThisActor.GetRace()
EndEvent

Event OnPlayerLoadGame()
    If ThisActor == Game.GetPlayer()
        Log("OnPlayerLoadGame")

        If ActorWatcherQuest == None
            Log("ActorWatcherQuestScript is None. Attempting to reinitialize quest.")
            ActorWatcherQuest = Game.GetFormFromFile(0x801, "vrelk_ActorEventWatcher.esp") As vrelk_ActorWatcherQuestScript
        EndIf

        ; If it's still None, we need to reinitialize the actor script
        If ActorWatcherQuest == None
            Log("ERROR! ActorWatcherQuestScript is None. Unable to reinitialize quest. Remove the spell and reapply it to yourself, save, then reload.")
            Return
        EndIf

        ActorWatcherQuest.Maintenance()
    EndIf
EndEvent

Event OnVampireFeed(Actor akVictim)
    Log(GetActorName(ThisActor) + " just fed on " + GetActorName(akVictim))
    ActorWatcherQuest.OnVampireFeedEvent(ThisActor, akVictim, akVictim.GetSleepState() >= 3)

    ;int handle = ModEvent.Create("vrelk_VampireFeed")
    ;If (handle)
    ;    ModEvent.PushInt(handle, ThisActor.GetFormID())
    ;    ModEvent.PushInt(handle, akVictim.GetFormID())
    ;    ModEvent.PushBool(handle, akVictim.GetSleepState() >= 3)
    ;    ModEvent.Send(handle)
    ;EndIf
EndEvent

Event OnVampireStateChange(bool isVampire)
    Log(GetActorName(ThisActor) + " is now a vampire: " + isVampire)

    ActorWatcherQuest.OnVampireStateChangeEvent(ThisActor, isVampire)

    ;int handle = ModEvent.Create("vrelk_VampireStateChange")
    ;If (handle)
    ;    ModEvent.PushForm(handle, ThisActor)
    ;    ModEvent.PushBool(handle, isVampire)
    ;    ModEvent.Send(handle)
    ;EndIf
EndEvent

Event OnLycanthropyStateChange(bool isLycanthrope)
    Log(GetActorName(ThisActor) + " is now a wearwolf: " + isLycanthrope)

    ActorWatcherQuest.OnLycanthropyStateChangeEvent(ThisActor, isLycanthrope)

    ;int handle = ModEvent.Create("vrelk_LycanthropyStateChange")
    ;If (handle)
    ;    ModEvent.PushForm(handle, ThisActor)
    ;    ModEvent.PushBool(handle, isLycanthrope)
    ;    ModEvent.Send(handle)
    ;EndIf
EndEvent

Event OnRaceSwitchComplete()
    ; These are only here so I can print the log message
    string oldRace = PO3_SKSEFunctions.GetFormEditorID(LastActorRace)
    string newRace = PO3_SKSEFunctions.GetFormEditorID(ThisActor.GetRace())

    Log(GetActorName(ThisActor) + " changed race from " + oldRace + " to " + newRace)

    ActorWatcherQuest.OnRaceSwitchCompleteEvent(ThisActor, LastActorRace, ThisActor.GetRace())

    ;int handle = ModEvent.Create("vrelk_RaceSwitchComplete")
    ;If (handle)
    ;    ModEvent.PushForm(handle, ThisActor)
    ;    ModEvent.PushForm(handle, LastActorRace)
    ;    ModEvent.PushForm(handle, ThisActor.GetRace())
    ;    ModEvent.Send(handle)
    ;EndIf

    LastActorRace = ThisActor.GetRace()
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    ActorWatcherQuest.OnObjectEquippedEvent(ThisActor, akBaseObject, akReference)

    ;If hasOCF && akBaseObject as Potion
    ;    If akBaseObject.HasKeywordString("OCF_AlchDrinkAlcohol")
    ;        VrelkTools_MinAi.RegisterEvent(GetActorName(ThisActor) + " just drank " + akBaseObject.GetName() + " (alcohol)", "infoaction")
    ;    ElseIf akBaseObject.HasKeywordString("OCF_AlchDrugSkooma")
    ;        VrelkTools_MinAi.RegisterEvent(GetActorName(ThisActor) + " just consumed some " + akBaseObject.GetName() + " (highly addictive narcotic)", "infoaction")
    ;    ElseIf akBaseObject.HasKeywordString("_SHBloodDrink")
    ;        VrelkTools_MinAi.RegisterEvent(GetActorName(ThisActor) + " just drank a " + akBaseObject.GetName() + " (alternative to feeding on another person)", "infoaction")
    ;    EndIf
    ;EndIf
EndEvent

string Function GetActorName(actor akActor)
    If akActor == Game.GetPlayer()
        Return akActor.GetActorBase().GetName()
    Else
        Return akActor.GetDisplayName()
    EndIf
EndFunction

Function Log(string msg)
    If enableLogging
        VrelkTools_Logging.Log(msg, logPrefix, true)
    EndIf
EndFunction