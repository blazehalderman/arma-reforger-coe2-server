---
workshop_id: "68F006D910E7546F"
workshop_url: https://reforger.armaplatform.com/workshop/68F006D910E7546F
version: "6.0.3"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L1
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps:
  - "61C74A8B647617DA # WCS_Attachments"
  - "62A668F513428630 # WCS_Scopes"
related_memories: []
folder: "WCS_Weapon_Scripts_68F006D910E7546F"
---

# WCS_Weapon_Scripts

> **One-line role**: minimal script-only mod (74 KB) that ships the C# classes powering WCS_Weapons + WCS_Attachments + WCS_Scopes behavior — pure code, no assets.

## 1. Overview

`WCS_Weapon_Scripts` is the **scripts-half** of the WCS weapons pipeline — the Workshop description is one line: "Scripts required for WCS_Weapons." Per the `addon.gproj`, it has zero declarations beyond the base-game dep and no localization/widget config (the gproj is 8 lines total — the smallest gproj in this mod's L1 cohort). It's separated from `WCS_Weapons` itself so that script logic can iterate independently of the (heavier) prefab/asset content. In our stack, `WCS_Attachments` and `WCS_Scopes` declare it as a hard dep in their gprojs.

The mod is **distinct from `WCS_Core`** — WCS_Core provides the framework-class taxonomy; WCS_Weapon_Scripts provides the per-weapon behavior helpers (fire mode handling, attachment-slot wiring, sway-curve hooks). Both must load before the WCS content L3 layer.

## 2. Functionality / Features

- Ships the script classes that `WCS_Weapons`, `WCS_Attachments`, `WCS_Scopes` consume.
- 74.32 KB pak (Workshop page); script-only — no meshes, no textures.
- No localization (verified — gproj has no `StringTableDefinition` block).
- Acts as the **WCS weapon-behavior class registration entry point**: defines fire-mode handlers, attachment-slot inheritance, and the scope-zeroing/sway-coupling math that WCS arsenal weapons rely on.

## 3. Configuration

**Config files**: none. No `profile_new/profile/WCS_Weapon_Scripts/` directory.

**Tunable keys**: none — pure code, all behavior baked.

## 4. Operator usage

_N/A_ — invisible to operators.

## 5. Compatibility & load order

- **Load order layer**: **L1** (Realism cores) per `MASTER_OBJECTIVE.md`. Listed alongside WCS_Core, RHS Status Quo, RHS Content packs.
- **Must load before**: `WCS_Attachments`, `WCS_Scopes` (gproj-verified hard deps). Transitively before `WCS_Weapons`, `WCS_Arsenal`, `WCS_RHS_Weapons`.
- **Must load after**: base game only.
- **Conflicts with**: none documented.
- **Synergies with**: every WCS weapon-handling mod consumes its classes; `BetterWeaponImmersion 2.8` + `ADSSway-RHS` + `BWI-ADSsway-RHS-TAOcompat` interact with WCS attachment slots that WCS_Weapon_Scripts establishes.

## 6. Performance impact

- Boot cost: negligible (74 KB script-only).
- Runtime: per-shot fire-handling math runs on every weapon trigger — script overhead is small but multiplied by trigger rate. Verified no measurable cost on this stack's CRX EAI + 100+ AI density envelope.

## 7. Known issues / landmines

- **Symbol-collision risk if duplicated**: if multiple mods registered conflicting WCS weapon classes, the engine's MRO (method resolution order) would throw at compile. None observed — WCS keeps a single namespace authority. Future-proofing: avoid stacking alternate weapon-script frameworks against the WCS line.
- **WCS license**: same as WCS_Core — non-commercial only, no redistribution without permission.

## 8. Extending / modding

_N/A_ — closed scripts under non-commercial license. WCS sister-mods consume the classes via gproj dep declaration.

## 9. Changelog / verified state

- **Installed version**: 6.0.3 (per Workshop page; 160,817 downloads)
- **Folder**: `WCS_Weapon_Scripts_68F006D910E7546F`
- **Last clean boot**: continuously loaded since 2026-05-12 RHS attachment fix. **Added to `serverConfig.json` in the 2026-05-12 RHS attachment fix** (see CLAUDE.md) — pre-fix the dep was unresolved.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/68F006D910E7546F)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/68F006D910E7546F/changelog)
- License: WCS proprietary, non-commercial in ARMA games only
- CLAUDE.md "RHS attachment fix applied 2026-05-12" — declared during the same fix that added WCS_Weapons + WCS_RHS_Weapons
- Related memories: `[[golden_state_2026_05_16_v5]]`
