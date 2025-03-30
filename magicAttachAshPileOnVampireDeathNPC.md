
# magicAttachAshPileOnVampireDeathNPC (Better Vampires)

### OnVampireFeed

The player created vampire just fed on someone.

    RegisterForModEvent("BetterVampires_TurnedVampireFeed", "OnVampireFeed")
    
    Event OnVampireFeed(Actor akVampire, Actor akVictim, bool victimSleeping)
    ; ...
    EndEvent

*   Actor akVampire = The vampire that is feeding
*   Actor akVictim = The actor the vampire is feeding on
*   Bool victimSleeping = Was the victim sleeping at the time