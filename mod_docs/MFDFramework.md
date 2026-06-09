---
workshop_id: "64EE818E08AFCF94"
workshop_url: https://reforger.armaplatform.com/workshop/64EE818E08AFCF94
version: "0.4.6"
author: "Colton1070"
load_order_layer: L0
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "60ED3CC6E7E40221 # SikorskyMH60DAPProject"
  - "61957C5C6FB7A773 # H-47Chinook"
  - "66726C1CF64BDCDC # LeesUH-1YVenom"
related_memories: []
folder: "MFDFramework_64EE818E08AFCF94"
---

# MFDFramework

> **One-line role**: cockpit Multi-Function Display (MFD) framework for helicopter content mods (MH-60 DAP, H-47 Chinook, UH-1Y Venom).

## 1. Overview

MFD Framework by Colton1070 provides scriptable cockpit multi-function-display widgets for aviation mods. Per the Workshop description, it ships "multiple prebuilt pages initially designed for the H-47 Chinook" along with customization hooks letting depender mods configure layouts and modify text and progress bars dynamically. Licensed under the Arma Public License.

## 2. Functionality / Features

- Prebuilt MFD page layouts (H-47 Chinook reference set)
- Dynamic text + progress bar widgets driven by depper script
- Configurable layouts per-airframe (each depper mod authors its own page set)
- Currently consumed by MH-60 DAP, H-47 Chinook, UH-1Y Venom in this stack

## 3. Configuration

_N/A_ — no `profile_new/profile/MFDFramework/` directory exists. Per-airframe MFD page configs live in each depper mod's data.pak.

## 4. Operator usage

Not directly consumed. The framework's value appears as functional cockpit instruments inside the three depper helicopters when the operator/player flies them. There is no GM toggle or chat command.

## 5. Compatibility & load order

- **Load order layer**: **L0** per CLAUDE.md (L0 list explicitly names `MFDFramework`).
- **Must load before**: MH-60 DAP, H-47 Chinook, UH-1Y Venom (all L8 heli content).
- **Conflicts with**: none documented.

## 6. Performance impact

Negligible — UI widget framework; per-aircraft cost only when a player is in a cockpit with MFD pages active.

## 7. Known issues / landmines

_None documented_ in CLAUDE.md or memory store.

## 8. Extending / modding

_N/A_ at operator level. Workbench-side: dependers create MFD-page prefabs and bind them to their cockpit prefab using MFDFramework's widget components. No documented public API beyond the H-47 Chinook reference implementation.

## 9. Changelog / verified state

- **Installed version**: 0.4.6
- **Folder**: `MFDFramework_64EE818E08AFCF94`
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/64EE818E08AFCF94)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/64EE818E08AFCF94/changelog)
- Author: Colton1070
