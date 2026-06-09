---
workshop_id: "628933A0D3A0D700"
workshop_url: https://reforger.armaplatform.com/workshop/628933A0D3A0D700
version: "6.0.13"
author: "Worst Case Scenario"
load_order_layer: L8
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "629B2BA37EFFD577 # WCS_Armaments"
  - "62CCD69DD17E4F2F # AKI_Core"
reverse_deps:
  - "6720D3B2BEBC691E # Mi24and28forDarcChopper (BLOCKED — hard-deps WCS_VehicleLock blacklist)"
related_memories: []
folder: "WCS_Mi-24V_628933A0D3A0D700"
---

# WCS_Mi-24V

> **One-line role**: WCS Mi-24V Hind — the dual-role Soviet gunship+transport; primary USSR/OPFOR rotary-wing CAS asset on this stack.

## 1. Overview

The Mi-24V "Hind" is the **iconic Soviet gunship with a passenger bay** — uniquely combines a heavy attack helicopter role (nose cannon + rocket pods + ATGMs) with a transport bay (up to 8 troops). On this stack it's the USSR-faction equivalent of the Apache (AH-64D) for OPFOR CAS. Workshop ships v6.0.13, last modified 2026-05-05, 1.64M downloads, 87% rating.

## 2. Functionality / Features

- **Variants shipped**: Workshop page does not enumerate specific variants. WCS authoring convention (see WCS_AH-6M and WCS_KA-52) is multiple liveries / loadout sub-variants — verify via in-game GM Entity Browser search "Mi-24" or "Hind".
- **Weapon loadout** (Mi-24V real-world standard, expected in this mod):
  - YakB 12.7mm gatling gun (nose) OR 23mm GSh-23 cannon (depending on variant)
  - UB-32 / B-8V20 rocket pods (S-5 or S-8 rockets — `Ammo_Rocket_S5.et` family from DarcChopper's tested list maps here)
  - 9M114 Shturm or 9M120 Ataka ATGMs (wing-stub mounted)
- **Crew compartments**: 2-seat tandem cockpit (pilot rear, gunner front) **+ 8-troop passenger bay** in the rear — the marquee Mi-24 feature. No other heli in the stack combines gunship + APC role.
- **Special features**: WCS_Armaments reload mechanism; thermal-equipped variants likely (verify in GM).

## 3. Configuration

**Config files**: none in `profile_new/profile/WCS_Mi-24V/` — content-only mod.

**Tunable keys**: _N/A_

## 4. Operator usage

**In-game (Game Master)**:
1. GM Entity Browser → search "Mi-24" / "Mi24" / "Hind"
2. Spawn the variant matching the operation (CAS vs CAS+insertion)
3. Crew: 2 (pilot + gunner), passenger bay supports armed troops
4. As OPFOR commander, this is the primary heli for "raid + extract" missions

**Keybinds**: standard vanilla heli flight.

## 5. Compatibility & load order

- **Load order layer**: **L8** (vehicle/weapon content packs).
- **Must load after**: `WCS_Armaments`, `AKI_Core` (hard deps).
- **Must load before**: any future Mi-24 DarcChopper compat shim.
- **Conflicts with**: none documented.
- **Synergies with**: `WCS_Armaments` (reloads); `DarkGruFactions` and `Arma2Factions` (OPFOR pilot character prefabs).
- **Reverse-dep landmine**: `Mi24and28forDarcChopper` (`6720D3B2BEBC691E`) is a published DarcChopper compat shim — **but it hard-deps WCS_VehicleLock (`61BA4EB5C886D396`) which is BLACKLISTED on this stack** (see CLAUDE.md "Known landmines" — *"Breaks vehicle occupancy — only one player can enter"*). See §8 below.

## 6. Performance impact

Standard content-pack footprint. No observed log spam in golden state 2026-05-16 v5.

## 7. Known issues / landmines

_no documented incidents on this stack._ The mod itself is clean; the only landmine is the *reverse-dep* via `Mi24and28forDarcChopper` — covered in §8 below, not in this section because it's about a *consumer* mod, not Mi-24V itself.

## 8. Extending / modding — DarcChopper integration

**Status**: ⚠️ **Published compat shim EXISTS but is BLOCKED for this stack.**

The shim `Mi24and28forDarcChopper` (`6720D3B2BEBC691E`) would normally be the no-Workbench option, but it hard-deps `WCS_VehicleLock` which is on CLAUDE.md's permanent disabled list (breaks vehicle occupancy — only one player can enter any vehicle). Installing the shim would force Steam to pull WCS_VehicleLock, and per the *"folder-presence triggers script execution regardless of declaration"* landmine (CLAUDE.md 2026-05-13), even leaving WCS_VehicleLock out of `mods[]` after install wouldn't stop its scripts from compiling.

**Final recommendation**: skip the shim, build a custom Workbench shim instead. Procedure in `mod_docs/DarcChopper.md` §8 Option B + `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 2.

**Per-airframe parameter recommendations** (Mi-24 is not listed in the extension plan's table by name — the plan tables Apache/Little Bird/MH-60/AH-1S/UH-1Y/Chinook explicitly; KA-52 has the existing shim. For Mi-24, derive from the airframe envelope):

| Param | Value (Mi-24 inferred — verify in test) |
|---|---|
| RotorForce0 / 1 | high lift, high rear (Mi-24 is heavy — comparable to Apache) |
| Speed Min/Max | 30 / 95 m/s (real-world Vne ~335 km/h; cap lower for engagement) |
| Fly Height Low/High | 80 / 200 m |
| Rocket Prefab | `Ammo_Rocket_S5_FRAG_S5MO` (`{EF17BED6DCEE4DE4}`) or `S5_HEDP_S5KO` (`{EE65544BA845C458}`) — Warsaw Pact convention |
| Rocket Count | -1 (unlimited; or limit to 80 to model real UB-32 + B-8 capacity) |
| Enemy Search Type | `VEHICLE_ARMORED` (gunship role) |
| Faction | `USSR` |

**Build priority**: high — Mi-24 is the OPFOR counterpart to Apache; build alongside Apache for balanced air-CAS coverage on both sides.

**Estimated build time**: 1-2h.

## 9. Changelog / verified state

- **Installed version**: 6.0.13
- **Folder**: `profile_new/addons/WCS_Mi-24V_628933A0D3A0D700`
- **Last clean boot**: continuously loaded in golden state 2026-05-16 v5

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/628933A0D3A0D700)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/628933A0D3A0D700/changelog)
- Related extension plan: `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` (Mi24and28forDarcChopper blocked-shim analysis)
- Framework consumer: `mod_docs/DarcChopper.md` §8
- WCS_VehicleLock landmine: `CLAUDE.md` "Known landmines" table
