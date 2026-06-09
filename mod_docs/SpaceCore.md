---
workshop_id: "5E389BB9F58B79A6"
workshop_url: https://reforger.armaplatform.com/workshop/5E389BB9F58B79A6
version: "1.3.24"
author: "TheSpaceStrider (contributors: MyVapeBlewUp, AkiraSeki)"
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
  - "5B02128D896F7DE8 # STRYKER"
  - "5B383D4CB27E0D54 # BMP3"
  - "5C721177A220B42F # JLTV"
  - "5D1880C4AD410C14 # <undeclared>"
  - "5D5A20A8AE33C21E # <undeclared>"
  - "5E0AB16BEB16D6A4 # T72A"
  - "5E5C154FEE1094BB # M113"
  - "62D15D0025AE021B # ZSU-23-4"
  - "63120AE07E6C0966 # M2A2"
  - "672EBE927A8B6D96 # <undeclared>"
  - "672F40664F706B72 # <undeclared>"
  - "6730D59067916E3D # <undeclared>"
  - "6730FB5A6302F4C7 # Zagoria89T55"
  - "67330E082FB5B3E1 # <undeclared>"
  - "6734D4F655E54260 # <undeclared>"
  - "6734FB8B6716853D # Zagoria89BMD1and2"
  - "67350654558A9C3D # Zagoria89MTLB"
  - "67351A1364FBF6FB # <undeclared>"
related_memories: []
folder: "SpaceCore_5E389BB9F58B79A6"
---

# SpaceCore

> **One-line role**: shared script library for TheSpaceStrider's vehicle/weapon content mods (Stryker, BMP3, JLTV, T-72A, M113, ZSU-23-4, M2A2 Bradley, Zagoria-89 series, etc.).

## 1. Overview

SpaceCore is a foundational dependency mod: "Created to easily consolidate all of my scripts and make updating them easier" (Workshop page). It ships no operator-visible content of its own — the value is pulled in transitively by ~18 vehicle/content mods in this stack via `addon.gproj Dependencies`. Hard-deps the base game plus `WCS_Armaments` (`629B2BA37EFFD577`), so vehicle content built on SpaceCore can share WCS weapon prefabs.

## 2. Functionality / Features

- Shared scripts used by TheSpaceStrider's vehicle prefabs (no direct gameplay surface)
- Localization stringtables present (cs_cz, de_de, en_us, es_es, fr_fr, it_it, ja_jp etc. visible in `addon.gproj`)
- WCS_Armaments dep means SpaceCore-derived vehicles can use WCS turret/weapon shared rigs
- Inert without a depper installed — purely a library

## 3. Configuration

_N/A_ — no `profile_new/profile/SpaceCore/` directory exists. Configuration is per-prefab in the depper mods.

## 4. Operator usage

Not directly consumed by the operator. The mod is pulled in by content mods (Stryker, BMP3, JLTV, T-72A, M113, ZSU-23-4, M2A2, Zagoria-89 vehicle pack) via gproj deps. To "use" SpaceCore, you install one of its dependents and SpaceCore loads automatically.

## 5. Compatibility & load order

- **Load order layer**: **L0** (Engine/utility frameworks) per CLAUDE.md "Mod stack architecture" (L0 list explicitly names `SpaceCore`).
- **Must load before**: all 18+ reverse-deps listed in frontmatter (vehicle content packs). DAG-resolved automatically via gproj.
- **Must load after**: `WCS_Armaments` (L1 realism core) — but in this stack SpaceCore is declared at L0; the WCS_Armaments hard-dep is resolved at registration time, not by mods[] order.
- **Conflicts with**: none documented.

## 6. Performance impact

Negligible — pure script library, no runtime hooks of its own. Cost is borne by the depper content.

## 7. Known issues / landmines

_None documented_ in CLAUDE.md or memory store.

## 8. Extending / modding

_N/A_ — silent library. To extend, see TheSpaceStrider's content mods for usage patterns; no public API documented on the Workshop page.

## 9. Changelog / verified state

- **Installed version**: 1.3.24
- **Folder**: `SpaceCore_5E389BB9F58B79A6`
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/5E389BB9F58B79A6)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/5E389BB9F58B79A6/changelog)
- Author: TheSpaceStrider
