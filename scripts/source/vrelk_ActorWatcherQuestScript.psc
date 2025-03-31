Scriptname vrelk_ActorWatcherQuestScript Extends Quest
{This listens for and processes incoming events}

Spell Property ActorWatcherSpell Auto
MagicEffect Property ActorWatcherEffect Auto

Faction Property PlayerFollowerFaction Auto
Faction Property PlayerMarriedFaction Auto

Faction Property PAHPlayerSlaveFaction Auto ; 0047DB - Paradise Halls - Player slave
Faction Property DOMPlayerSlaveFaction Auto ; 56C505 - Diary of Mine - Player slave
Faction Property VampirePCFamily Auto ; 0135EB - Better Vampires - Player turned an npc into a vampire

AssociationType Property AssociationCousin Auto
AssociationType Property AssociationSibling Auto

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


    RegisterEvents()

    isLoading = False
EndFunction

Function RegisterEvents()
    UnregisterForAllModEvents()

    RegisterForModEvent("vrelk_VampireFeed", "OnVampireFeedEvent")
    ;RegisterForModEvent("vrelk_VampireStateChange", "OnVampireStateChangeEvent")           ; enable this when it does something
    ;RegisterForModEvent("vrelk_LycanthropyStateChanged", "OnLycanthropyStateChangedEvent") ; enable this when it does something
    RegisterForModEvent("vrelk_RaceSwitchComplete", "OnRaceSwitchCompleteEvent")

    If hasBetterVampires
        RegisterForModEvent("BetterVampires_TurnedVampireFeed", "OnVampireFeedEvent")
    EndIf

    If hasPAH
        RegisterForModEvent("PAHE_NewSlave", "OnNewPaheSlaveEvent")
    EndIf
EndFunction



Event OnVampireFeedEvent(int formVampire, int formVictim, bool victimSleeping)
    Actor akVampire = Game.GetFormEx(formVampire) as Actor
    Actor akVictim = Game.GetFormEx(formVictim) as Actor

    Log(GetActorName(akVampire) + " fed on " + GetActorName(akVictim) + ". Was Sleeping: " + victimSleeping)

    string msg = GetActorName(akVampire) + "'s vampiric thirst for blood has been quenched by feeding on"

    If akVictim.IsDead()
        msg = msg + " the corpse of"
    EndIf

    string playerName = " " + GetActorName(PlayerRef)

    If akVampire == PlayerRef ; Vampire is the player

        If akVampire != PlayerRef && akVampire.IsInFaction(PlayerFollowerFaction) ; check if the vampire is a follower
            msg = msg + " their follower"
        ElseIf akVampire != PlayerRef && akVampire.IsInFaction(PlayerMarriedFaction) ; check if the vampire is married to the victim
            msg = msg + " their spouse"
        ElseIf akVampire.GetRelationshipRank(akVictim) < 0 ; check if the vampire and victim are enemies
            msg = msg + " their enemy"
        ElseIf akVampire.GetRelationshipRank(akVictim) == 1 ; check if the vampire and victim are friends
            msg = msg + " their friend"
        ElseIf akVampire.GetRelationshipRank(akVictim) == 2 ; check if the vampire and victim are confidants
            msg = msg + " their confidant"
        ElseIf akVampire.GetRelationshipRank(akVictim) == 3 ; check if the vampire and victim are allies
            msg = msg + " their ally"
        ElseIf akVampire.GetRelationshipRank(akVictim) == 4 ; check if the vampire and victim are lovers
            msg = msg + " their lover"
        EndIf

    Else ; Non-player vampire
        If akVampire.HasAssociation(AssociationSibling, akVictim) ; check if the vampire and victim are siblings
            msg = msg + " their own sibling"
        ElseIf akVampire.HasAssociation(AssociationCousin, akVictim) ; check if the vampire and victim are cousins
            msg = msg + " their own cousin"
        ElseIf akVampire.HasFamilyRelationship(akVictim) ; check if the vampire and victim are related
            msg = msg + " their own family member"
        ElseIf akVictim.IsInFaction(PlayerFollowerFaction) ; check if the vampire is the player's follower
            msg = msg + playerName + "'s follower"
        ElseIf akVictim.IsInFaction(PlayerMarriedFaction) ; check if the player is married to the victim
            msg = msg + playerName + "'s spouse"
        ElseIf PlayerRef.GetRelationshipRank(akVictim) < 0 ; check if the player and victim are enemies
            msg = msg + playerName + "'s enemy"
        ElseIf PlayerRef.GetRelationshipRank(akVictim) == 1 ; check if the player and victim are friends
            msg = msg + playerName + "'s' friend"
        ElseIf PlayerRef.GetRelationshipRank(akVictim) == 2 ; check if the player and victim are confidants
            msg = msg + playerName + "'s' confidant"
        ElseIf PlayerRef.GetRelationshipRank(akVictim) == 3 ; check if the player and victim are allies
            msg = msg + playerName + "'s' ally"
        ElseIf PlayerRef.GetRelationshipRank(akVictim) == 4 ; check if the player and victim are lovers
            msg = msg + playerName + "'s' lover"
        EndIf
    EndIf

    msg = msg + ", " + GetActorName(akVictim)

    If victimSleeping
        msg = msg + ", while they were sleeping."
    EndIf

    VrelkTools_MinAi.RequestResponse(msg, "chat", "everyone") ; send generic dialogue to everyone, requesting a response
EndEvent

Event OnVampireStateChangeEvent(Actor akActor, bool isVampire)
    Log(GetActorName(akActor) + " is now a vampire: " + isVampire)

    ; make this do something else later
EndEvent

Event OnLycanthropyStateChangedEvent(Actor akActor, bool isLycanthrope)
    Log(GetActorName(akActor) + " is now a wearwolf: " + isLycanthrope)

    ; make this do something else later
EndEvent

Event OnRaceSwitchCompleteEvent(Actor akActor, Race oldRace, Race newRace)
    string oldRaceE = PO3_SKSEFunctions.GetFormEditorID(oldRace)
    string newRaceE = PO3_SKSEFunctions.GetFormEditorID(newRace)

    Log(GetActorName(akActor) + " changed race from " + oldRaceE + " to " + newRaceE)

    string msg = ""

    If newRace == VampireLordRace ; Transform into vampire lord
        msg = GetActorName(akActor) + " just transformed into a vampire lord!"

    ElseIf oldRace == VampireLordRace && newRace != VampireLordRace ; Transform from vampire lord back to human
        msg = GetActorName(akActor) + " just transformed from a vampire lord back to their normal human form."

    ElseIf newRace == WerewolfRace ; Transform into werewolf
        msg = GetActorName(akActor) + " just transformed into a werewolf!"

    ElseIf oldRace == WerewolfRace && newRace != WerewolfRace ; Transform from werewolf back to human
        msg = GetActorName(akActor) + " just transformed from a werewolf back to their normal human form."
    EndIf

    If msg == "" ; not a transformation we care about, so just return
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
        VrelkTools_Logging.Log(msg, "ActorWatcherQuestScript-1.01", true)
    EndIf
EndFunction