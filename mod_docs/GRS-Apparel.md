---
workshop_id: "65157D09F042428A"
workshop_url: https://reforger.armaplatform.com/workshop/65157D09F042428A
version: "1.0.48"
author: "gl1tch_ (Grey Reign Systems)"
load_order_layer: L7
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "5D0551624969C92E # ZeliksCharacter"
  - "657B064AE0E231DF # GRS-Patches"
  - "606B100247F5C709 # BaconLoadoutEditor"
reverse_deps:
  - "66577E328BF1401E # DarkGruMPPCamos-GRS"
related_memories: []
folder: "GRS-Apparel_65157D09F042428A"
---

# GRS-Apparel

> **One-line role**: tactical/casual apparel content pack (G3 Crye tops/bottoms, MARPAT/Multicam/Tiger/Snow camos, sunglasses, footwear, boonie hats, tactical gloves) — and the **reason BaconLoadoutEditor is re-declared first-class** on this server (hard-deps BLE).

## 1. Overview

The principal apparel content mod from gl1tch_ / Grey Reign Systems. Adds tactical and casual clothing items consumed by player loadouts and by DarkGruMPPCamos-GRS (which reskins certain GRS-Apparel pieces with DarkGru-branded MPP camo patterns). The mod is Work-in-Progress, "PATCH SUPPORT ONLY", and depends hard on `GRS-Patches`, `ZeliksCharacter`, and **`BaconLoadoutEditor`** — the BLE hard-dep is the operationally important fact for this stack.

## 2. Functionality / Features

**Apparel items added** (per Workshop):
- **G3 Crye tops + bottoms** — tactical combat uniforms
- **Camouflage colorways**: MARPAT, Multicam, Tiger Stripe, Snow
- **Eyewear**: Ray-Ban sunglasses
- **Footwear**: Vans
- **Headgear**: Boonie hats
- **Hands**: Tactical gloves designed for firearms use
- **Modular design**: supports reskins and prefab modifications (the DarkGruMPPCamos-GRS overlay extends this)

## 3. Configuration

**Server-side config files**: none in `profile_new/profile/`. Items are surfaced through BLE loadouts and the standard WCS Arsenal / vanilla arsenal UI.

## 4. Operator usage

- **In-game**: GRS-Apparel items appear in the arsenal UI under uniform / vest / headgear slots, and are loadable through BLE.
- **Reskin extension**: when `DarkGruMPPCamos-GRS` is also loaded, additional camo variants appear on GRS-Apparel base prefabs.

## 5. Compatibility & load order

- **Load order layer**: **L7** (apparel/loadouts) per `MASTER_OBJECTIVE.md`.
- **Must load after** (per `addon.gproj` Dependencies):
  - `ZeliksCharacter` (`5D0551624969C92E`) — at L0
  - `GRS-Patches` (`657B064AE0E231DF`) — same L7 layer, but CLAUDE.md DAG fix mandates the order
  - `BaconLoadoutEditor` (`606B100247F5C709`) — at L7
- **CLAUDE.md DAG fix (verbatim)**: "GRS-Patches MUST precede GRS-Apparel (DAG fix 2026-05-13)".
- **CLAUDE.md landmine list dep chain (verbatim)**: "`BaconLoadoutEditor` ← hard-depped by `GRS-Apparel` + `sTsRHSVanillaArsenal`. Removing it kills loadout UI for those mods." — This is **the** reason BLE was re-declared first-class on 2026-05-13.
- **Must load before**: `DarkGruMPPCamos-GRS` (which gproj-hard-deps GRS-Apparel).
- **Conflicts with**: no known conflicts.
- **Synergies with**: `[[BaconLoadoutEditor]]`, `[[DarkGruMPPCamos-GRS]]`, `[[GRS-Patches]]`.

## 6. Performance impact

495 MB content pack — biggest asset-load cost in the apparel layer. No per-tick cost.

## 7. Known issues / landmines

- **The BLE re-add was forced by this mod** (and sTsRHSVanillaArsenal). CLAUDE.md "Landmines discovered 2026-05-13" verbatim: *"Two mods (GRS-Apparel, sTsRHSVanillaArsenal) hard-dep BLE via `addon.gproj`, so removing it from `serverConfig.json mods[]` was a half-measure: folder-presence triggers script compile + execution regardless of modlist declaration. Now declared first-class."* If a future operator considers removing BLE again, they'll cause this mod to fail to register.
- **GRS apparel reconstruction landmine (CLAUDE.md verbatim)**: *"The 'delete locked pak destroys the mod' landmine (proven by GRS apparel reconstruction 2026-05-12): `Remove-Item` on a folder whose `data.pak` is held open by the running server process will leave the locked pak orphaned and remove only the manifest stubs — clients will then fail `RplConnection::ValidationError remote script source code checksum does not match!`. Always kill the server and wait 3-5 seconds for handle release before any folder operation."* This mod's pak was the original casualty on 2026-05-12.
- Mod is WIP ("PATCH SUPPORT ONLY") — Workshop updates may change item inventory.

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 1.0.48
- **Folder**: `GRS-Apparel_65157D09F042428A`
- **Game compat declared**: 1.6.0.108 (server is 1.6.0.119 — no observed issue)
- **Last clean boot**: continuously loaded since 2026-05-12 reconstruction

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/65157D09F042428A)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/65157D09F042428A/changelog)
- Required dep: `[[BaconLoadoutEditor]]` (the critical one), `[[GRS-Patches]]`, `[[ZeliksCharacter]]`
- Downstream reskin: `[[DarkGruMPPCamos-GRS]]`
- CLAUDE.md "Known landmines — keep these disabled" → BaconLoadoutEditor row (the GRS-Apparel hard-dep)
- CLAUDE.md "Landmines discovered 2026-05-13" → folder-presence rule
- CLAUDE.md "Landmines discovered 2026-05-11/12" → pak-lock + reconstruction
