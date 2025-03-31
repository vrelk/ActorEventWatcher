
# vrelk_ActorWatcherEffectScript

### OnVampireFeed

The actor (vampire) just fed on someone.

    RegisterForModEvent("vrelk_VampireFeed", "OnVampireFeed")
    
    Event OnVampireFeed(Actor akVampire, Actor akVictim, bool victimSleeping)
    ; ...
    EndEvent

*   Actor akVampire = The vampire that is feeding
*   Actor akVictim = The actor the vampire is feeding on
*   Bool victimSleeping = Was the victim sleeping at the time

* * *

### OnVampireStateChange

The actor either became a vampire, or was cured.

    RegisterForModEvent("vrelk_VampireStateChange", "OnVampireStateChange")
    
    Event OnVampireStateChange(Actor akActor, bool isVampire)
    ; ...
    EndEvent

*   Actor akActor = The actor that either became a vampire, or was cured.
*   Bool isVampire = Are they now a vampire, or are they now cured.

* * *

### OnRaceSwitchComplete

The actor race just changed.

    RegisterForModEvent("vrelk_RaceSwitchComplete", "OnRaceSwitchComplete")
    
    Event OnRaceSwitchComplete(Actor akActor, Race oldRace, Race newRace)
    ; ...
    EndEvent

*   Actor akActor = The actor in question
*   Race oldRace = The actor's previous race
*   Race newRace = The actor's new race
