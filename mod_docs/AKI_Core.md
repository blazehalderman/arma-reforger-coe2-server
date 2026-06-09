---
workshop_id: "62CCD69DD17E4F2F"
workshop_url: https://reforger.armaplatform.com/workshop/62CCD69DD17E4F2F
version: "6.0.8"
author: "AkiraSeki"
load_order_layer: L0
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "629B2BA37EFFD577 # WCS_Armaments"
reverse_deps:
  - "6273146ADFE8241D # AH-6M_LittleBird"
  - "628933A0D3A0D700 # WCS_Mi-24V"
  - "6303360DA719E832 # WCS_AH-64D"
related_memories: []
folder: "AKI_Core_62CCD69DD17E4F2F"
---

# AKI_Core

> **One-line role**: shared script/asset library for AkiraSeki's aviation mods (AH-6M Little Bird, WCS_Mi-24V, WCS_AH-64D).

## 1. Overview

AKI_Core is "Core mod for AkiraSeki Mods" (Workshop page) — a framework dependency for AkiraSeki's content lineup, most notably the rotary-wing aviation content used in this stack. Like SpaceCore, it ships no standalone gameplay; it loads automatically whenever a dependent helicopter content pack is installed.

## 2. Functionality / Features

- Shared scripts for AkiraSeki's three current dependents: AH-6M, WCS_Mi-24V (Hind), WCS_AH-64D (Apache)
- WCS_Armaments dep means AKI_Core-derived helis use shared WCS rocket/MG turret rigs
- Inert without a depper installed

## 3. Configuration

_N/A_ — no `profile_new/profile/AKI_Core/` directory exists.

## 4. Operator usage

Not directly consumed by the operator. Pulled in by the three rotary content packs via gproj deps. Mi-24V and AH-64D are key assets for the COE2 + DarcChopper integration plan (see `mod_docs/DarcChopper.md` §8).

## 5. Compatibility & load order

- **Load order layer**: **L0** per CLAUDE.md (L0 list explicitly names `AKI_Core`).
- **Must load before**: AH-6M_LittleBird, WCS_Mi-24V, WCS_AH-64D (all L8 vehicle/weapon content).
- **Must load after**: WCS_Armaments — resolved at registration time, not by mods[] order.
- **Conflicts with**: none documented.

## 6. Performance impact

Negligible — pure script library.

## 7. Known issues / landmines

_None documented_ in CLAUDE.md or memory store.

## 8. Extending / modding

_N/A_ — silent library; no public API documented.

## 9. Changelog / verified state

- **Installed version**: 6.0.8
- **Folder**: `AKI_Core_62CCD69DD17E4F2F`
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/62CCD69DD17E4F2F)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/62CCD69DD17E4F2F/changelog)
- Author: AkiraSeki
