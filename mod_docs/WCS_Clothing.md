---
workshop_id: "6152CB0BD0684837"
workshop_url: https://reforger.armaplatform.com/workshop/6152CB0BD0684837
version: "6.0.21"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "6602C1EC7E5A4A87 # WCS_Clothing_Assets"
reverse_deps:
  - "615CC2D870A39838 # WCS_Arsenal"
related_memories: []
folder: "WCS_Clothing_6152CB0BD0684837"
---

# WCS_Clothing

> **One-line role**: tiny (2.48 MB) prefab/inventory-item definitions for WCS uniforms/vests/helmets — references the heavy textures shipped by [[WCS_Clothing_Assets]].

## 1. Overview

`WCS_Clothing` is the **prefab half** of the deliberate split with `WCS_Clothing_Assets`. It ships only the `InventoryItem` and wearable prefabs (uniforms, vests, helmets, headgear, etc.) plus localization strings, all referencing the 2 GB asset bundle for actual textures/meshes. This keeps version churn cheap — most updates are prefab edits, so players don't re-download 2 GB.

## 2. Functionality / Features

- WCS uniform / vest / helmet / headgear inventory-item prefabs (specific list not enumerated on Workshop)
- Localization strings (12+ languages; cs_cz, de_de, en_us, es_es, fr_fr, it_it, ja_jp, ko_kr, pl_pl, etc. per gproj)
- All wearables wire through the NATO/RU faction character prefabs in [[WCS_NATO]] / [[WCS_RU]]

## 3. Configuration

**Config files**: none in `$profile:/`.

_N/A_ — no tunable keys.

## 4. Operator usage

**In-game**: clothing appears in WCS_Arsenal under the apparel tabs of the US/USSR faction templates. Players equip via standard arsenal UI.

**Keybinds / admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content).
- **Must load before**: `WCS_Arsenal` (which deps it via gproj)
- **Must load after**: **[[WCS_Clothing_Assets]]** — per [[CLAUDE.md]] §"DAG fixes" item 1: *"WCS_Clothing_Assets MUST precede WCS_Clothing"*. Violating the order risks missing-texture cascades on every clothing item.
- **Conflicts with**: none known.
- **Synergies with**: `WCS_Armbands` (parallel wearable system on a dedicated armband slot — see [[WCS_Armbands]]).

## 6. Performance impact

Negligible. Tiny prefab footprint (2.48 MB). All real cost is in the Assets bundle.

## 7. Known issues / landmines

- **DAG ordering** (above) — re-iterate: `WCS_Clothing_Assets` MUST be before this in `mods[]` array. Verify after any modlist reorder.
- See `WCS_LoadoutEditor/audit/incidents/*.jsonl` for stale-clothing-prefab errors if WCS bumps a uniform GUID across versions (per [[CLAUDE.md]] §"audit/incidents/*.jsonl is the missing-prefab smoking gun").

## 8. Extending / modding

_N/A_ — content mod.

## 9. Changelog / verified state

- **Installed version**: 6.0.21
- **Folder**: `WCS_Clothing_6152CB0BD0684837`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/6152CB0BD0684837) — 83% rating, 1.56M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/6152CB0BD0684837/changelog)
- [[CLAUDE.md]] §"DAG fixes" item 1
- Companion: [[WCS_Clothing_Assets]]
