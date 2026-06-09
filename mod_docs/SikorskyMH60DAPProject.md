---
workshop_id: "60ED3CC6E7E40221"
workshop_url: https://reforger.armaplatform.com/workshop/60ED3CC6E7E40221
version: "0.6.53"
author: "TheAussieMerc"
load_order_layer: L8
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "6276E6E3CC97A22B # AUS_CORE"
  - "629B2BA37EFFD577 # WCS_Armaments"
  - "64EE818E08AFCF94 # MFDFramework"
reverse_deps: []
related_memories: []
folder: "SikorskyH60Project_60ED3CC6E7E40221"
---

# SikorskyMH60DAPProject

> **One-line role**: MH-60 Black Hawk family — DAP gunship (M134 + Hydra rockets) plus minigun, supply transport, and medevac variants. Early-development (v0.6.53), recent ground-up rebuild.

## 1. Overview

Sikorsky H60 Project is the **MH-60 Black Hawk family** mod by TheAussieMerc, building toward a full SOAR-style suite. Currently shipping 4 variants spanning gunship → supply → medevac roles. v0.6.53 represents a **complete ground-up rebuild** per the changelog — earlier configs may be stale; treat the rebuild as the canonical state. 1.48M downloads, 90% rating.

## 2. Functionality / Features

**Variants shipped (4 confirmed via Workshop page)**:

| Variant | Role | Armament/Features |
|---|---|---|
| MH-60 M134 x2 Minigun | Door-gun escort | 2× M134 miniguns (door-mounted) |
| MH-60 DAP Hydra x4 | Gunship (Direct Action Penetrator) | Dual M134 miniguns + 4× Hydra-70 rocket pods |
| MH-60 Supply | Logistics transport | Unarmed, supply capacity |
| MH-60 MEDEVAC | Medical evacuation | Added v0.6.50 — medical bay loadout |

**Crew compartments**: 2-seat cockpit (pilot + copilot) + 2 door gunner stations (on armed variants) + troop bay (Black Hawk real-world: ~11 troops; in-mod capacity not specified on Workshop).

**Special features**: ground-up rebuild in v0.6.53 — flight model may have changed since previous golden state; verify in-game if regressions appear. Additional DAP/SOAR variants flagged as "forthcoming" by author.

## 3. Configuration

**Config files**: none in `profile_new/profile/SikorskyMH60DAPProject/` — content-only mod.

**Tunable keys**: _N/A_

## 4. Operator usage

**In-game (Game Master)**:
1. GM Entity Browser → search "MH-60" / "MH60" / "Black Hawk" / "DAP"
2. Pick variant: DAP for CAS, M134 for escort, Supply for log runs, MEDEVAC for casualty extraction
3. Crew: 2 pilots + 2 door gunners on armed variants

**Keybinds**: standard vanilla heli flight.

## 5. Compatibility & load order

- **Load order layer**: **L8** (vehicle/weapon content packs).
- **Must load after**: `AUS_CORE`, `WCS_Armaments`, `MFDFramework` (hard deps). **Surprising dep**: AUS_CORE is the TheAussieMerc framework; folder is present in stack but worth checking it loads before this mod.
- **Must load before**: any future MH-60 DarcChopper compat shim.
- **Conflicts with**: none documented.
- **Synergies with**: `WCS_Armaments` (weapon reloads), `MFDFramework` (cockpit MFDs).

## 6. Performance impact

454 MB on disk — **largest single heli mod in the stack** (post-rebuild). At-rest footprint is in-disk only; per-active-heli cost is vanilla. The rebuild bumped file size noticeably; no observed log spam in current golden state.

## 7. Known issues / landmines

_no documented incidents on this stack._

**Cautionary note**: v0.6.53 was a "complete rebuild from the ground up" (Workshop changelog) — if any regression appears after a Steam re-pull, the ground-up rebuild is the most likely root cause vs config drift.

## 8. Extending / modding — DarcChopper integration

**Status**: ❌ **NO published DarcChopper compat shim exists for MH-60 / Black Hawk.** Custom Workbench shim required (procedure in `mod_docs/DarcChopper.md` §8 Option B + `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 2).

**Per-airframe parameter recommendations** (verbatim from extension plan):

| Param | Value |
|---|---|
| RotorForce0 / 1 | medium lift |
| Speed Min/Max | 35 / 80 m/s |
| Fly Height Low/High | 80 / 180 m |
| Rocket Prefab | Hydra-70 (mixed — `Ammo_Rocket_Hydra70.et` baseline or HEDP for harder targets) |
| Rocket Count | -1 (unlimited) |
| Enemy Search Type | `ANY` (mixed-role airframe) |
| Faction | `US` |

**Variant selection note**: the **DAP Hydra x4** prefab is the right base to inherit — it has the rocket pods. Inheriting from MEDEVAC or Supply for SDRC_ChopperComp would not match the offensive parameter set.

**Build priority**: ranked **#3** by ROI in the extension plan.

**Estimated build time**: 1-2h.

## 9. Changelog / verified state

- **Installed version**: 0.6.53 (ground-up rebuild)
- **Folder**: `profile_new/addons/SikorskyH60Project_60ED3CC6E7E40221`
- **Last clean boot**: continuously loaded in golden state 2026-05-16 v5

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/60ED3CC6E7E40221)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/60ED3CC6E7E40221/changelog)
- Related extension plan: `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md`
- Framework consumer: `mod_docs/DarcChopper.md` §8
