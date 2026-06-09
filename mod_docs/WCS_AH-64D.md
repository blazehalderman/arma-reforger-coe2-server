---
workshop_id: "6303360DA719E832"
workshop_url: https://reforger.armaplatform.com/workshop/6303360DA719E832
version: "6.0.14"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L8
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "62CCD69DD17E4F2F # AKI_Core"
  - "58D0FB3206B6F859 # base game"
  - "629B2BA37EFFD577 # WCS_Armaments"
reverse_deps: []
related_memories: []
folder: "WCS_AH-64D_6303360DA719E832"
---

# WCS_AH-64D

> **One-line role**: WCS-faction AH-64D Apache Longbow attack helicopter — heavy gunship with chain gun + Hydra-70 + Hellfire loadout, intended as the US BLUFOR primary CAS asset.

## 1. Overview

Adds the AH-64D Apache Longbow attack helicopter for US/NATO use on this stack. The Apache is the **flagship US gunship**: 30mm M230 chain gun (nose), Hydra-70 unguided rocket pods, and AGM-114 Hellfire ATGMs on the wing stubs. It's a 2-seat tandem aircraft (pilot back, gunner front). Pure attack platform — no cargo bay, no transport role. Highest gameplay value per airframe in this stack for SAD waypoints.

## 2. Functionality / Features

- **Variants shipped**: The Workshop page documents the AH-64D Apache Longbow as the headline variant; no patrol/transport/special sub-variants documented. Spawn via GM Entity Browser → search "AH-64" / "Apache".
- **Weapon loadout**: 30mm M230 chain gun (nose-mounted, gunner-controlled), Hydra-70 unguided rocket pods (wing-mounted), AGM-114 Hellfire ATGMs (wing-mounted). Standard Apache fit.
- **Crew compartments**: 2-seat tandem cockpit (pilot rear, gunner front). No passenger seats.
- **Per WCS contributor pattern**: Same author team as WCS_AH-1S, WCS_KA-52 — expect WCS_Armaments-managed reloadable weapons via helipad, gunner camera with thermal (if WCS_AH-64D_Upgrade `6326F0C7E748AB8A` mod is added — not currently installed; mentioned in `_asks/2026-05-16_darcchopper-heli-extension.md`).

## 3. Configuration

**Config files**: none in `profile_new/profile/WCS_AH-64D/` — WCS heli mods are content-only, no operator-side JSON tunables. Weapon balance is in the prefab itself; physical/AI behavior is handled by the engine (or by DarcChopper if integrated).

**Tunable keys**: _N/A_ — configuration is per-prefab via Workbench, not via runtime config.

## 4. Operator usage

**In-game (Game Master)**:
1. Open GM (default `M`)
2. Entity Browser → search "AH-64" or "Apache"
3. Place at desired spawn
4. Spawn or assign crew (Apache needs 2 — pilot + gunner)
5. As pilot, fly manually OR (with DarcChopper integration via custom shim — see §8) assign waypoint

**Player usage**: spawnable from any vehicle-supporting arsenal/depot in current scenarios; configured loadouts pull from WCS_Armaments.

**Keybinds**: standard vanilla heli flight; no mod-specific binds.

## 5. Compatibility & load order

- **Load order layer**: **L8** (vehicle/weapon content packs) per `MASTER_OBJECTIVE.md`.
- **Must load after**: `WCS_Armaments`, `AKI_Core` (hard deps from `addon.gproj`).
- **Must load before**: any future `AH64DforDarcChopper` compat shim at L8/L9 (would need WCS_AH-64D's prefab present to inherit-and-override).
- **Conflicts with**: none documented on current stack.
- **Synergies with**: `MFDFramework` (cockpit MFD displays — present in stack); future `WCS_AH-64D_Upgrade` would add thermal optics to gunner cam.

## 6. Performance impact

Standard content-pack footprint — adds prefab assets but no per-tick scripts. At-rest cost: zero. Spawned-and-flying cost: 1 rotor physics body + vanilla weapon projectiles. No log spam observed in golden state 2026-05-16 v5.

## 7. Known issues / landmines

_no documented incidents on this stack._ Workshop page reports no known issues; CLAUDE.md contains no AH-64D-specific entries.

## 8. Extending / modding — DarcChopper integration

**Status**: ❌ **NO published DarcChopper compat shim exists for Apache.** A custom Workbench shim must be built — procedure documented in `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 2 and `mod_docs/DarcChopper.md` §8 Option B.

**Per-airframe parameter recommendations** (verbatim from `_asks/2026-05-16_darcchopper-heli-extension.md`):

| Param | Value |
|---|---|
| RotorForce0 / 1 | high lift, high rear |
| Speed Min/Max | 30 / 90 m/s |
| Fly Height Low/High | 80 / 200 m |
| Rocket Prefab | `Hydra70_HEDP_M247` (`{61AF60E0235DC3B1}Prefabs/Weapons/Ammo/Ammo_Rocket_Hydra70_HEDP_M247.et`) |
| Rocket Count | -1 (unlimited) |
| Enemy Search Type | `VEHICLE_ARMORED` |
| Faction | `US` |

**Build priority**: ranked #1 by ROI in the Phase 2 build queue — biggest gameplay payoff for a single custom shim.

**Estimated build time**: 1-2h (Workbench inherit-and-override + SDRC_ChopperComp + test).

## 9. Changelog / verified state

- **Installed version**: 6.0.14
- **Folder**: `profile_new/addons/WCS_AH-64D_6303360DA719E832`
- **Last clean boot**: continuously loaded in golden state 2026-05-16 v5

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/6303360DA719E832)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/6303360DA719E832/changelog)
- Related extension plan: `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md`
- Framework consumer: `mod_docs/DarcChopper.md` §8
