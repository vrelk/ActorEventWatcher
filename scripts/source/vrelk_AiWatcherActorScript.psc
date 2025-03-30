Scriptname vrelk_AiWatcherActorScript Extends ActiveMagicEffect

Actor ThisActor = None
Race LastActorRace = None

Event OnEffectStart(Actor akTarget, Actor akCaster)
    VrelkTools_Logging.Log("OnEffectStart: " + GetActorName(akTarget), "AiWatcherActor", true)

    ThisActor = akTarget
    LastActorRace = ThisActor.GetRace()
EndEvent

Event OnVampireFeed(Actor akVictim)
    VrelkTools_Logging.Log(GetActorName(ThisActor) + " just fed on " + GetActorName(akVictim), "AiWatcherActorScript", true)

	int handle = ModEvent.Create("vrelk_VampireFeed")
    If (handle)
		ModEvent.PushForm(handle, ThisActor)
		ModEvent.PushForm(handle, akVictim)
		ModEvent.PushString(handle, akVictim.GetSleepState() >= 3)
		ModEvent.Send(handle)
	EndIf
EndEvent

Event OnVampireStateChange(bool isVampire)
    VrelkTools_Logging.Log(GetActorName(ThisActor) + " is now a vampire: " + isVampire, "AiWatcherActorScript", true)

    int handle = ModEvent.Create("vrelk_VampireStateChange")
    If (handle)
		ModEvent.PushForm(handle, ThisActor)
		ModEvent.PushBool(handle, isVampire)
		ModEvent.Send(handle)
	EndIf
EndEvent

Event OnRaceSwitchComplete()
    string oldRace = PO3_SKSEFunctions.GetFormEditorID(LastActorRace)
    string newRace = PO3_SKSEFunctions.GetFormEditorID(ThisActor.GetRace())

    VrelkTools_Logging.Log(GetActorName(ThisActor) + " changed race from " + oldRace + " to " + newRace, "AiWatcherActorScript", true)

    int handle = ModEvent.Create("vrelk_RaceSwitchComplete")
    If (handle)
		ModEvent.PushForm(handle, ThisActor)
		ModEvent.PushForm(handle, LastActorRace)
		ModEvent.PushForm(handle, ThisActor.GetRace())
		ModEvent.Send(handle)
	EndIf

    LastActorRace = ThisActor.GetRace()
EndEvent

string Function GetActorName(actor akActor)
    If akActor == Game.GetPlayer()
        Return akActor.GetActorBase().GetName()
    Else
        Return akActor.GetDisplayName()
    EndIf
EndFunction