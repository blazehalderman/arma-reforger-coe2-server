---
workshop_id: "5D550926D43F1409"
workshop_url: https://reforger.armaplatform.com/workshop/5D550926D43F1409
version: "1.3.15"
author: ""
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps: []
reverse_deps:
  - "5F396C4F713595DB # Arma2Factions"
related_memories: []
folder: "TacticalFlava_5D550926D43F1409"
---

# TacticalFlava

> **One-line role**: shared cosmetic / equipment asset library (helmets, vests, patches, attachments) consumed by other faction packs.

## 1. Overview

Asset library mod — provides a curated pool of headgear, vests, plate carriers, patches, scope/attachment cosmetic variants for other mods to consume. `[[Arma2Factions]]` hard-deps it (declared in gproj reverse-dep).

## 2. Functionality / Features

- Shared cosmetic asset pool.
- Other mods bind via gproj dep.

## 3. Configuration

_No config file._

## 4. Operator usage

Passive — assets surface via dependent mods' loadout entries.

## 5. Compatibility & load order

- **Load order layer**: **L10** (content overlay). Could arguably sit in L0 (utility framework) since it's a dep — verify against MASTER_OBJECTIVE.md.
- **Reverse-depped**: `[[Arma2Factions]]` — must load before that mod.
- **No known conflicts**.

## 6. Performance impact

Asset memory only.

## 7. Known issues / landmines

None known.

## 8. Extending / modding

_N/A_ for direct use — it's a passive asset library.

## 9. Changelog / verified state

- **Installed version**: 1.3.15
- **Last clean boot**: 2026-05-16

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/5D550926D43F1409)
- Reverse-depper: `[[Arma2Factions]]`
