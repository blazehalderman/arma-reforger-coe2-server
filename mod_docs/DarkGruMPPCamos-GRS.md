---
workshop_id: "66577E328BF1401E"
workshop_url: https://reforger.armaplatform.com/workshop/66577E328BF1401E
version: "1.0.5"
author: "CMinano98 2.0 (textures: Mr. Enward; framework: gl1tch_/GRS)"
load_order_layer: L7
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "65157D09F042428A # GRS-Apparel"
  - "5D0551624969C92E # ZeliksCharacter"
  - "65DACC64CE785B6C # GRS-DevFramework"
  - "58D0FB3206B6F859 # base game"
  - "65EC8C419D243264 # RedactedCore (transitive dep on disk)"
reverse_deps: []
related_memories: []
folder: "DarkGruMPPCamos-GRS_66577E328BF1401E"
---

# DarkGruMPPCamos-GRS

> **One-line role**: camo overlay that adds Tier-2 and Tier-3 MPP (Milsim Partnership Program) faction skins on top of GRS-Apparel and DarkGruFactions unit prefabs.

## 1. Overview

Bridge content pack. Surfaces additional camo patterns for the DarkGru-branded faction units (Tactical Turtlenecks at Tier 3; Сerафимы / Spectre Bravo PMC / WMD Elite Forces at Tier 2) by extending the GRS-Apparel asset framework with new texture/material variants. Author credits gl1tch_grs for the underlying GRS line and Mr. Enward for textures.

## 2. Functionality / Features

**Per Workshop**:
- **Tier 3 groups**: Tactical Turtlenecks
- **Tier 2 groups**:
  - Сerафимы (Temporary Top)
  - Spectre Bravo PMC
  - WMD Elite Forces
- **Extras**: "A bag of Chips"

## 3. Configuration

**Server-side config files**: none. Pure content overlay riding on GRS-Apparel's framework.

## 4. Operator usage

- **In-game**: items surface through the arsenal UI (where the DarkGru factions have arsenal coverage) and through BLE loadout slots when authoring loadouts for the DarkGru factions.
- **CLAUDE.md cosmetic-noise note**: `SCR_Faction trying to get entity list of type 'ITEM' but there is no catalog with that type for faction 'DarkGru Operators'` is one of the cosmetic spam lines fired hundreds of times per session — confirmed unrelated to gameplay impact for this overlay.

## 5. Compatibility & load order

- **Load order layer**: **L7** (apparel/loadouts) per `MASTER_OBJECTIVE.md`.
- **Must load after** (per `addon.gproj` Dependencies, all gproj-hard):
  - `GRS-Apparel` (`65157D09F042428A`) — same L7 layer
  - `ZeliksCharacter` (`5D0551624969C92E`) — at L0
  - `GRS-DevFramework` (`65DACC64CE785B6C`) — at L0
  - `RedactedCore` (`65EC8C419D243264`) — transitive on disk only (NOT in `mods[]`)
- **The DarkGruFactions tie**: gproj does NOT hard-dep `DarkGruFactions` directly, but the camos are visually meaningful only when DarkGruFactions' unit prefabs are also loaded.
- **CLAUDE.md verbatim dep chain**: "`RedactedCore` ← `DarkGruMPPCamos-GRS`. GRS dep chain." (from the "Mod purge safety protocol" example list)
- **Conflicts with**: no known conflicts.
- **Synergies with**: `[[DarkGruFactions]]`, `[[GRS-Apparel]]`, `[[GRS-Patches]]`.

## 6. Performance impact

Negligible. Texture/material overlay only.

## 7. Known issues / landmines

- **RedactedCore is a transitive on-disk dep** (`65EC8C419D243264`). CLAUDE.md "Mod purge safety protocol" lists this exact chain: *"`RedactedCore` ← `DarkGruMPPCamos-GRS`. GRS dep chain."* — if a future operator runs a purge audit and considers deleting RedactedCore (which is undeclared in `mods[]`), this mod's registration breaks. The audit pattern in CLAUDE.md is the protection.
- Mod is small and stable; no behavior landmines observed on this stack.

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 1.0.5
- **Folder**: `DarkGruMPPCamos-GRS_66577E328BF1401E`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/66577E328BF1401E)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/66577E328BF1401E/changelog)
- License: Arma Public License No Derivatives (APL-ND)
- Required deps: `[[GRS-Apparel]]`, `[[GRS-DevFramework]]`, `[[ZeliksCharacter]]`
- Conceptual sibling: `[[DarkGruFactions]]` (the unit families this reskins)
- CLAUDE.md "Mod purge safety protocol" — RedactedCore dep-chain example
