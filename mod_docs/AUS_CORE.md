---
workshop_id: "6276E6E3CC97A22B"
workshop_url: https://reforger.armaplatform.com/workshop/6276E6E3CC97A22B
version: "0.1.15"
author: "TheAussieMerc"
load_order_layer: L0
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "629B2BA37EFFD577 # WCS_Armaments"
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "60ED3CC6E7E40221 # SikorskyMH60DAPProject"
related_memories: []
folder: "AUS_CORE_6276E6E3CC97A22B"
---

# AUS_CORE

> **One-line role**: shared vehicle-weapon asset pack (M134 minigun, FFARs, flight outfits) plus dependency for TheAussieMerc's content — currently consumed only by SikorskyMH60DAPProject.

## 1. Overview

Per the Workshop description, AUS_CORE is "a core mod usable as a dependency which will contain most if not all, of my weapon assets for vehicles." It ships ready-to-attach turret weapons (M134 miniguns), aerial rocket pods (FFARs) and ammunition, plus pilot flight outfits and helmets. The MH-60 DAP content mod is its only declared dependent in this stack.

## 2. Functionality / Features

- M134 minigun turret prefabs (vehicle weapon)
- FFAR (Folding-Fin Aerial Rocket) prefabs + ammunition variants
- Flight outfits / helmets for player characters
- WCS_Armaments hard-dep — shares the WCS turret/weapon rig backbone
- Localization stringtable present (`Language/aus_localization.st`, en_us only — verified in `addon.gproj`)

## 3. Configuration

_N/A_ — no `profile_new/profile/AUS_CORE/` directory exists. Vehicle weapon attach points are per-prefab.

## 4. Operator usage

Not directly consumed. The M134 / FFAR assets surface on MH-60 DAP and (potentially) future TheAussieMerc vehicle prefabs. Flight outfits may appear in arsenal for US-faction players if a SCR_LoadoutTemplate registers them — verify via Game Master entity browser.

## 5. Compatibility & load order

- **Load order layer**: **L0** per CLAUDE.md (L0 list explicitly names `AUS_CORE`).
- **Must load before**: SikorskyMH60DAPProject (L8).
- **Must load after**: WCS_Armaments — resolved at registration time.
- **Conflicts with**: none documented.

## 6. Performance impact

Negligible — content + scripts only, no runtime hooks.

## 7. Known issues / landmines

_None documented_ in CLAUDE.md or memory store.

## 8. Extending / modding

_N/A_ — no public API documented. The mod's value is consuming its turret/rocket prefabs in vehicle Workbench projects.

## 9. Changelog / verified state

- **Installed version**: 0.1.15
- **Folder**: `AUS_CORE_6276E6E3CC97A22B`
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/6276E6E3CC97A22B)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/6276E6E3CC97A22B/changelog)
- Author: TheAussieMerc
