---
workshop_id: "62A668F513428630"
workshop_url: https://reforger.armaplatform.com/workshop/62A668F513428630
version: "6.0.10"
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
  - "690EE89CA417ECD8 # sTsWCSVanillaArsenal"
related_memories: []
folder: "WCS_Scopes_62A668F513428630"
---

# WCS_Scopes

> **One-line role**: optic-rail content — red dots, holographics, LPVOs, magnified day scopes, night vision optics, thermals — bound to WCS-rail-compatible weapons and RHS weapons via the bridge.

## 1. Overview

`WCS_Scopes` is the **optics-only half** of the WCS attachment family (paired with [[WCS_Attachments]] for non-optic rails). Workshop description is intentionally vague — the mod ships a broad scope catalog (red dot, holographic, magnified day, NV-compatible, etc.) with weapon-rail bindings handled by `WCS_Weapon_Scripts` (sole non-base dep). 371 MB on disk.

Per [[CLAUDE.md]] §"RHS attachment fix applied 2026-05-12", WCS_Scopes alone does NOT give RHS weapons usable optic slots — that requires the [[WCS_RHS_Weapons]] bridge mod to advertise the slots on RHS prefabs.

## 2. Functionality / Features

- Red-dot sights (Aimpoint-pattern, holographic-pattern)
- Magnified day optics (LPVO, ACOG-style, 3.5x to 12x scopes)
- Night-vision-compatible optics (PVS-pattern)
- Thermal optics (if shipped — Workshop page doesn't enumerate)
- Optic rail-slot definitions consumed by WCS weapons
- Localization in 12+ languages

## 3. Configuration

**Config files**: none in `$profile:/`.

_N/A_ — no tunable keys.

## 4. Operator usage

**In-game**: scopes appear in the "Optic" rail slot of any WCS or RHS-bridged weapon. Standard arsenal UI for selection. Zero operator keybinds — Arma Reforger's vanilla optic-zoom keys (default `Page Up` / `Page Down` on variable optics, `V` to toggle PIP) handle in-mission use.

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content).
- **Must load before**: [[WCS_NATO]], [[WCS_RU]], [[WCS_Weapons]], [[WCS_Arsenal]], `sTsWCSVanillaArsenal` (all reverse-deps).
- **Must load after**: `WCS_Weapon_Scripts` (sole non-base dep).
- **Conflicts with**: none in current stack. Be wary of any mod that registers competing optic rail slots.
- **Synergies with**: [[WCS_Attachments]] (paired), [[WCS_RHS_Weapons]] (RHS bridge — empties slots without it).

## 6. Performance impact

Negligible runtime. 371 MB on disk. Optics-rendering cost is per-frame when ADS-ing through one, but that's vanilla engine, not mod-specific.

## 7. Known issues / landmines

- **RHS optics empty without bridge** — same root-cause as [[WCS_Attachments]] §7: declare [[WCS_RHS_Weapons]] in `serverConfig.json` per [[CLAUDE.md]] §"RHS attachment fix applied 2026-05-12".
- **PIP rendering cost** on scopes with picture-in-picture (variable LPVOs) can be expensive on low-end clients — engine-level, not mod-fixable.
- Stale-scope-prefab errors will surface in `WCS_LoadoutEditor/audit/incidents/*.jsonl` if WCS bumps a scope GUID across versions.

## 8. Extending / modding

_N/A_ — content mod.

## 9. Changelog / verified state

- **Installed version**: 6.0.10
- **Folder**: `WCS_Scopes_62A668F513428630`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/62A668F513428630) — 76% rating, 1.68M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/62A668F513428630/changelog)
- [[CLAUDE.md]] §"RHS attachment fix applied 2026-05-12"
- Companion: [[WCS_Attachments]], [[WCS_RHS_Weapons]]
