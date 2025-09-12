# Relations Finder - Skyrim Utility Mod

A developer utility mod that provides functions to easily find NPCs' relationships (spouse, courting partners, and lovers) in Skyrim.

## Overview

Relations Finder is a utility mod designed specifically for mod developers who need to retrieve information about NPC relationships. It provides a simple interface to find an NPC's spouse, courting partner, or lovers, which is otherwise difficult to obtain through standard Papyrus functions.

> ⚠️ **Note**: This is not an end-user mod. You only need this mod if another mod specifically requires it as a dependency.

## Requirements

- Skyrim Special Edition
- SKSE
- [JContainers](https://www.nexusmods.com/skyrimspecialedition/mods/16495)
- [powerofthree's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)

## For Developers

### Functions

The mod provides three main functions for retrieving NPC relationships:

```papyrus
; Returns the spouse Actor reference of the given NPC
Actor Function GetSpouse(Actor npc)

; Returns the courting partner Actor reference of the given NPC
Actor Function GetCourting(Actor npc)

; Returns an array of Forms (can be cast to Actor) representing lovers 
; (relationship rank 4) of the given NPC
Form[] Function GetLovers(Actor npc)
```

### Technical Implementation

The mod uses the following approach to find relationships:

1. Adds a temporary custom Faction to the target NPC
2. Starts a utility Quest that:
   - Fills the target NPC to an alias
   - Uses CK's `HasAssociationType` and `GetRelationshipRank` condition functions to find relationships
3. Stores the gathered information in JContainers for caching
4. Removes the temporary Faction and stops the quest
5. Subsequent queries for the same NPC will use the cached data from JContainers

### Performance Considerations

- First-time queries for an NPC will require quest initialization
- Subsequent queries use cached data from JContainers for better performance
- The mod can track up to 5 potential lovers per NPC (relationship rank 4)

### Known Limitations

- Works with Actor references rather than ActorBase
- Uses a quest-based approach instead of direct SKSE functions
- Initial query for each NPC requires temporary quest activation

### Future Development

While this implementation works, a more efficient solution could potentially be developed using SKSE directly. If you develop a more performant SKSE-based solution, please let us know, and we'll gladly redirect users to your implementation.

## Dependencies Documentation

The mod relies on:
- JContainers for data caching and storage
- Papyrus Extender's relationship functions (though limited by ActorBase constraints)

## Version History

Initial Release:
- Implemented core relationship finding functions
- Added JContainer caching system
- Created quest-based relationship detection