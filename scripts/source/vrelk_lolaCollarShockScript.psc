Scriptname vrelk_lolaCollarShockScript Extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)

    vrelk_ActorWatcherQuestScript ActorWatcherQuest = Game.GetFormFromFile(0x801, "vrelk_ActorEventWatcher.esp") As vrelk_ActorWatcherQuestScript
    vkjMQ lolaQuest = Game.GetFormFromFile(0x26EC9, "submissivelola_est.esp") As vkjMQ

    ActorWatcherQuest.Log("Pet just got zapped!", "vrelk_lolaCollarShockScript", true)

    int handle = ModEvent.Create("vrelk_lolaCollarShock")
    If (handle)
        ModEvent.PushString(handle, lolaQuest.OwnerTitle)
        If lolaQuest.OwnerRef
            ModEvent.PushString(handle, GetActorName(lolaQuest.OwnerRef))
        Else ; just so it works if this spell gets cast when you aren't a slave
            ModEvent.PushString(handle, GetActorName(akCaster))
        EndIf
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