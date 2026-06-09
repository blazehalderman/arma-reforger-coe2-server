---
workshop_id: "BADC0DEDABBEDA5E"
workshop_url: https://reforger.armaplatform.com/workshop/BADC0DEDABBEDA5E
version: "0.14.4899"
author: "Red Hammer Studios"
load_order_layer: L1
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps:
  - "595F2BF2F44836FB # RHS_Status_Quo"
  - "615CC2D870A39838 # WCS_Arsenal"
  - "656B3A0955474CB7 # ADSSway-RHS"
  - "69075EC0BD287A6E # sTsRHSVanillaArsenal"
related_memories: []
folder: "RHS-ContentPack02_BADC0DEDABBEDA5E"
---

# RHS_Content_02

> **One-line role**: smaller (880 MB) companion asset pack to RHS Content 01 — additional meshes, textures, audio for RHS: Status Quo. Pure data, no scripts.

## 1. Overview

`RHS - Status Quo - Content Pack 02` is the **second of two split asset packs** that `RHS_Status_Quo` references as hard deps. Its Workshop blurb is literally "Content pack 02" — per the `addon.gproj`, it carries only the base-game dep (`58D0FB3206B6F859`) and exposes no scripts. It exists as a separate Workshop entry mainly so RHS can ship rolling additive content updates without re-uploading the full 5.87 GB of Pack 01. Loading order **must be after the base game and before `RHS_Status_Quo`** per gproj.

## 2. Functionality / Features

- ~880 MB of supplemental RHS art assets (per Workshop page).
- No scripts, no behavior overrides — exposed indirectly through `RHS_Status_Quo` prefabs.
- Updated more frequently than Pack 01 (current rev `0.14.4899` vs Pack 01's `0.14.4886`).
- Same CC BY-NC-ND 4.0 license + conflict-depiction restrictions as Pack 01.

## 3. Configuration

**Config files**: none. No `profile_new/profile/RHS_Content_02/` directory.

**Tunable keys**: none.

## 4. Operator usage

_N/A_ — operators don't interact with this pack directly. Assets surface via `RHS_Status_Quo` in Game Master Entity Browser.

## 5. Compatibility & load order

- **Load order layer**: **L1** (Realism cores) per `MASTER_OBJECTIVE.md`.
- **Must load before**: `RHS_Status_Quo` (hard dep per `RHS-StatusQuo/addon.gproj` line 6: `"BADC0DEDABBEDA5E"`).
- **Must load after**: nothing — only the base game.
- **Conflicts with**: no known conflicts.
- **Synergies with**: same as Pack 01 — bridge via `WCS_RHS_Weapons`, arsenal merge via `sTsRHSVanillaArsenal`.

## 6. Performance impact

Boot-time-only; once paks are mapped no runtime cost. Smaller hit than Pack 01.

## 7. Known issues / landmines

- Same pak-file-lock landmine as all RHS folders — see CLAUDE.md "Pak file lock + addon move/delete".
- **Folder MUST be present even when nothing references it visibly** — `RHS_Status_Quo.addon.gproj` declares it as a hard dep, so removing this folder breaks the entire Status Quo chain → cascade-fail boot. Per CLAUDE.md mod-purge protocol: **always run the dep audit before any delete**.

## 8. Extending / modding

_N/A_ — closed asset library; you extend `RHS_Status_Quo`, not the packs.

## 9. Changelog / verified state

- **Installed version**: 0.14.4899 (per Workshop page, last modified 20.04.2026)
- **Folder**: `RHS-ContentPack02_BADC0DEDABBEDA5E`
- **Last clean boot**: continuously loaded since 2026-05-12 RHS attachment fix.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/BADC0DEDABBEDA5E) — 1,421,690 downloads; 92% rating
- [Workshop changelog](https://reforger.armaplatform.com/workshop/BADC0DEDABBEDA5E/changelog)
- RHS upstream: <https://www.rhsmods.org/>
- **Trivia — the meme GUID**: `BADC0DEDABBEDA5E` ("BAD CODE DABBED A5E"). Sibling to Pack 01's `1337C0DE5DABBEEF`. Both meme GUIDs were honored by Bohemia's Workshop API.
- Related memories: `[[landmine_steam_dedicated_addon_gproj_missing]]`
