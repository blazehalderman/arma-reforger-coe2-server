---
workshop_id: "657B064AE0E231DF"
workshop_url: https://reforger.armaplatform.com/workshop/657B064AE0E231DF
version: "1.0.18"
author: "gl1tch_ (Grey Reign Systems)"
load_order_layer: L7
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "65DACC64CE785B6C # GRS-DevFramework"
reverse_deps:
  - "65157D09F042428A # GRS-Apparel"
related_memories: []
folder: "GRS-Patches_657B064AE0E231DF"
---

# GRS-Patches

> **One-line role**: ships the patch/insignia assets (models + textures + materials + prefabs) consumed exclusively by GRS-Apparel. Pure content overlay; must load before GRS-Apparel.

## 1. Overview

Companion content pack for `GRS-Apparel`. Ships visual assets — models, textures, materials, prefab configurations — for unit patches/insignia. Per the author: "Patches for my apparel mod. Only works with my mods!" The patches are surfaced through GRS-Apparel's loadout slots; they have no standalone effect.

## 2. Functionality / Features

- Patch/insignia visual assets (models, textures, materials, prefabs)
- Consumed exclusively by GRS-Apparel — no other mod in this stack references its content
- 122 MB asset payload

## 3. Configuration

**Server-side config files**: none in `profile_new/profile/`. Pure content pack.

## 4. Operator usage

- Players see GRS-Patches assets through GRS-Apparel's character customization / loadout slots (via BLE or the in-game arsenal).

## 5. Compatibility & load order

- **Load order layer**: **L7** (apparel/loadouts) per `MASTER_OBJECTIVE.md`.
- **Must load after**: `GRS-DevFramework` (`65DACC64CE785B6C`) — declared in gproj.
- **Must load before**: `GRS-Apparel`. **CLAUDE.md DAG fix (verbatim)**: "GRS-Patches MUST precede GRS-Apparel (DAG fix 2026-05-13)". The gproj does NOT enforce this ordering — it's a DAG fix added because GRS-Apparel's prefab references GRS-Patches assets, and load order is the symbol-override tiebreaker.
- **Conflicts with**: no known conflicts.
- **Synergies with**: `[[GRS-Apparel]]` exclusively.

## 6. Performance impact

Asset-load cost at scenario init only. No per-tick cost.

## 7. Known issues / landmines

- **Order-matters DAG fix** (above) is the only landmine. Loading GRS-Apparel before GRS-Patches would mean GRS-Apparel's prefabs resolve patch slots against a non-yet-registered asset table — symptoms would be missing patches on uniforms in arsenal preview.

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 1.0.18
- **Folder**: `GRS-Patches_657B064AE0E231DF`
- **Last clean boot**: continuously loaded since pre-2026-05-12

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/657B064AE0E231DF)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/657B064AE0E231DF/changelog)
- Downstream consumer: `[[GRS-Apparel]]`
- Required dep: `[[GRS-DevFramework]]`
- CLAUDE.md "Mod stack architecture (load order layers)" — DAG fix #2
