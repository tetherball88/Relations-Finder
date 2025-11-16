# Relations Finder - Skyrim Utility Mod

A high-performance SKSE plugin that provides efficient functions to query NPC relationships in Skyrim, including family, romantic, and professional connections.

## Overview

Relations Finder is a developer utility mod that exposes Skyrim's relationship system through both Papyrus scripts and a C++ API. It efficiently retrieves NPC relationships by building an in-memory actor map and querying the game's native relationship data structures.

> ⚠️ **Note**: This is a developer utility mod. You only need this if another mod specifically requires it as a dependency.

## Requirements

- Skyrim Special Edition
- SKSE64

## Features

- **Zero External Dependencies**: Pure SKSE plugin with no JContainers or other requirements
- **High Performance**: Direct relationship data access with in-memory actor mapping
- **Comprehensive Filtering**: Filter by association type, hierarchy, and relationship rank
- **Both APIs**: Papyrus interface for scripts and C++ API for other SKSE plugins
- **Detailed Logging**: Built-in performance metrics and debugging information

## For Mod Developers

### Papyrus API

The main function provides flexible relationship queries:

```papyrus
; Core function - retrieves NPCs matching relationship criteria
Actor[] Function GetNpcRelationships(Actor npc, string associationType = "", string hierarchy = "any", int minRelationshipRank = -4, int exactRelationshipRank = -999) Global Native
```

**Parameters:**
- `npc` - The NPC to find relationships for
- `associationType` - Type of relationship (see Supported Association Types below). Empty string or "any" for all types
- `hierarchy` - Relationship direction: "primary" (e.g., parent), "secondary" (e.g., child), or "any"
- `minRelationshipRank` - Minimum relationship rank (-4 to +4). Default -4 (archnemesis and above)
- `exactRelationshipRank` - Exact relationship rank to match. Takes priority if not -999 (default)

**Relationship Ranks:**
- `-4` = Archnemesis
- `-3` = Enemy
- `-2` = Foe
- `-1` = Rival
- `0` = Acquaintance
- `1` = Friend
- `2` = Confidant
- `3` = Ally
- `4` = Lover

### Convenience Functions

The mod provides shortcut functions for common queries:

**Family Relationships:**
```papyrus
; Parents and children
Actor[] Function GetParents(Actor npc, int minRelationshipRank = -4)
Actor[] Function GetChildren(Actor npc, int minRelationshipRank = -4)

; Grandparents and grandchildren
Actor[] Function GetGrandparents(Actor npc, int minRelationshipRank = -4)
Actor[] Function GetGrandchildren(Actor npc, int minRelationshipRank = -4)

; Siblings and cousins
Actor[] Function GetSiblings(Actor npc, string hierarchy = "any", int minRelationshipRank = -4)
Actor[] Function GetCousins(Actor npc, string hierarchy = "any", int minRelationshipRank = -4)

; Aunts/Uncles and Nieces/Nephews
Actor[] Function GetAuntUncle(Actor npc, int minRelationshipRank = -4)
Actor[] Function GetNiecesNephews(Actor npc, int minRelationshipRank = -4)

; In-laws (parents, children, siblings, etc.)
Actor[] Function GetInLawParents(Actor npc, int minRelationshipRank = -4)
Actor[] Function GetInLawChildren(Actor npc, int minRelationshipRank = -4)
; ... and more
```

**Romantic Relationships:**
```papyrus
Actor Function GetSpouse(Actor npc, string hierarchy = "any", int minRelationshipRank = -4)
Actor Function GetCourting(Actor npc, string hierarchy = "any", int minRelationshipRank = -4)
Actor[] Function GetAllLovers(Actor npc)  ; Returns all with rank 4
```

**Work/Professional Relationships:**
```papyrus
Actor[] Function GetBusinessPartners(Actor npc, string hierarchy = "any", int minRelationshipRank = -4)
Actor[] Function GetBossEmployees(Actor npc, string hierarchy = "any", int minRelationshipRank = -4)
Actor[] Function GetJarlHousecarl(Actor npc, string hierarchy = "any", int minRelationshipRank = -4)
; ... and more
```

### Supported Association Types

- `Siblings`, `ParentChild`, `AuntUncle`, `Cousins`
- `Spouse`, `Courting`
- `GrandparentGrandchild`, `GreatGrandparentGreatgrandchild`, `GrandAuntUncle`
- `InLawBrotherSister`, `InLawParentChild`, `InLawAuntUncle`, `InLawGrandparentGrandchild`
- `MasterAssistant`, `JarlSteward`, `JarlHousecarl`, `BossEmployee`
- `BusinessPartners`, `Conspirators`, `FavorTarget`

### Usage Example

```papyrus
Actor spouse = TTRF_RelationsFinder.GetSpouse(myNPC)
if spouse
    Debug.Trace(myNPC.GetName() + " is married to " + spouse.GetName())
endif

Actor[] children = TTRF_RelationsFinder.GetChildren(myNPC, minRelationshipRank = 1)
Debug.Trace(myNPC.GetName() + " has " + children.Length + " friendly children")

Actor[] lovers = TTRF_RelationsFinder.GetAllLovers(myNPC)
```

## C++ API for SKSE Plugins

Other SKSE plugins can access Relations Finder through the messaging interface:

```cpp
#include "RelationsFinderAPI.h"

// Request the API
const auto* api = RequestRelationsFinderAPI();
if (api && api->version >= 2) {
    // Use callback-based API (safe across DLL boundaries)
    std::vector<RE::Actor*> results;
    api->GetNpcRelationshipsCallback(
        npc, "Spouse", "any", -4, -999,
        [](RE::Actor* actor, void* userData) {
            static_cast<std::vector<RE::Actor*>*>(userData)->push_back(actor);
        },
        &results
    );
}
```

## Technical Implementation

### How It Works

1. **Actor Map Service**: On game load, builds a map of `TESNPC` (base form) → `ActorHandle` (live actor) for all NPCs with relationships
2. **Relationship Query**: Iterates through the NPC's relationship array, applies filters, and resolves live actors from the map
3. **Efficient Filtering**: Uses case-insensitive string matching and direct FormID lookups
4. **Performance Logging**: Tracks query time, filter statistics, and actor lookup failures

### Performance

- **Map Building**: ~40-50ms on game load (depends on number of loaded NPCs)
- **Relationship Queries**: ~0.01-0.1ms per query (microseconds for most NPCs)
- **Memory**: Minimal overhead - only stores NPCs that have relationships

### Logging

The plugin logs to `SKSE/Plugins/RelationsFinder.log` with:
- Query parameters and results
- Filter statistics (how many relationships filtered by each criterion)
- Performance metrics (execution time)
- Actor lookup failures for debugging

Example log output:
```
[12:34:56] [info] GetNpcRelationships called for 'Lydia' (FormID: 000A2C8E) - Filters: assoc='Spouse', hierarchy='any', minRank=-4, exactRank=-999
[12:34:56] [info] GetNpcRelationships results: 1 matches from 3 total relationships (filtered: 0 by assoc, 2 by hierarchy, 0 by rank, 0 actor not found) - took 0.042 ms
```

## Known Limitations

- Relationships are based on the game's BGSRelationship data structures
- Actor map is rebuilt on new game/load game events

## Version History

**v0.1.0.dev** (Current)
- Initial SKSE implementation
- Direct relationship data access
- Comprehensive Papyrus API with 50+ convenience functions
- C++ API with callback support
- In-memory actor mapping for performance
- Detailed logging and performance metrics