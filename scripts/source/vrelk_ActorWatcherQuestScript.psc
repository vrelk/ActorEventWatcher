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


Event OnInit()
    VrelkTools_Logging.Log("OnInit", "ActorWatcherQuestScript", true)
	Maintenance()
EndEvent

Event OnLoad()
    VrelkTools_Logging.Log("OnLoad", "ActorWatcherQuestScript", true)
	Maintenance()
EndEvent

Function Maintenance()
    If isLoading
		Return
	EndIf

	isLoading = True

    ;PlayerRef = Game.GetPlayer()

    If !PlayerRef.HasMagicEffect(ActorWatcherEffect)
        VrelkTools_Logging.Log("Adding AiWatcherActorSpell to PlayerRef", "ActorWatcherQuestScript", true)
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
    If Game.IsPluginInstalled("DiaryOfMine.esm")
        hasDOM = true
        DOMPlayerSlaveFaction = Game.GetFormFromFile(0x56C505, "DiaryOfMine.esm") As Faction
    EndIf
    If Game.IsPluginInstalled("DiaryOfMine.esp")
        hasDOM = true
        DOMPlayerSlaveFaction = Game.GetFormFromFile(0x56C505, "DiaryOfMine.esp") As Faction
    EndIf

    VrelkTools_Logging.Log("Monitoring for Actor Events", "ActorWatcherQuestScript", true)


    UnregisterForAllModEvents()

    RegisterForModEvent("vrelk_VampireFeed", "OnVrelkVampireFeed")
    RegisterForModEvent("vrelk_VampireStateChange", "OnVrelkVampireStateChange")
    RegisterForModEvent("vrelk_RaceSwitchComplete", "OnVrelkRaceSwitchComplete")

    RegisterForModEvent("BetterVampires_TurnedVampireFeed", "OnVrelkVampireFeed")
    RegisterForModEvent("PAHE_NewSlave", "OnNewPAHESlave")

    isLoading = False
EndFunction



Event OnVrelkVampireFeed(string nameVampire, string nameVictim, bool victimSleeping)
    VrelkTools_Logging.Log(nameVampire + " fed on " + nameVictim + ". Was Sleeping: " + victimSleeping, "ActorWatcherQuestScript", true)

    string msg = nameVampire + "'s vampiric thirst has been quenched by feeding on " + nameVictim
    If victimSleeping
        msg = msg + ", who was sleeping."
    EndIf

    VrelkTools_MinAi.RequestResponse(msg, "chat", "everyone") ; send generic dialogue to everyone, requesting a response
EndEvent

Event OnVrelkVampireStateChange(Actor akActor, bool isVampire)
    VrelkTools_Logging.Log(GetActorName(akActor) + " is now a vampire: " + isVampire, "ActorWatcherQuestScript", true)

    ; make this do something else later
EndEvent

Event OnVrelkRaceSwitchComplete(Actor akActor, Race oldRace, Race newRace)
    string oldRaceE = PO3_SKSEFunctions.GetFormEditorID(oldRace)
    string newRaceE = PO3_SKSEFunctions.GetFormEditorID(newRace)

    VrelkTools_Logging.Log(GetActorName(akActor) + " changed race from " + oldRaceE + " to " + newRaceE, "ActorWatcherQuestScript", true)

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

    If msg != None && akActor.IsInCombat()
        VrelkTools_MinAi.RegisterEvent(msg, "info") ; actor is in combat, so just send this as general context information
    ElseIf msg != None && !akActor.IsInCombat()
        VrelkTools_MinAi.RequestResponse(msg, "chat", "everyone") ; send generic dialogue to everyone, requesting a response
    EndIf
EndEvent

Event OnNewPAHESlave(PAHCore pahCore, Actor akSlave)
    VrelkTools_Logging.Log("OnNewPAHESlave: " + eventName + " " + strArg + " " + numArg + " " + sender, "ActorWatcherQuestScript", true)

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