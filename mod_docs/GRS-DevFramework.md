---
workshop_id: "65DACC64CE785B6C"
workshop_url: https://reforger.armaplatform.com/workshop/65DACC64CE785B6C
version: "1.0.26"
author: "gl1tch_ / Shadow_Haven_Studios"
load_order_layer: L0
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "657B064AE0E231DF # GRS-Patches"
  - "66577E328BF1401E # DarkGruMPPCamos-GRS"
related_memories: []
folder: "GRS-DevFramework_65DACC64CE785B6C"
---

# GRS-DevFramework

> **One-line role**: scripting library underpinning the GRS inventory + loadout systems (consumed by GRS-Patches, DarkGruMPPCamos-GRS, and transitively by GRS-Apparel).

## 1. Overview

GRS-DevFramework (gproj `ID GRSDevFramework`) by gl1tch_ and Shadow_Haven_Studios is the foundational scripting layer for the GRS apparel/loadout/inventory ecosystem. Per the Workshop description: "This framework contains important scripts that support the GRS inventory system and loadout systems." Development-only infrastructure — not consumed directly by players or operators.

## 2. Functionality / Features

- Shared scripts for the GRS inventory system
- Shared scripts for GRS loadout management
- Foundational code other GRS mods derive from (GRS-Patches, DarkGruMPPCamos-GRS, and transitively GRS-Apparel via GRS-Patches)

## 3. Configuration

_N/A_ — no `profile_new/profile/GRS-DevFramework/` directory exists.

## 4. Operator usage

Not directly consumed. Its value reaches operators through the GRS-Apparel + GRS-Patches + DarkGruMPPCamos-GRS chain (apparel/patch/camo content used by DarkGruFactions and other faction packs).

## 5. Compatibility & load order

- **Load order layer**: **L0** per CLAUDE.md (L0 list explicitly names `GRS-DevFramework`).
- **Must load before**: GRS-Patches, DarkGruMPPCamos-GRS, and transitively GRS-Apparel.
- **Related DAG fix**: CLAUDE.md "DAG fixes" #2 — *"GRS-Patches MUST precede GRS-Apparel (DAG fix 2026-05-13)"*. GRS-DevFramework feeds that chain at the head.
- **Conflicts with**: none documented.

## 6. Performance impact

Negligible — pure library.

## 7. Known issues / landmines

- **Indirectly named in the dep-chain warnings** in CLAUDE.md "Mod purge safety protocol" example list: GRS-Apparel is hard-depped by BaconLoadoutEditor's consumers, and GRS-Apparel itself transitively depends on GRS-DevFramework via GRS-Patches. Purging this folder will cascade-fail the GRS apparel stack. **Do not purge.**

## 8. Extending / modding

_N/A_ at operator level. Workbench: see GRS-Patches or DarkGruMPPCamos-GRS for usage patterns; no public API doc on Workshop page.

## 9. Changelog / verified state

- **Installed version**: 1.0.26
- **Folder**: `GRS-DevFramework_65DACC64CE785B6C`
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/65DACC64CE785B6C)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/65DACC64CE785B6C/changelog)
- Author: gl1tch_ / Shadow_Haven_Studios
