---
workshop_id: "629B2BA37EFFD577"
workshop_url: https://reforger.armaplatform.com/workshop/629B2BA37EFFD577
version: "6.0.25"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "5E389BB9F58B79A6 # SpaceCore"
  - "60ED3CC6E7E40221 # SikorskyMH60DAPProject"
  - "615CC2D870A39838 # WCS_Arsenal"
  - "61957C5C6FB7A773 # H-47Chinook"
  - "6273146ADFE8241D # AH-6M_LittleBird"
  - "6276E6E3CC97A22B # AUS_CORE"
  - "628933A0D3A0D700 # WCS_Mi-24V"
  - "62CCD69DD17E4F2F # AKI_Core"
  - "62D15D0025AE021B # ZSU-23-4"
  - "6303360DA719E832 # WCS_AH-64D"
  - "63120AE07E6C0966 # M2A2"
  - "632F64CB7D65D1FC # <undeclared>"
  - "633343E891C1CD38 # KamAZ5350"
related_memories: []
folder: "WCS_Armaments_629B2BA37EFFD577"
---

# WCS_Armaments

> **One-line role**: vehicle-mounted weapon system + turret stabilization framework — the script-side substrate that vehicle/aircraft content mods (Apache, Mi-24, Chinook, Little Bird, ZSU, M2A2, KamAZ, etc.) hook into.

## 1. Overview

`WCS_Armaments` is **NOT a small-arms catalog** — the name is misleading. Per the Workshop page: *"introduces a robust weapon system for vehicles"* with turret stabilization tech. It's a framework consumed by ~12 vehicle/aircraft mods (a long reverse-dep list: AH-64D, Mi-24V, AH-6M Little Bird, MH-60 DAP, H-47 Chinook, ZSU-23-4, M2A2 Bradley, KamAZ-5350, plus AUS_CORE and AKI_Core). Their turrets and pylon weapons pull from this mod's component implementations.

**Crucial dep-DAG note**: gproj declares only base game. The 13 reverse-deps consume it but it's a script library, not a content provider. If purged, every vehicle/helicopter mod listed above stops functioning correctly. 340 MB on disk.

## 2. Functionality / Features

- Turret stabilization scripts (per Workshop: *"Documentation coming soon"*)
- Vehicle-mounted weapon prefab framework (door MGs, pylons, coax MGs, autocannons)
- Pylon mount system for rotary-wing weapons (hellfires, rocket pods, gun pods)
- Provides component classes consumed by content mods (e.g., `WCS_Mi-24V` Mi-24's pod-mounted rocket and KORD components)
- 339.89 MB on disk

## 3. Configuration

**Config files**: none in `$profile:/`.

_N/A_ — no operator-tunable keys. Per-prefab parameters live on the vehicle mods that consume the framework.

## 4. Operator usage

**In-game**: invisible substrate. Operator interaction is via the vehicle/heli mods built on top: spawn a `WCS_Mi-24V` or `WCS_AH-64D` and use its weapons — those weapons routes through WCS_Armaments under the hood.

**Keybinds / admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content) per `MASTER_OBJECTIVE.md`. Note: technically it's a framework with vehicle-content consumers at L8 — placing at L3 keeps it within the WCS DAG cluster.
- **Must load before**: every reverse-dep listed in frontmatter (WCS heli/vehicle pack, AUS_CORE/AKI_Core, SpaceCore, Sikorsky MH60, H-47, AH-6M, ZSU-23-4, M2A2, KamAZ).
- **Must load after**: base game only.
- **Conflicts with**: none known.
- **Synergies with**: every vehicle content mod in L8. Removing this orphans turret systems on those mods.

## 6. Performance impact

Per-turret tick cost (stabilization solver) — empirically negligible in current stack at typical density (a few active armored vehicles + helis). Untested under heavy mech/heli density.

## 7. Known issues / landmines

- **The huge reverse-dep list** is the landmine: 12+ content mods break if `WCS_Armaments` is purged. Treat as a "safe to purge: NO" mod per [[CLAUDE.md]] §"Mod purge safety protocol" dep-audit rules. The audit pattern in CLAUDE.md will correctly flag this mod's GUID `629B2BA37EFFD577` as being depped by 12+ other mods.
- **Undeclared reverse-dep `632F64CB7D65D1FC`** in the gproj scan — investigate during a future audit to identify which mod this is.
- **Documentation officially "coming soon"** per Workshop — turret-stabilization tuning is undocumented; tune via the consuming vehicle mod's own knobs if exposed.

## 8. Extending / modding

_N/A from operator perspective._ Framework consumers are built in Workbench by mod authors — to add a vehicle that uses WCS_Armaments turret components, you'd subscribe-to-source this mod in Workbench and reference its component classes from a new vehicle prefab. Not operator-script-tunable.

## 9. Changelog / verified state

- **Installed version**: 6.0.25
- **Folder**: `WCS_Armaments_629B2BA37EFFD577`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/629B2BA37EFFD577) — 2.1M+ downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/629B2BA37EFFD577/changelog)
- [[CLAUDE.md]] §"Mod purge safety protocol" — dep-audit before purging anything with reverse-deps
- Reverse-deps: [[WCS_AH-64D]], [[WCS_Mi-24V]], [[AH-6M_LittleBird]], [[H-47Chinook]], [[ZSU-23-4]], [[M2A2]], [[KamAZ5350]], [[AUS_CORE]], [[AKI_Core]], [[SpaceCore]]
