---
workshop_id: "64CB39E57377C861"
workshop_url: https://reforger.armaplatform.com/workshop/64CB39E57377C861
version: "6.0.9"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L8
status: deployed-only
last_verified: 2026-05-16
declared_in:
  - deployed
hard_deps:
  - "629B2BA37EFFD577 # WCS_Armaments"
reverse_deps: []
related_memories:
  - golden_state_2026_05_16_v5.md
folder: ""
---

# WCS_AH-1S

> **One-line role**: WCS AH-1S Cobra attack helicopter — agile, fast, US-side fire-support gunship. Deployed-only (not in local stack).

## 1. Overview

The AH-1S Cobra is the **classic narrow-fuselage US gunship** — predecessor to the Apache, smaller and more agile, two-seat tandem cockpit. Added to the **deployed stack only** during iter3 (2026-05-15/16) as part of the WCS vehicle catalog gap-fill (alongside WCS_KA-52 and WCS_AH-1S → ~110 of 299 missing prefab errors resolved per [[golden_state_2026_05_16_v5]] memory). Highest-rated WCS heli on Workshop (97%).

## 2. Functionality / Features

- **Variants shipped**: Workshop page does not enumerate specific variants. WCS authoring convention (see WCS_AH-6M's 10-variant model) likely means multiple variant prefabs — verify via GM Entity Browser search "AH-1S" / "Cobra".
- **Weapon loadout** (AH-1S real-world standard, expected in this mod):
  - M197 20mm 3-barrel gatling cannon (nose turret, gunner-aimed)
  - Hydra-70 unguided rocket pods (wing-stub mounted)
  - BGM-71 TOW ATGMs (wing-stub mounted — Cobra was the original TOW-capable helicopter)
- **Crew compartments**: 2-seat tandem cockpit (pilot rear, gunner front). No passenger seats — pure attack platform.
- **Special features**: WCS_Armaments-managed reloads.

## 3. Configuration

**Config files**: none in `profile_new/profile/WCS_AH-1S/` — content-only mod (no local profile folder since this mod is deployed-only).

**Tunable keys**: _N/A_

## 4. Operator usage

**In-game (Game Master)** — deployed server only:
1. GM Entity Browser → search "AH-1S" / "Cobra"
2. Pick variant matching mission (likely standard CAS or anti-armor with TOW loadout)
3. Crew: 2 (pilot + gunner)
4. Pairs well with AH-64D for **mixed light + heavy CAS** flights (Cobra for anti-infantry/light, Apache for heavy)

**Keybinds**: standard vanilla heli flight.

## 5. Compatibility & load order

- **Load order layer**: **L8** (vehicle/weapon content packs).
- **Must load after**: `WCS_Armaments` (hard dep). AKI_Core dep not declared in `addon.gproj` per Workshop (single dep listed) — verify if registration ever fails.
- **Must load before**: any future AH-1S DarcChopper compat shim.
- **Conflicts with**: none documented.
- **Synergies with**: `WCS_Armaments`, other WCS heli mods (consistent reload + camera UX).
- **Deployment scope**: **deployed-only** — present in `serverconfig-deployed.json` but NOT in `serverConfig.json` (local). On-disk folder absent on local; download triggered on deployed-server boot only.

## 6. Performance impact

132 MB on disk on deployed. No observed log spam in deployed golden-state v5 sessions.

## 7. Known issues / landmines

_no documented incidents on this stack._ Was specifically added as part of the iter3 missing-prefab fix per [[golden_state_2026_05_16_v5]] — its addition was net-positive for error reduction.

## 8. Extending / modding — DarcChopper integration

**Status**: ❌ **NO published DarcChopper compat shim exists for Cobra.** Custom Workbench shim required (procedure in `mod_docs/DarcChopper.md` §8 Option B + `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 2).

**Per-airframe parameter recommendations** (verbatim from extension plan):

| Param | Value |
|---|---|
| RotorForce0 / 1 | medium lift |
| Speed Min/Max | 30 / 80 m/s |
| Fly Height Low/High | 80 / 180 m |
| Rocket Prefab | `Ammo_Rocket_Hydra70.et` (baseline Hydra-70) |
| Rocket Count | -1 (unlimited) |
| Enemy Search Type | `VEHICLE_ARMORED` (anti-armor gunship; Cobra was TOW-capable from inception) |
| Faction | `US` |

**Build priority**: ranked **#4** by ROI in the extension plan, with the explicit caveat *"deployed-only. Build only if you're still using the deployed stack."* If the deployed Linux container is decommissioned, this airframe drops out of scope.

**Estimated build time**: 1-2h. Note: since this is deployed-only, the published shim needs to land on Workshop AND be added to `serverconfig-deployed.json` (not `serverConfig.json` local).

## 9. Changelog / verified state

- **Installed version**: 6.0.9 (per Workshop page)
- **Folder**: present only on deployed server (Linux container)
- **Last clean boot**: deployed golden state 2026-05-16 v5 (iter3 fix)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/64CB39E57377C861)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/64CB39E57377C861/changelog)
- Related extension plan: `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md`
- Framework consumer: `mod_docs/DarcChopper.md` §8
- Related memory: `[[golden_state_2026_05_16_v5]]` (iter3 addition rationale)
