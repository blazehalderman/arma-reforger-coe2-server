---
workshop_id: "615818DA7C0343FD"
workshop_url: https://reforger.armaplatform.com/workshop/615818DA7C0343FD
version: "6.0.8"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "61C74A8B647617DA # WCS_Attachments"
  - "62A668F513428630 # WCS_Scopes"
  - "631C3C1AEE9C90BC # WCS_Sounds"
reverse_deps:
  - "615CC2D870A39838 # WCS_Arsenal"
  - "65CF7AE8574E06D2 # WCS_Weapons"
related_memories: []
folder: "WCS_RU_615818DA7C0343FD"
---

# WCS_RU

> **One-line role**: RU/OPFOR faction + full Russian-side small-arms / gear arsenal for the WCS stack (one half of the WCS faction pair; pairs with WCS_NATO).

## 1. Overview

WCS_RU is the **Russian faction registration + content** half of the WCS pair. It registers an SCR_Faction entry for "RU"/"USSR" and ships AK-pattern weapons, Russian-style characters, and Russian-side gear. Pairs 1:1 with [[WCS_NATO]] — `WCS_Weapons` declares both as hard deps in its gproj.

Note: this mod is **weapons-and-characters only**; it ships no helicopters, no vehicles, no tanks. See [[CLAUDE.md]] §"Abandoned: IPC Proxy War via IPC_SoldierList.json" — historical evidence that WCS_RU has no vehicle prefabs (the proxy-war hack failed in part because of this).

## 2. Functionality / Features

- Registers `SCR_Faction` for **RU** (basis for USSR loadout template in WCS_Arsenal)
- Ships RU-side weapon prefabs (AK-74, AKM, PKM, SVD, etc. — full list not enumerated on Workshop page)
- Ships RU-side character prefabs (uniformed Russian-pattern soldiers wired via `WCS_Clothing`)
- Ships RU-side gear (AK mags, Russian-pattern grenades/IFAKs)

## 3. Configuration

**Config files**: none in `$profile:/`. All tuning happens upstream via WCS_LoadoutEditor + WCS_Arsenal.

_N/A_ — no tunable keys.

## 4. Operator usage

**In-game**: USSR/RU faction selectable via COE2 faction picker. RU weapons appear in arsenal boxes on USSR-affiliated bases or via GM-spawned arsenal. Character prefabs via GM Entity Browser (F1 → search "USSR_Army_*").

**Keybinds**: none.

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** per `MASTER_OBJECTIVE.md`.
- **Must load before**: `WCS_Weapons`, `WCS_Arsenal`
- **Must load after**: `WCS_Attachments`, `WCS_Scopes`, `WCS_Sounds`, `WCS_Weapon_Scripts` (transitive)
- **Conflicts with**: nothing in current stack. Same SCR_Faction key-override caveat as WCS_NATO if another mod registers a competing USSR/RU faction.
- **Synergies with**: `WCS_RHS_Weapons` (RHS AKs use this catalog's attachment slots), `sTsRHSVanillaArsenal`.

## 6. Performance impact

Negligible runtime cost — content-only. 440 MB on-disk; loads into arsenal cache once at boot.

## 7. Known issues / landmines

- **No character prefabs for IPC proxy use** — `WCS_RU` was tested 2026-05-13 as a proxy-faction substitute (swap WCS_RU prefabs into IPC's FIA bucket). Failed because WCS_RU ships **weapons-only**; the deps in `addon.gproj` are only base + WCS_Attachments/Scopes/Sounds. See [[CLAUDE.md]] §"Abandoned: IPC Proxy War" point 1. **Wait — review note**: WCS_RU DOES ship character prefabs (USSR_Army_* discoverable via GM F1). The CLAUDE.md note's "WCS_RU is weapons-only" is more precisely "WCS_RU character prefabs are not in the script-discoverable bucket IPC scans." Read the CLAUDE.md note as the operator-relevant truth.
- See `WCS_LoadoutEditor/audit/incidents/*.jsonl` for any stale-prefab errors after WCS_RU updates.
- Same `version: ""` mandate as all WCS mods.

## 8. Extending / modding

_N/A_ — content mod, no framework hooks. Forking license is non-commercial.

## 9. Changelog / verified state

- **Installed version**: 6.0.8 (Workshop current)
- **Folder**: `WCS_RU_615818DA7C0343FD`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/615818DA7C0343FD) — 1.69M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/615818DA7C0343FD/changelog)
- [[CLAUDE.md]] §"Abandoned: IPC Proxy War via IPC_SoldierList.json" — proxy-faction failure mode
- Companion mod: [[WCS_NATO]] (the BLUFOR half)
