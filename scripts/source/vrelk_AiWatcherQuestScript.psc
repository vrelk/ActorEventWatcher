Scriptname vrelk_AiWatcherQuestScript Extends Quest  
{This listens for and processes incoming events}

Spell Property AiWatcherActorSpell Auto
MagicEffect Property AiWatcherActorEffect Auto

Faction Property PlayerFollowerFaction Auto
Faction Property PlayerMarriedFaction Auto

Faction Property PAHPlayerSlaveFaction Auto ; 0047DB - Paradise Halls - Player slave
Faction Property DOMPlayerSlaveFaction Auto ; 56C505 - Diary of Mine - Player slave
Faction Property VampirePCFamily Auto ; 0135EB - Better Vampires - Player turned an npc into a vampire

Actor PlayerRef

Bool isLoading = False
Bool hasPAH = false
Bool hasDOM = false
Bool hasBetterVampires = false


Event OnInit()
    VrelkTools_Logging.Log("OnInit", "AiWatcherQuestScript", true)
	Maintenance()
EndEvent

Event OnLoad()
    VrelkTools_Logging.Log("OnLoad", "AiWatcherQuestScript", true)
	Maintenance()
EndEvent

Function Maintenance()
    If isLoading
		Return
	EndIf

	isLoading = True

    PlayerRef = Game.GetPlayer()

    If !PlayerRef.HasMagicEffect(AiWatcherActorEffect)
        VrelkTools_Logging.Log("Adding AiWatcherActorSpell to PlayerRef", "AiWatcherQuestScript", true)
        AiWatcherActorSpell.Cast(PlayerRef, PlayerRef)
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

    VrelkTools_Logging.Log("Monitoring for Actor Events", "AiWatcherQuestScript", true)


    UnregisterForAllModEvents()

    RegisterForModEvent("vrelk_VampireFeed", "OnVrelkVampireFeed")
    RegisterForModEvent("vrelk_VampireStateChange", "OnVrelkVampireStateChange")
    RegisterForModEvent("vrelk_RaceSwitchComplete", "OnVrelkRaceSwitchComplete")

    RegisterForModEvent("BetterVampires_TurnedVampireFeed", "OnVrelkVampireFeed")
    RegisterForModEvent("PAHE_NewSlave", "OnNewPAHESlave")

    isLoading = False
EndFunction



Event OnVrelkVampireFeed(Actor akVampire, Actor akVictim, bool victimSleeping)
    VrelkTools_Logging.Log(GetActorName(akVampire) + " just fed on " + GetActorName(akVictim), "AiWatcherQuestScript", true)
    
    SendVampireFeedEvent(Game.GetPlayer(), akVictim, akVictim.GetSleepState() >= 3)
EndEvent

Event OnVrelkVampireStateChange(Actor akActor, bool isVampire)
    VrelkTools_Logging.Log(GetActorName(akActor) + " is now a vampire: " + isVampire, "AiWatcherQuestScript", true)

    ; make this do something else later
EndEvent

Event OnVrelkRaceSwitchComplete(Actor akActor, Race oldRace, Race newRace)
    string oldRaceE = PO3_SKSEFunctions.GetFormEditorID(oldRace)
    string newRaceE = PO3_SKSEFunctions.GetFormEditorID(newRace)

    VrelkTools_Logging.Log(GetActorName(akActor) + " changed race from " + oldRaceE + " to " + newRaceE, "AiWatcherQuestScript", true)

    ; make this do something else later, like check if they are a vampire lord now or not
EndEvent

Event OnNewPAHESlave(string eventName, string strArg, float numArg, Form sender)
    VrelkTools_Logging.Log("OnNewPAHESlave: " + eventName + " " + strArg + " " + numArg + " " + sender, "AiWatcherQuestScript", true)

    ; make this do something later, once I figure out what the parameters are
EndEvent




Function SendVampireFeedEvent(Actor akVampire, Actor akVictim, bool victimSleeping)
    VrelkTools_Logging.Log("OnVampireFeed: " + GetActorName(akVampire) + " fed on " + GetActorName(akVictim) + ". Was Sleeping: " + victimSleeping, "VampireFeed", true)



    string msg = GetActorName(akVampire) + "'s vampiric thirst has been quenched by feeding on " + GetActorName(akVictim)
    If victimSleeping
        msg = msg + ", who was sleeping."
    EndIf
    
    VrelkTools_MinAi.RequestResponse(msg, "info", "everyone")
EndFunction


string Function GetActorName(actor akActor)
    If akActor == Game.GetPlayer()
        Return akActor.GetActorBase().GetName()
    Else
        Return akActor.GetDisplayName()
    EndIf
EndFunction