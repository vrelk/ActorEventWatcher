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
Bool hasOCF = false
Bool hasDD = false
Bool hasDevCurses = false
Bool hasLola = false

minai_MainQuestController main
minai_AIFF aiff
zadLibs Property zadLib Auto

string playerName ; just so we have what it should be, as things like to change it while functions are running

; Logging toggle
Bool enableLogging = true
String logPrefix = "Vrelk_ActorWatcherQuestScript-0.00"

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

    logPrefix = "Vrelk_ActorWatcherQuestScript-1.09"

    Log("Maintenance")
    
    playerName = GetActorName(PlayerRef)

    If Game.IsPluginInstalled("MinAI.esp")
        aiff = Game.GetFormFromFile(0x802, "MinAI.esp") as minai_AIFF
        main = Game.GetFormFromFile(0x802, "MinAI.esp") as minai_MainQuestController
    Else
        Return
    EndIf
    
    isLoading = True

    If !PlayerRef.HasMagicEffect(ActorWatcherEffect)
        Log("Adding AiWatcherActorSpell to PlayerRef")
        PlayerRef.AddSpell(ActorWatcherSpell)
    EndIf

    If Game.IsPluginInstalled("OCF.esp") ; Object Catigorization Framework
        hasOCF = true
    EndIf

    If Game.IsPluginInstalled("Better Vampires.esp")
        hasBetterVampires = true
        VampirePCFamily = Game.GetFormFromFile(0x0135EB, "Better Vampires.esp") As Faction
        ;aiff.SetModAvailable("BetterVampires", true)
    EndIf
    If Game.IsPluginInstalled("paradise_halls.esm")
        hasPAH = true
        PAHPlayerSlaveFaction = Game.GetFormFromFile(0x0047DB, "paradise_halls.esm") As Faction
        ;aiff.SetModAvailable("ParadiseHalls", true)
    EndIf
    If Game.IsPluginInstalled("DiaryOfMine.esm") ; The newer ESM version of Diary of Mine
        hasDOM = true
        DOMPlayerSlaveFaction = Game.GetFormFromFile(0x56C505, "DiaryOfMine.esm") As Faction
        ;aiff.SetModAvailable("DiaryOfMine", true)
    EndIf
    If Game.IsPluginInstalled("DiaryOfMine.esp") ; The older ESP version of Diary of Mine
        hasDOM = true
        DOMPlayerSlaveFaction = Game.GetFormFromFile(0x56C505, "DiaryOfMine.esp") As Faction
        ;aiff.SetModAvailable("DiaryOfMineLegacy", true)
    EndIf

    If Game.IsPluginInstalled("Devious Devices - Integration.esm")
        hasDD = true
        zadLib = Game.GetFormFromFile(0x00F624, "Devious Devices - Integration.esm") as zadlibs
    EndIf
    
    If Game.IsPluginInstalled("Devious Curses.esp")
        hasDevCurses = true
    EndIf
    
    If Game.IsPluginInstalled("submissivelola_est.esp")
        hasLola = true
    EndIf

    Log("Monitoring for Actor Events")


    RegisterEvents()

    isLoading = False
EndFunction

Function RegisterEvents()
    UnregisterForAllModEvents()

    Log("Registering events")

    ;RegisterForModEvent("vrelk_VampireFeed", "OnVampireFeedEvent")
    ;RegisterForModEvent("vrelk_VampireStateChange", "OnVampireStateChangeEvent")           ; enable this when it does something
    ;RegisterForModEvent("vrelk_LycanthropyStateChanged", "OnLycanthropyStateChangedEvent") ; enable this when it does something
    ;RegisterForModEvent("vrelk_RaceSwitchComplete", "OnRaceSwitchCompleteEvent")

    If hasDD
        RegisterForModEvent("vrelk_zadElectroShock", "OnZadElectroShockScript")
    EndIf

    If hasBetterVampires
        RegisterForModEvent("BetterVampires_TurnedVampireFeed", "OnVampireFeedEvent")
    EndIf

    If hasPAH
        RegisterForModEvent("PAHE_NewSlave", "OnNewPaheSlaveEvent")
    EndIf
    
    If hasLola
        RegisterForModEvent("vrelk_lolaCollarShock", "OnLolaCollarShock")
    EndIf
EndFunction



