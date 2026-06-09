---
workshop_id: "618EBC907D93DE97"
workshop_url: https://reforger.armaplatform.com/workshop/618EBC907D93DE97
version: "0.1.8"
author: "ActionBeard90"
load_order_layer: L7
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps: []
related_memories: []
folder: "BlackCamoPack_618EBC907D93DE97"
---

# BlackCamoPack

> **One-line role**: tiny vehicle reskin pack — five US base-game vehicles in a three-color black + dark-gray camo finish. Part of ActionBeard90's larger DarkPackCollection.

## 1. Overview

Small (~content-only) reskin overlay adding black/gray camo variants of five US military vehicles. Each variant keeps vanilla dirt and mud levels with no logos or decals — "stealth-black" aesthetic. No prefab logic; pure texture/material swap on inherited prefabs.

## 2. Functionality / Features

**Vehicles added (5)** — per Workshop:
- **M1025 M2HB** — HMMWV variant
- **M997** — Ambulance
- **M998 Covered Long** — cargo variant
- **M923A1 Command** — 5-ton truck
- **M923A1 Transport Covered** — 5-ton truck

Author note: part of the DarkPackCollection (a larger family of single-color vehicle reskins).

## 3. Configuration

**Server-side config files**: none. Pure content/reskin overlay.

## 4. Operator usage

- **In-game (Game Master)**: Entity Browser → search "Black" or the vehicle name. Spawn as needed for GM scenarios.

## 5. Compatibility & load order

- **Load order layer**: **L7** by `MASTER_OBJECTIVE.md` co-location with other camo overlays. (Note: not explicitly called out in CLAUDE.md's L7 quick-reference text, which highlights GRS-Patches → GRS-Apparel + BLE; BlackCamoPack tags along as a sibling reskin.)
- **Must load after**: base game only (per `addon.gproj`).
- **Must load before**: nothing (no reverse-deps).
- **Conflicts with**: no known conflicts. Single-color reskin overlays of distinct vehicle GUIDs are conflict-free.

## 6. Performance impact

Negligible. Texture-only reskins.

## 7. Known issues / landmines

- None on this stack. Stable since first install.

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 0.1.8
- **Folder**: `BlackCamoPack_618EBC907D93DE97`
- **Last clean boot**: continuously loaded

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/618EBC907D93DE97)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/618EBC907D93DE97/changelog)
- Author family: DarkPackCollection (other ActionBeard90 reskins)
