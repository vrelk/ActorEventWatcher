Scriptname vrelk_ActorWatcherEffectScript Extends ActiveMagicEffect

vrelk_ActorWatcherQuestScript Property ActorWatcherQuest Auto

Actor ThisActor = None
Race LastActorRace = None
Bool hasOCF = false

; Logging toggle
Bool enableLogging = true

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Log("OnEffectStart: " + GetActorName(akTarget))

    ThisActor = akTarget
    LastActorRace = ThisActor.GetRace()
    If Game.IsPluginInstalled("OCF.esp") ; Object Catigorization Framework
        hasOCF = true
    EndIf
EndEvent

Event OnPlayerLoadGame()
    If ThisActor == Game.GetPlayer()
        If ActorWatcherQuest == None
            Log("ERROR! ActorWatcherQuestScript is None. Unable to reinitialize quest. Remove the spell and reapply it to yourself, save, then reload.")
            Return
        EndIf
        ActorWatcherQuest.Maintenance()

        If Game.IsPluginInstalled("OCF.esp") ; Object Catigorization Framework
            hasOCF = true
        EndIf
    EndIf
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
    If ThisActor == Game.GetPlayer()
        If ActorWatcherQuest == None
            Log("ERROR! ActorWatcherQuestScript is None. Unable to register events.")
            Return
        EndIf
        ActorWatcherQuest.RegisterEvents()
    EndIf
EndEvent

Event OnVampireFeed(Actor akVictim)
    Log(GetActorName(ThisActor) + " just fed on " + GetActorName(akVictim))

    int handle = ModEvent.Create("vrelk_VampireFeed")
    If (handle)
        ModEvent.PushInt(handle, ThisActor.GetFormID())
        ModEvent.PushInt(handle, akVictim.GetFormID())
        ModEvent.PushBool(handle, akVictim.GetSleepState() >= 3)
        ModEvent.Send(handle)
    EndIf
EndEvent

Event OnVampireStateChange(bool isVampire)
    Log(GetActorName(ThisActor) + " is now a vampire: " + isVampire)

    int handle = ModEvent.Create("vrelk_VampireStateChange")
    If (handle)
        ModEvent.PushForm(handle, ThisActor)
        ModEvent.PushBool(handle, isVampire)
        ModEvent.Send(handle)
    EndIf
EndEvent

Event OnLycanthropyStateChange(bool isLycanthrope)
    Log(GetActorName(ThisActor) + " is now a wearwolf: " + isLycanthrope)

    int handle = ModEvent.Create("vrelk_LycanthropyStateChange")
    If (handle)
        ModEvent.PushForm(handle, ThisActor)
        ModEvent.PushBool(handle, isLycanthrope)
        ModEvent.Send(handle)
    EndIf
EndEvent

Event OnRaceSwitchComplete()
    string oldRace = PO3_SKSEFunctions.GetFormEditorID(LastActorRace)
    string newRace = PO3_SKSEFunctions.GetFormEditorID(ThisActor.GetRace())

    Log(GetActorName(ThisActor) + " changed race from " + oldRace + " to " + newRace)

    int handle = ModEvent.Create("vrelk_RaceSwitchComplete")
    If (handle)
        ModEvent.PushForm(handle, ThisActor)
        ModEvent.PushForm(handle, LastActorRace)
        ModEvent.PushForm(handle, ThisActor.GetRace())
        ModEvent.Send(handle)
    EndIf

    LastActorRace = ThisActor.GetRace()
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    If hasOCF && akBaseObject as Potion
        If akBaseObject.HasKeywordString("OCF_AlchDrinkAlcohol")
            VrelkTools_MinAi.RegisterEvent(GetActorName(ThisActor) + " just drank " + akBaseObject.GetName() + " (alcohol)")
        EndIf
    EndIf
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
        VrelkTools_Logging.Log(msg, "ActorWatcherActorScript-1.01", true)
    EndIf
EndFunction