; 888     888                                d8b                 8888888888                     888
; 888     888                                Y8P                 888                            888
; 888     888                                                    888                            888
; Y88b   d88P 8888b.  88888b.d88b.  88888b.  888 888d888 .d88b.  8888888  .d88b.   .d88b.   .d88888
;  Y88b d88P     "88b 888 "888 "88b 888 "88b 888 888P"  d8P  Y8b 888     d8P  Y8b d8P  Y8b d88" 888
;   Y88o88P  .d888888 888  888  888 888  888 888 888    88888888 888     88888888 88888888 888  888
;    Y888P   888  888 888  888  888 888 d88P 888 888    Y8b.     888     Y8b.     Y8b.     Y88b 888
;     Y8P    "Y888888 888  888  888 88888P"  888 888     "Y8888  888      "Y8888   "Y8888   "Y88888
;                                   888
;                                   888
;                                   888
; only converting to FormID since the event kept getting both Actor and ObjectReference for some reason (and couldn't convert to Actor)
Event OnVampireFeed(Form formVampire, Form formVictim, bool victimSleeping)
    Actor akVampire = formVampire as Actor
    Actor akVictim = formVictim as Actor
    OnVampireFeedEvent(akVampire, akVictim, victimSleeping)
EndEvent

Function OnVampireFeedEvent(Actor akVampire, Actor akVictim, bool victimSleeping)
    Log(GetActorName(akVampire) + " fed on " + GetActorName(akVictim) + ". Was Sleeping: " + victimSleeping)

    string msg = GetActorName(akVampire) + " just quenched their vampiric thirst for blood by feeding on"

    If akVictim.IsDead() ; this never triggers. I guess feeding on a corpse doesn't trigger this event
        msg = msg + " the corpse of"
    EndIf

    string _playerName = " " + GetActorName(PlayerRef)
    bool requestVictimResponse = false


    ; ----
    ; Put these in the order you want them to be checked
    ; ----
    If akVampire == PlayerRef ; Vampire is the player
        If akVampire != PlayerRef && akVampire.IsInFaction(PlayerMarriedFaction) ; check if the vampire is married to the victim
            msg = msg + " their spouse"
            requestVictimResponse = true

        ElseIf akVampire != PlayerRef && akVampire.IsInFaction(PlayerFollowerFaction) ; check if the vampire is a follower
            msg = msg + " their follower"
            requestVictimResponse = true

        ElseIf hasPAH && akVictim.IsInFaction(PAHPlayerSlaveFaction) ; check if the vampire is a slave
            msg = msg + " their slave"
            requestVictimResponse = true

        ; ----
        ; Order doesn't matter for relationship ranks
        ; ----
        ElseIf akVampire.GetRelationshipRank(akVictim) < 0 ; check if the vampire and victim are enemies
            msg = msg + " their enemy"
        ElseIf akVampire.GetRelationshipRank(akVictim) == 1 ; check if the vampire and victim are friends
            msg = msg + " their friend"
        ElseIf akVampire.GetRelationshipRank(akVictim) == 2 ; check if the vampire and victim are confidants
            msg = msg + " their confidant"
        ElseIf akVampire.GetRelationshipRank(akVictim) == 3 ; check if the vampire and victim are allies
            msg = msg + " their ally"
            requestVictimResponse = true
        ElseIf akVampire.GetRelationshipRank(akVictim) == 4 ; check if the vampire and victim are lovers
            msg = msg + " their lover"
            requestVictimResponse = true
        EndIf

    ; ----
    ; Put these in the order you want them to be checked
    ; ----
    Else ; Non-player vampire
        If akVampire.HasAssociation(AssociationSibling, akVictim) ; check if the vampire and victim are siblings
            msg = msg + " their now upset sibling"
            requestVictimResponse = true

        ElseIf akVampire.HasAssociation(AssociationCousin, akVictim) ; check if the vampire and victim are cousins
            msg = msg + " their now irritated cousin"
            requestVictimResponse = true

        ElseIf akVampire.HasFamilyRelationship(akVictim) ; check if the vampire and victim are related
            msg = msg + " their now irritated family member"
            requestVictimResponse = true

        ElseIf hasPAH && akVictim.IsInFaction(PAHPlayerSlaveFaction) && akVampire.IsInFaction(PAHPlayerSlaveFaction)
            msg = msg + " their fellow slave"

        ElseIf hasPAH && akVictim.IsInFaction(PAHPlayerSlaveFaction)
            msg = msg + _playerName + "'s slave"

        ElseIf akVictim.IsInFaction(PlayerFollowerFaction) ; check if the vampire is the player's follower
            msg = msg + _playerName + "'s follower"

        ElseIf akVictim.IsInFaction(PlayerMarriedFaction) ; check if the player is married to the victim
            msg = msg + _playerName + "'s now furious spouse"
            requestVictimResponse = true
        
        ; ----
        ; Order doesn't matter for relationship ranks
        ; ----
        ElseIf PlayerRef.GetRelationshipRank(akVictim) < 0 ; check if the player and victim are enemies
            msg = msg + _playerName + "'s enemy"
        ElseIf PlayerRef.GetRelationshipRank(akVictim) == 1 ; check if the player and victim are friends
            msg = msg + _playerName + "'s friend"
        ElseIf PlayerRef.GetRelationshipRank(akVictim) == 2 ; check if the player and victim are confidants
            msg = msg + _playerName + "'s confidant"
        ElseIf PlayerRef.GetRelationshipRank(akVictim) == 3 ; check if the player and victim are allies
            msg = msg + _playerName + "'s ally"
            requestVictimResponse = true
        ElseIf PlayerRef.GetRelationshipRank(akVictim) == 4 ; check if the player and victim are lovers
            msg = msg + _playerName + "'s lover"
            requestVictimResponse = true
        EndIf
    EndIf

    msg = msg + ", " + GetActorName(akVictim)

    If victimSleeping
        msg = msg + ", while they were sleeping."
    EndIf

    main.RegisterEvent(msg, "infoaction") ; this is showing up as info_infoaction
EndFunction



; 888     888                                d8b                 .d8888b.  888             888
; 888     888                                Y8P                d88P  Y88b 888             888
; 888     888                                                   Y88b.      888             888
; Y88b   d88P 8888b.  88888b.d88b.  88888b.  888 888d888 .d88b.  "Y888b.   888888  8888b.  888888 .d88b.
;  Y88b d88P     "88b 888 "888 "88b 888 "88b 888 888P"  d8P  Y8b    "Y88b. 888        "88b 888   d8P  Y8b
;   Y88o88P  .d888888 888  888  888 888  888 888 888    88888888      "888 888    .d888888 888   88888888
;    Y888P   888  888 888  888  888 888 d88P 888 888    Y8b.    Y88b  d88P Y88b.  888  888 Y88b. Y8b.
;     Y8P    "Y888888 888  888  888 88888P"  888 888     "Y8888  "Y8888P"   "Y888 "Y888888  "Y888 "Y8888
;                                   888
;                                   888
;                                   888
Function OnVampireStateChangeEvent(Actor akActor, bool isVampire)
    Log(GetActorName(akActor) + " is now a vampire: " + isVampire)

    ; make this do something else later
EndFunction



; 888                                         888    888                                         .d8888b.  888             888
; 888                                         888    888                                        d88P  Y88b 888             888
; 888                                         888    888                                        Y88b.      888             888
; 888     888  888  .d8888b  8888b.  88888b.  888888 88888b.  888d888 .d88b.  88888b.  888  888  "Y888b.   888888  8888b.  888888 .d88b.
; 888     888  888 d88P"        "88b 888 "88b 888    888 "88b 888P"  d88""88b 888 "88b 888  888     "Y88b. 888        "88b 888   d8P  Y8b
; 888     888  888 888      .d888888 888  888 888    888  888 888    888  888 888  888 888  888       "888 888    .d888888 888   88888888
; 888     Y88b 888 Y88b.    888  888 888  888 Y88b.  888  888 888    Y88..88P 888 d88P Y88b 888 Y88b  d88P Y88b.  888  888 Y88b. Y8b.
; 88888888 "Y88888  "Y8888P "Y888888 888  888  "Y888 888  888 888     "Y88P"  88888P"   "Y88888  "Y8888P"   "Y888 "Y888888  "Y888 "Y8888
;              888                                                            888           888
;         Y8b d88P                                                            888      Y8b d88P
;          "Y88P"                                                             888       "Y88P"
Function OnLycanthropyStateChangeEvent(Actor akActor, bool isLycanthrope)
    Log(GetActorName(akActor) + " is now a wearwolf: " + isLycanthrope)

    ; make this do something else later
EndFunction



; 8888888b.                            .d8888b.                d8b 888            888
; 888   Y88b                          d88P  Y88b               Y8P 888            888
; 888    888                          Y88b.                        888            888
; 888   d88P  8888b.   .d8888b .d88b.  "Y888b.   888  888  888 888 888888 .d8888b 88888b.
; 8888888P"      "88b d88P"   d8P  Y8b    "Y88b. 888  888  888 888 888   d88P"    888 "88b
; 888 T88b   .d888888 888     88888888      "888 888  888  888 888 888   888      888  888
; 888  T88b  888  888 Y88b.   Y8b.    Y88b  d88P Y88b 888 d88P 888 Y88b. Y88b.    888  888
; 888   T88b "Y888888  "Y8888P "Y8888  "Y8888P"   "Y8888888P"  888  "Y888 "Y8888P 888  888
Function OnRaceSwitchCompleteEvent(Actor akActor, Race oldRace, Race newRace)
    string oldRaceE = PO3_SKSEFunctions.GetFormEditorID(oldRace)
    string newRaceE = PO3_SKSEFunctions.GetFormEditorID(newRace)

    Log(GetActorName(akActor) + " changed race from " + oldRaceE + " to " + newRaceE)

    string msg = ""

    If newRace == VampireLordRace ; Transform into vampire lord
        msg = " just transformed into a vampire lord!"

    ElseIf oldRace == VampireLordRace && newRace != VampireLordRace ; Transform from vampire lord back to human
        msg = " just transformed from a vampire lord back to their normal human form."

    ElseIf newRace == WerewolfRace ; Transform into werewolf
        msg = " just transformed into a werewolf!"

    ElseIf oldRace == WerewolfRace && newRace != WerewolfRace ; Transform from werewolf back to human
        msg = " just transformed from a werewolf back to their normal human form."
    EndIf
    
    If akActor == PlayerRef
        msg = "I" + msg
    Else
        msg = GetActorName(akActor) + msg
    EndIf

    If msg == "" ; not a transformation we care about, so just return
        return
    ElseIf akActor.IsInCombat()
        main.RegisterEvent(msg, "infoaction") ; actor is in combat, so just send this as general context information
    ElseIf !akActor.IsInCombat()
        If akActor == PlayerRef
            main.RequestLLMResponseFromActor(msg, "chat", "everyone", "npc") ; send generic dialogue to everyone, requesting a response)
        Else
            main.RequestLLMResponseNPC(GetActorName(akActor), msg, "everyone") ; send generic dialogue to everyone, requesting a response
        EndIf
    EndIf
