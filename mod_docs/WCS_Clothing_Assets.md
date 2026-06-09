---
workshop_id: "6602C1EC7E5A4A87"
workshop_url: https://reforger.armaplatform.com/workshop/6602C1EC7E5A4A87
version: "6.0.6"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "6152CB0BD0684837 # WCS_Clothing"
  - "615CC2D870A39838 # WCS_Arsenal"
related_memories: []
folder: "WCS_Clothing_Assets_6602C1EC7E5A4A87"
---

# WCS_Clothing_Assets

> **One-line role**: heavyweight (~2 GB) asset bundle (textures/meshes/materials) for WCS clothing — pure asset library, no script logic; consumed by `WCS_Clothing`.

## 1. Overview

`WCS_Clothing_Assets` is the **asset half** of a deliberate two-mod split: this bundle ships the raw textures, meshes, and material configs for WCS-style uniforms/vests/helmets, while [[WCS_Clothing]] ships the lightweight prefab definitions that *reference* these assets. The split keeps the prefab mod small (2.48 MB) so updates to wearable inventory items don't force a 2 GB re-download.

**Critical ordering**: this mod must load **BEFORE** WCS_Clothing — per [[CLAUDE.md]] §"DAG fixes" item 1, this is an explicit DAG fix (the gproj of WCS_Clothing declares Assets as a dep, but historically the engine has had ordering bugs with content-only-asset chains; the ordering is enforced via `mods[]` array order as belt-and-suspenders).

## 2. Functionality / Features

- 1.99 GB of texture/mesh/material data for WCS clothing
- Provides the underlying `.xob`, `.emat`, texture resources referenced by `WCS_Clothing` prefabs
- No scripts, no prefabs of its own (pure asset library)

## 3. Configuration

**Config files**: none. Asset library only.

_N/A_ — no tunable keys.

## 4. Operator usage

**In-game**: invisible to operator — only relevant when the operator notices missing-texture pink/checker on WCS clothing items (which indicates this mod failed to load or was purged).

**Keybinds / admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content) per `MASTER_OBJECTIVE.md`.
- **Must load before**: **[[WCS_Clothing]]** — `MASTER_OBJECTIVE.md` Layer 3 row + [[CLAUDE.md]] §"DAG fixes" item 1: *"WCS_Clothing_Assets MUST precede WCS_Clothing"*. This is non-negotiable: violating the order risks engine reading prefab files (Clothing) before their asset deps (Assets) are registered, producing missing-texture cascades.
- **Must load after**: base game only (gproj has just `58D0FB3206B6F859`)
- **Conflicts with**: none known.
- **Synergies with**: `WCS_Clothing` (its sole declared consumer in the current stack).

## 6. Performance impact

Disk: ~2 GB. RAM: ~the same when assets paged in by clothed entities on screen. No per-tick CPU cost. The big-asset cost is *startup-once*; mid-game cost is small.

## 7. Known issues / landmines

- **DAG fix priority** (above) — if the operator ever reshuffles the `mods[]` array, verify Assets stays above Clothing.
- **Pak file lock hazard** (general WCS rule) — never `Remove-Item` this folder with server running, per [[CLAUDE.md]] §"Pak file lock + addon move/delete". Killing the server first + waiting 3-5 s for handle release is mandatory.
- **Steam re-download landmine** (general) — if folder is purged for any reason while declared in `mods[]`, Steam will re-pull 2 GB on next start; budget accordingly.

## 8. Extending / modding

_N/A_ — asset library; forks would need to also fork `WCS_Clothing` to reference the new assets.

## 9. Changelog / verified state

- **Installed version**: 6.0.6
- **Folder**: `WCS_Clothing_Assets_6602C1EC7E5A4A87`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/6602C1EC7E5A4A87) — 1.99 GB
- [Workshop changelog](https://reforger.armaplatform.com/workshop/6602C1EC7E5A4A87/changelog)
- [[CLAUDE.md]] §"DAG fixes" item 1 — the must-precede-WCS_Clothing rule
- [[MASTER_OBJECTIVE.md]] Layer 3 row
- Companion: [[WCS_Clothing]]
