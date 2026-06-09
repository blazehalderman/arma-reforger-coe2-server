---
workshop_id: "5D0551624969C92E"
workshop_url: https://reforger.armaplatform.com/workshop/5D0551624969C92E
version: "1.1.20"
author: "zelik"
load_order_layer: L0
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "65157D09F042428A # GRS-Apparel"
  - "65D050C86106E5BC # Smokes"
  - "66577E328BF1401E # DarkGruMPPCamos-GRS"
related_memories: []
folder: "ZeliksCharacter_5D0551624969C92E"
gproj_file: "ZEL_Character.gproj"
gproj_id: "ZEL_Character"
---

# ZeliksCharacter

> **One-line role**: foundational character-system dependency by zelik — referenced by GRS-Apparel, Smokes, and DarkGruMPPCamos-GRS as a shared base layer.

## 1. Overview

Zelik's Character is published as a developer-facing dependency. Per the Workshop page: "to be used as a dependency, no altering of core files" — i.e., it provides primitives other apparel/cosmetic mods reference at runtime without re-publishing those core character pieces. Licensed APL-ND. **Note**: the addon ships under a non-standard gproj filename — `ZEL_Character.gproj` instead of `addon.gproj`, with `ID "ZEL_Character"` and `TITLE "Zelik's Character"` (verified in folder).

## 2. Functionality / Features

- Character system primitives consumed by GRS-Apparel (L7 loadout content), Smokes (L8 weapon/projectile pack), and DarkGruMPPCamos-GRS (L7 camo pack)
- License APL-ND — derivatives not permitted; this is why the mod is a hard-dep rather than being absorbed into dependers
- No standalone gameplay content

## 3. Configuration

_N/A_ — no `profile_new/profile/ZeliksCharacter/` directory exists.

## 4. Operator usage

Not directly consumed. Loads automatically when any of the three depper mods is installed.

## 5. Compatibility & load order

- **Load order layer**: **L0** per CLAUDE.md (L0 list explicitly names `ZeliksCharacter`).
- **Must load before**: GRS-Apparel (L7), Smokes (L8), DarkGruMPPCamos-GRS (L7).
- **Conflicts with**: none documented.
- **Non-standard gproj name** (`ZEL_Character.gproj`) — the engine resolves it because addon.gproj is not literally required to be named `addon.gproj` as long as the project file is at the addon folder root and is referenced via the manifest. This is unusual in this stack — most addons ship `addon.gproj`. If anyone ever tries to "regenerate addon.gproj" for this folder per the reconstruction template in memory `landmine-steam-dedicated-addon-gproj-missing.md`, **stop** — the file already exists under a different name and reconstruction would create a duplicate / wrong-checksum problem.

## 6. Performance impact

Negligible — pure dependency.

## 7. Known issues / landmines

- **APL-ND license + folder-presence dep chain risk**: if a future Steam re-download evicts this folder, GRS-Apparel + Smokes + DarkGruMPPCamos-GRS all fail to register. Mitigation: ZeliksCharacter is already declared in `serverConfig.json mods[]` per L0 list.
- **Non-standard gproj filename** (see §5) — do not let any automated gproj-reconstruction tooling treat this folder as missing addon.gproj.

## 8. Extending / modding

_N/A_ at operator level. Workbench: depper mods inherit/reference Zelik's character prefabs but cannot modify them per APL-ND.

## 9. Changelog / verified state

- **Installed version**: 1.1.20
- **Folder**: `ZeliksCharacter_5D0551624969C92E`
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/5D0551624969C92E)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/5D0551624969C92E/changelog)
- Author: zelik