EndFunction



;  .d88888b.  888       d8b                   888    8888888888                  d8b                                 888
; d88P" "Y88b 888       Y8P                   888    888                         Y8P                                 888
; 888     888 888                             888    888                                                             888
; 888     888 88888b.  8888  .d88b.   .d8888b 888888 8888888    .d88888 888  888 888 88888b.  88888b.   .d88b.   .d88888
; 888     888 888 "88b "888 d8P  Y8b d88P"    888    888       d88" 888 888  888 888 888 "88b 888 "88b d8P  Y8b d88" 888
; 888     888 888  888  888 88888888 888      888    888       888  888 888  888 888 888  888 888  888 88888888 888  888
; Y88b. .d88P 888 d88P  888 Y8b.     Y88b.    Y88b.  888       Y88b 888 Y88b 888 888 888 d88P 888 d88P Y8b.     Y88b 888
;  "Y88888P"  88888P"   888  "Y8888   "Y8888P  "Y888 8888888888 "Y88888  "Y88888 888 88888P"  88888P"   "Y8888   "Y88888
;                       888                                         888              888      888
;                      d88P                                         888              888      888
;                    888P"                                          888              888      888
Function OnObjectEquippedEvent(Actor akActor, Form akBaseObject, ObjectReference akReference)
    If hasOCF && akBaseObject as Potion
        string msg = ""
        If akBaseObject.HasKeywordString("OCF_AlchDrinkAlcohol")
            msg = GetActorName(akActor) + " just drank " + akBaseObject.GetName() + " (alcohol)"
        ElseIf akBaseObject.HasKeywordString("OCF_AlchDrugSkooma")
            msg = GetActorName(akActor) + " just consumed some " + akBaseObject.GetName() + " (highly addictive narcotic)"
        ElseIf akBaseObject.HasKeywordString("_SHBloodDrink")
            msg = GetActorName(akActor) + " just drank a " + akBaseObject.GetName() + " (alternative to feeding on another person)"
        EndIf

        If msg != ""
            main.RegisterEvent(msg, "infoaction")
        EndIf
    EndIf
