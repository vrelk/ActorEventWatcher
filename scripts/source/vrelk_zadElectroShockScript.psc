Scriptname vrelk_zadElectroShockScript Extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)

    vrelk_ActorWatcherQuestScript ActorWatcherQuest = Game.GetFormFromFile(0x801, "vrelk_ActorEventWatcher.esp") As vrelk_ActorWatcherQuestScript

    ActorWatcherQuest.Log(GetActorName(akTarget) + " just got zapped!", "vrelk_zadElectroShockScript", true)

    int handle = ModEvent.Create("vrelk_zadElectroShock")
    If (handle)
        ModEvent.PushForm(handle, akTarget As Form)
        ModEvent.Send(handle)
    EndIf
EndEvent

string Function GetActorName(actor akActor)
    If akActor == Game.GetPlayer()
        Return akActor.GetActorBase().GetName()
    Else
        Return akActor.GetDisplayName()
    EndIf
EndFunction