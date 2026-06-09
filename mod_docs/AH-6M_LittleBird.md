---
workshop_id: "6273146ADFE8241D"
workshop_url: https://reforger.armaplatform.com/workshop/6273146ADFE8241D
version: "6.0.21"
author: "Worst Case Scenario"
load_order_layer: L8
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "629B2BA37EFFD577 # WCS_Armaments"
  - "62CCD69DD17E4F2F # AKI_Core"
reverse_deps: []
related_memories: []
folder: "WCS_AH-6M_6273146ADFE8241D"
---

# AH-6M_LittleBird

> **One-line role**: WCS Little Bird family — 10 variants spanning transport (MH-6), gunship (AH-6), and supply roles. Highest variant-count of any heli mod in this stack.

## 1. Overview

The Little Bird is the **light, fast, low-profile gunship** of the stack — perfect for tight infiltration runs, urban CAS, and supply drops. WCS ships **10 variants** in this single mod, covering US and USSR factions with unique liveries. Spans MH-6 transport (bench seats) through dedicated gunship loadouts (M134, rockets, ATGMs, Stingers, GAU-19). Both pilot- and copilot-controlled weapons depending on variant.

## 2. Functionality / Features

**Variants shipped (10 total)** — confirmed from Workshop page:

| Variant | Role | Weapon/Capacity |
|---|---|---|
| `MH6M` | Transport | 8 passenger bench seats |
| `MH6M Supply` | Logistics | 600 supply capacity |
| `AH6M Standard` | Gunship | (base armament) |
| `AH6M M134` | Gunship | M134 miniguns |
| `AH6M RKT` | Gunship | LAU-86 rocket pods |
| `AH6M ATGMX1` | Gunship | 1× AGM-114 Hellfire |
| `AH6M ATGMX2` | Gunship | 2× AGM-114 Hellfire |
| `AH6M AIM92X1` | A2A | 1× AIM-92 Stinger |
| `AH6M AIM92X2` | A2A | 2× AIM-92 Stinger |
| `AH6M GAU19` | Heavy gunship | 20mm GAU-19 gatling |

**Crew compartments**: 2-seat cockpit (pilot + copilot) + up to 8 bench passengers on MH-6 transport variants.

**Special features**:
- Reloadable weapons via helipad (WCS_Armaments-backed)
- Gunner cameras on all variants
- Thermal imaging available with `AH6M_Upgrade` mod (not currently installed; would be a separate Workshop subscription)

## 3. Configuration

**Config files**: none in `profile_new/profile/AH-6M_LittleBird/` — content-only mod.

**Tunable keys**: _N/A_

## 4. Operator usage

**In-game (Game Master)**:
1. GM Entity Browser → search "AH6M" / "MH6M" / "Little Bird"
2. Each of the 10 variant prefabs is independently spawnable
3. For transport ops, pick `MH6M` (8 bench seats)
4. For SAD CAS, pick `AH6M RKT` or `AH6M GAU19`

**Player usage**: vehicle catalogs in scenarios pull individual variants depending on faction loadout config.

**Keybinds**: standard vanilla heli flight.

## 5. Compatibility & load order

- **Load order layer**: **L8** (vehicle/weapon content packs).
- **Must load after**: `WCS_Armaments`, `AKI_Core` (hard deps).
- **Must load before**: any future `AH6MforDarcChopper` compat shim.
- **Conflicts with**: none documented on current stack.
- **Synergies with**: `WCS_Armaments` (reload system); optional `AH6M_Upgrade` (thermal optics — not installed).

## 6. Performance impact

Largest variant-count of any heli mod in the stack (10 variants → ~10× the prefab metadata to register), but at-rest cost is still zero. Per-active-heli cost is vanilla. No observed log spam.

## 7. Known issues / landmines

_no documented incidents on this stack._

## 8. Extending / modding — DarcChopper integration

**Status**: ❌ **NO published DarcChopper compat shim exists for Little Bird.** Custom Workbench shim required (procedure in `mod_docs/DarcChopper.md` §8 Option B + `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 2).

**Per-airframe parameter recommendations** (verbatim from extension plan):

| Param | Value |
|---|---|
| RotorForce0 / 1 | low lift, agile rear |
| Speed Min/Max | 40 / 75 m/s |
| Fly Height Low/High | 50 / 150 m |
| Rocket Prefab | `Hydra70_HE_M229` (`{072A755D5CB85D47}Prefabs/Weapons/Ammo/Ammo_Rocket_Hydra70_HE_M229.et`) |
| Rocket Count | 24 (limited — Little Bird carries less) |
| Enemy Search Type | `ANY_CHAR` (anti-infantry role) |
| Faction | `US` |

**Variant selection note**: when building the shim, the best base prefab to inherit is `AH6M RKT` (rocket gunship — pairs cleanly with `SDRC_ChopperComp.RocketPrefabs`). Don't shim `MH6M` (transport — has no offensive role; `Rocket Count=0`, `Enemy Search Type=NONE`).

**Build priority**: ranked #2 by ROI (fast, low-profile gunship complements Apache's heavy-CAS role).

**Estimated build time**: 1-2h.

## 9. Changelog / verified state

- **Installed version**: 6.0.21
- **Folder**: `profile_new/addons/WCS_AH-6M_6273146ADFE8241D`
- **Last clean boot**: continuously loaded in golden state 2026-05-16 v5

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/6273146ADFE8241D)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/6273146ADFE8241D/changelog)
- Related extension plan: `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md`
- Framework consumer: `mod_docs/DarcChopper.md` §8