EndFunction



; 888b    888                        8888888b.          888               .d8888b.  888
; 8888b   888                        888   Y88b         888              d88P  Y88b 888
; 88888b  888                        888    888         888              Y88b.      888
; 888Y88b 888  .d88b.  888  888  888 888   d88P 8888b.  88888b.   .d88b.  "Y888b.   888  8888b.  888  888  .d88b.
; 888 Y88b888 d8P  Y8b 888  888  888 8888888P"     "88b 888 "88b d8P  Y8b    "Y88b. 888     "88b 888  888 d8P  Y8b
; 888  Y88888 88888888 888  888  888 888       .d888888 888  888 88888888      "888 888 .d888888 Y88  88P 88888888
; 888   Y8888 Y8b.     Y88b 888 d88P 888       888  888 888  888 Y8b.    Y88b  d88P 888 888  888  Y8bd8P  Y8b.
; 888    Y888  "Y8888   "Y8888888P"  888       "Y888888 888  888  "Y8888  "Y8888P"  888 "Y888888   Y88P    "Y8888
Event OnNewPaheSlaveEvent(PAHCore pahCore, Actor akSlave)
    Log(GetActorName(akSlave) + " is now a PAH slave.")

    string msg = "I just enslaved " + GetActorName(akSlave)
    main.RequestLLMResponseFromActor(msg, "chat", "everyone", "npc") ; send player dialogue to everyone, requesting a response
