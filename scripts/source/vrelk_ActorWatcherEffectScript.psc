Scriptname vrelk_ActorWatcherEffectScript Extends ActiveMagicEffect

vrelk_ActorWatcherQuestScript Property ActorWatcherQuest Auto

Actor ThisActor = None
Race LastActorRace = None

; Logging toggle
Bool enableLogging = true


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
EndEvent

Event OnVampireStateChange(bool isVampire)
    Log(GetActorName(ThisActor) + " is now a vampire: " + isVampire)

    ActorWatcherQuest.OnVampireStateChangeEvent(ThisActor, isVampire)
EndEvent

Event OnLycanthropyStateChange(bool isLycanthrope)
    Log(GetActorName(ThisActor) + " is now a wearwolf: " + isLycanthrope)

    ActorWatcherQuest.OnLycanthropyStateChangeEvent(ThisActor, isLycanthrope)
EndEvent

Event OnRaceSwitchComplete()
    ; These are only here so I can print the log message
    string oldRace = PO3_SKSEFunctions.GetFormEditorID(LastActorRace)
    string newRace = PO3_SKSEFunctions.GetFormEditorID(ThisActor.GetRace())

    Log(GetActorName(ThisActor) + " changed race from " + oldRace + " to " + newRace)

    ActorWatcherQuest.OnRaceSwitchCompleteEvent(ThisActor, LastActorRace, ThisActor.GetRace())

    LastActorRace = ThisActor.GetRace()
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    ActorWatcherQuest.OnObjectEquippedEvent(ThisActor, akBaseObject, akReference)
EndEvent

string Function GetActorName(actor akActor)
    If akActor == Game.GetPlayer()
        Return akActor.GetActorBase().GetName()
    Else
        Return akActor.GetDisplayName()
    EndIf
EndFunction

Function Log(string msg, string prefix = "ActorWatcherActorScript-1.07")
    ActorWatcherQuest.Log(msg, prefix, true)
EndFunction