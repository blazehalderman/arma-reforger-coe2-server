---
workshop_id: "61C74A8B647617DA"
workshop_url: https://reforger.armaplatform.com/workshop/61C74A8B647617DA
version: "6.0.12"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "68F006D910E7546F # WCS_Weapon_Scripts"
reverse_deps:
  - "615806DC6C57AF02 # WCS_NATO"
  - "615818DA7C0343FD # WCS_RU"
  - "615CC2D870A39838 # WCS_Arsenal"
related_memories: []
folder: "WCS_Attachments_61C74A8B647617DA"
---

# WCS_Attachments

> **One-line role**: ships the rail/foregrip/suppressor/laser/light/bipod attachment prefabs that bind to WCS-rail-compatible weapons (and, via [[WCS_RHS_Weapons]] bridge, to RHS weapons).

## 1. Overview

`WCS_Attachments` is one of the **three pillars of the WCS weapons stack** (Attachments + Scopes + Sounds — all share `WCS_Weapon_Scripts` as their script-side core). It ships non-optic attachments: foregrips, vertical grips, angled grips, suppressors/cans, IR/visible lasers, weapon lights, bipods, and the underlying rail-slot definitions. WCS-pattern guns expose slots that pull from this catalog; RHS-pattern guns gain those slots only when [[WCS_RHS_Weapons]] is loaded as the bridge.

**Critical for RHS attachment fix** (see [[CLAUDE.md]] §"RHS attachment fix applied 2026-05-12"): the entire "RHS weapons spawn but attachments are useless" failure mode is rooted in the bridge mod **not being declared** in `serverConfig.json` — *not* this mod being broken. If RHS rifles show no attachment slots, the bug is in `WCS_RHS_Weapons` declaration, not here.

## 2. Functionality / Features

- Foregrips (vertical, angled, hand-stop variants)
- Suppressors (multiple calibres — 5.56, 7.62, 9mm, etc.)
- Lasers (IR + visible, varying intensity/range)
- Weapon lights (flashlights at various brightness levels)
- Bipods (folding, fixed)
- Rail definitions / slot interfaces consumed by WCS weapon prefabs
- Localization in 12+ languages (per gproj)

## 3. Configuration

**Config files**: none in `$profile:/`.

_N/A_ — no tunable keys.

## 4. Operator usage

**In-game**: attachments populate the rail-slot menus on WCS / RHS-bridged weapons in arsenal. Players right-click a weapon → "Attachments" → pick from available rails.

**Keybinds**: standard Arma Reforger attachment keys (default `L` = laser, `T` = light, etc. — game-level binds, not mod-specific).

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content) per `MASTER_OBJECTIVE.md`.
- **Must load before**: [[WCS_NATO]], [[WCS_RU]], [[WCS_Weapons]], [[WCS_Arsenal]] — all reverse-deps.
- **Must load after**: `WCS_Weapon_Scripts` (sole non-base dep).
- **Conflicts with**: any other attachment-system mod that registers competing rail slot interfaces — none in current stack.
- **Synergies with**: [[WCS_Scopes]] (optics half), [[WCS_RHS_Weapons]] (the canonical bridge — see [[CLAUDE.md]] §"Proxy Node Preservation": *"WCS_RHS_Weapons is the ONLY canonical bridge between WCS attachment slots and RHS weapons"*).

## 6. Performance impact

Negligible runtime; 445 MB on disk. Arsenal cache slice on boot.

## 7. Known issues / landmines

- **RHS attachment slots silently empty without the bridge** — re-stated for emphasis from [[CLAUDE.md]] §"RHS attachment fix applied 2026-05-12": the failure mode is misleading because RHS rifles spawn fine, just with no rails populated. The fix is declaring [[WCS_RHS_Weapons]] in `serverConfig.json` `mods[]`, not patching this mod.
- **No standalone attachment-system stacking** — per [[MASTER_OBJECTIVE.md]] "Proxy Node Preservation" rule: do not stack alternate attachment systems alongside this one.
- See `WCS_LoadoutEditor/audit/incidents/*.jsonl` for stale-attachment-prefab errors.

## 8. Extending / modding

_N/A_ — content mod.

## 9. Changelog / verified state

- **Installed version**: 6.0.12
- **Folder**: `WCS_Attachments_61C74A8B647617DA`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/61C74A8B647617DA) — 81% rating, 1.7M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/61C74A8B647617DA/changelog)
- [[CLAUDE.md]] §"RHS attachment fix applied 2026-05-12" — the bridge-declaration rule
- [[CLAUDE.md]] §"Proxy Node Preservation" — single-attachment-system rule
- Companion: [[WCS_Scopes]], [[WCS_RHS_Weapons]], [[WCS_Sounds]]