EndEvent



; 8888888888 888                   888                     .d8888b.  888                        888
; 888        888                   888                    d88P  Y88b 888                        888
; 888        888                   888                    Y88b.      888                        888
; 8888888    888  .d88b.   .d8888b 888888 888d888 .d88b.   "Y888b.   88888b.   .d88b.   .d8888b 888  888
; 888        888 d8P  Y8b d88P"    888    888P"  d88""88b     "Y88b. 888 "88b d88""88b d88P"    888 .88P
; 888        888 88888888 888      888    888    888  888       "888 888  888 888  888 888      888888K
; 888        888 Y8b.     Y88b.    Y88b.  888    Y88..88P Y88b  d88P 888  888 Y88..88P Y88b.    888 "88b
; 8888888888 888  "Y8888   "Y8888P  "Y888 888     "Y88P"   "Y8888P"  888  888  "Y88P"   "Y8888P 888  888
Event OnZadElectroShockScript(Form akTarget)
    Actor akActor = akTarget as Actor
    Log("OnZadElectroShockScript: " + GetActorName(akActor))

    bool HasPlug = false
    bool hasPiercing = false
    bool hasVagPlug = false
    bool hasAnalPlug = false
    bool hasVagPiercing = false
    bool hasNipPiercing = false
    string deviceString = "devices"
    int devCount = 0

    If akActor.WornHasKeyword(zadLib.zad_DeviousPlugVaginal)
        hasVagPlug = true
        hasPlug = true
        devCount += 1
    EndIf
    If akActor.WornHasKeyword(zadLib.zad_DeviousPlugAnal)
        hasAnalPlug = true
        hasPlug = true
        devCount += 1
    EndIf
    If akActor.WornHasKeyword(zadLib.zad_DeviousPiercingsNipple)
        hasNipPiercing = true
        hasPiercing = true
        devCount += 1
    EndIf
    If akActor.WornHasKeyword(zadLib.zad_DeviousPiercingsVaginal)
        hasVagPiercing = true
        hasPiercing = true
        devCount += 1
    EndIf


    If hasPlug
        deviceString = Pluralize("plug", hasVagPlug, hasAnalPlug)
    EndIf

    If hasPiercing && hasPlug
        deviceString = deviceString + " and " + Pluralize("piercing", hasVagPiercing, hasNipPiercing)
    ElseIf hasPiercing && !hasPlug
        deviceString = Pluralize("piercing", hasVagPiercing, hasNipPiercing)
    EndIf

    main.RegisterEvent(GetActorName(akActor) + " just got zapped by their " + deviceString + "!", "infoaction")

    if(akActor == PlayerRef)
        main.RequestLLMResponseFromActor("*A painful shock emanating from " + GetActorName(akActor) + "'s " + deviceString + " rips through their body* Ouch! " + PronounItem(devCount) + " damn " + deviceString + " just shocked me again right when I was on the edge! I was so close...", "chat", "everyone", "npc")
    else
        main.RequestLLMResponseNPC(GetActorName(akActor), "*A painful shock emanating from " + GetActorName(akActor) + "'s " + deviceString + " rips through their body* Ouch! " + PronounItem(devCount) + " damn " + deviceString + " just shocked me again right when I was on the edge! I was so close...", "everyone")
    EndIf
