Scriptname vrelk_ActorWatcherQuestScript Extends Quest
{This listens for and processes incoming events}

Spell Property ActorWatcherSpell Auto
MagicEffect Property ActorWatcherEffect Auto

Faction Property PlayerFollowerFaction Auto
Faction Property PlayerMarriedFaction Auto

Faction Property PAHPlayerSlaveFaction Auto ; 0047DB - Paradise Halls - Player slave
Faction Property DOMPlayerSlaveFaction Auto ; 56C505 - Diary of Mine - Player slave
Faction Property VampirePCFamily Auto ; 0135EB - Better Vampires - Player turned an npc into a vampire

Race Property VampireLordRace Auto
Race Property WerewolfRace Auto

Actor Property PlayerRef Auto

Bool isLoading = False
Bool hasPAH = false
Bool hasDOM = false
Bool hasBetterVampires = false

; Logging toggle
Bool enableLogging = true


Event OnInit()
    Log("OnInit")
    Maintenance()
EndEvent

Event OnLoad()
    Log("OnLoad")
    Maintenance()
EndEvent

Function Maintenance()
    If isLoading
        Return
    EndIf

    isLoading = True

    If !PlayerRef.HasMagicEffect(ActorWatcherEffect)
        Log("Adding AiWatcherActorSpell to PlayerRef")
        PlayerRef.AddSpell(ActorWatcherSpell)
    EndIf

    If Game.IsPluginInstalled("Better Vampires.esp")
        hasBetterVampires = true
        VampirePCFamily = Game.GetFormFromFile(0x0135EB, "Better Vampires.esp") As Faction
    EndIf
    If Game.IsPluginInstalled("paradise_halls.esm")
        hasPAH = true
        PAHPlayerSlaveFaction = Game.GetFormFromFile(0x0047DB, "paradise_halls.esm") As Faction
    EndIf
    If Game.IsPluginInstalled("DiaryOfMine.esm") ; The newer ESM version of Diary of Mine
        hasDOM = true
        DOMPlayerSlaveFaction = Game.GetFormFromFile(0x56C505, "DiaryOfMine.esm") As Faction
    EndIf
    If Game.IsPluginInstalled("DiaryOfMine.esp") ; The older ESP version of Diary of Mine
        hasDOM = true
        DOMPlayerSlaveFaction = Game.GetFormFromFile(0x56C505, "DiaryOfMine.esp") As Faction
    EndIf

    Log("Monitoring for Actor Events")


    UnregisterForAllModEvents()

    RegisterForModEvent("vrelk_VampireFeed", "OnVampireFeedEvent")
    RegisterForModEvent("vrelk_VampireStateChange", "OnVampireStateChangeEvent")
    RegisterForModEvent("vrelk_RaceSwitchComplete", "OnRaceSwitchCompleteEvent")

    If hasBetterVampires
        RegisterForModEvent("BetterVampires_TurnedVampireFeed", "OnVampireFeedEvent")
    EndIf

    If hasPAH
        RegisterForModEvent("PAHE_NewSlave", "OnNewPaheSlaveEvent")
    EndIf

    isLoading = False
EndFunction



Event OnVampireFeedEvent(string nameVampire, string nameVictim, bool victimSleeping)
    Log(nameVampire + " fed on " + nameVictim + ". Was Sleeping: " + victimSleeping)

    string msg = nameVampire + "'s vampiric thirst has been quenched by feeding on " + nameVictim
    If victimSleeping
        msg = msg + ", who was sleeping."
    EndIf

    VrelkTools_MinAi.RequestResponse(msg, "chat", "everyone") ; send generic dialogue to everyone, requesting a response
EndEvent

Event OnVampireStateChangeEvent(Actor akActor, bool isVampire)
    Log(GetActorName(akActor) + " is now a vampire: " + isVampire)

    ; make this do something else later
EndEvent

Event OnRaceSwitchCompleteEvent(Actor akActor, Race oldRace, Race newRace)
    string oldRaceE = PO3_SKSEFunctions.GetFormEditorID(oldRace)
    string newRaceE = PO3_SKSEFunctions.GetFormEditorID(newRace)

    Log(GetActorName(akActor) + " changed race from " + oldRaceE + " to " + newRaceE)

    string msg = None

    If newRace == VampireLordRace ; Transform into vampire lord
        msg = GetActorName(akActor) + " just transformed into a vampire lord!"

    ElseIf oldRace == VampireLordRace && newRace != VampireLordRace ; Transform from vampire lord back to human
        msg = GetActorName(akActor) + " just transformed from a vampire lord back to their normal human form."

    ElseIf newRace == WerewolfRace ; Transform into werewolf
        msg = GetActorName(akActor) + " just transformed into a werewolf!"

    ElseIf oldRace == WerewolfRace && newRace != WerewolfRace ; Transform from werewolf back to human
        msg = GetActorName(akActor) + " just transformed from a werewolf back to their normal human form."
    EndIf

    If msg == None ; not a transformation we care about, so just return
        return
    ElseIf akActor.IsInCombat()
        VrelkTools_MinAi.RegisterEvent(msg, "info") ; actor is in combat, so just send this as general context information
    ElseIf !akActor.IsInCombat()
        VrelkTools_MinAi.RequestResponse(msg, "chat", "everyone") ; send generic dialogue to everyone, requesting a response
    EndIf
EndEvent

Event OnNewPaheSlaveEvent(PAHCore pahCore, Actor akSlave)
    Log(GetActorName(akSlave) + " is now a PAH slave.")

    string msg = "I just enslaved " + GetActorName(akSlave)
    VrelkTools_MinAi.RequestResponseDialogue(GetActorName(PlayerRef), msg, "everyone") ; send player dialogue to everyone, requesting a response
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
        VrelkTools_Logging.Log(msg, "ActorWatcherQuestScript", true)
    EndIf
EndFunction