EndEvent


;  .d8888b.           888                    d8b                   d8b                        888              888
; d88P  Y88b          888                    Y8P                   Y8P                        888              888
; Y88b.               888                                                                     888              888
;  "Y888b.   888  888 88888b.  88888b.d88b.  888 .d8888b  .d8888b  888 888  888  .d88b.       888      .d88b.  888  8888b.
;     "Y88b. 888  888 888 "88b 888 "888 "88b 888 88K      88K      888 888  888 d8P  Y8b      888     d88""88b 888     "88b
;       "888 888  888 888  888 888  888  888 888 "Y8888b. "Y8888b. 888 Y88  88P 88888888      888     888  888 888 .d888888
; Y88b  d88P Y88b 888 888 d88P 888  888  888 888      X88      X88 888  Y8bd8P  Y8b.          888     Y88..88P 888 888  888
;  "Y8888P"   "Y88888 88888P"  888  888  888 888  88888P'  88888P' 888   Y88P    "Y8888       88888888 "Y88P"  888 "Y888888
Event OnLolaCollarShock(string ownerTitle, string ownerName)
    string msg = ownerTitle + " " + ownerName + " just gave " + playerName + " a crippling shock using their collar as punishment."
    main.RegisterEvent(msg, "infoaction") ; do I want to use this event type for this???
EndEvent


; 8888888b.                    d8b                                  .d8888b.
; 888  "Y88b                   Y8P                                 d88P  Y88b
; 888    888                                                       888    888
; 888    888  .d88b.  888  888 888  .d88b.  888  888 .d8888b       888        888  888 888d888 .d8888b   .d88b.  .d8888b
; 888    888 d8P  Y8b 888  888 888 d88""88b 888  888 88K           888        888  888 888P"   88K      d8P  Y8b 88K
; 888    888 88888888 Y88  88P 888 888  888 888  888 "Y8888b.      888    888 888  888 888     "Y8888b. 88888888 "Y8888b.
; 888  .d88P Y8b.      Y8bd8P  888 Y88..88P Y88b 888      X88      Y88b  d88P Y88b 888 888          X88 Y8b.          X88
; 8888888P"   "Y8888    Y88P   888  "Y88P"   "Y88888  88888P'       "Y8888P"   "Y88888 888      88888P'  "Y8888   88888P'

; FUTURE EXPANSION




string Function PronounItem(int count)
    ;Bool[] has = new Bool[3]
    ;has[0] = has1
    ;has[1] = has2
    ;has[2] = has3

    ;int count = PapyrusUtil.CountTrue(has)

    If count == 1
        Return "this"
    ElseIf count > 1
        Return "these"
    Else
        Return "" ; what's the pronoun for nothing?
    EndIf
EndFunction

string Function Pluralize(string term, bool has1, bool has2, bool has3 = false)
    Bool[] has = new Bool[3]
    has[0] = has1
    has[1] = has2
    has[2] = has3

    int count = PapyrusUtil.CountTrue(has)

    If count > 1
        Return term + "s"
    Else
        Return term
    EndIf
EndFunction

string Function GetActorName(actor akActor)
    If akActor == Game.GetPlayer()
        Return akActor.GetActorBase().GetName()
    Else
        Return akActor.GetDisplayName()
    EndIf
EndFunction

Function Log(string msg, string prefix = "Vrelk_ActorWatcherQuestScript-1.10", bool console = true)
    msg = "[" + prefix + "] " + msg

    If (console)
        MiscUtil.PrintConsole(msg)
    EndIf
    Debug.Trace(msg)
EndFunction
