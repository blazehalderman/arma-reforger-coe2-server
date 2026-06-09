---
workshop_id: "65CF7AE8574E06D2"
workshop_url: https://reforger.armaplatform.com/workshop/65CF7AE8574E06D2
version: "6.0.18"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "615806DC6C57AF02 # WCS_NATO"
  - "615818DA7C0343FD # WCS_RU"
reverse_deps:
  - "615CC2D870A39838 # WCS_Arsenal"
  - "65F929DF622BAD50 # WCS_RHS_Weapons"
  - "690EE89CA417ECD8 # sTsWCSVanillaArsenal"
related_memories: []
folder: "WCS_Weapons_65CF7AE8574E06D2"
---

# WCS_Weapons

> **One-line role**: WCS-style weapon prefabs (the "fully-WCS" rifle/MG/pistol catalog) — sits atop NATO+RU faction content and is the hard dep of the [[WCS_RHS_Weapons]] bridge.

## 1. Overview

`WCS_Weapons` is the **WCS-canonical weapon prefab catalog** — the rifles, MGs, pistols, etc. that are "fully WCS" (as opposed to RHS guns made WCS-compatible via the bridge). Its gproj is a thin 3-dep chain: `base + WCS_NATO + WCS_RU`. The Workshop page calls this *"weapon prefabs for WCS servers"* without enumeration.

**Bridge-fix anchor**: [[WCS_RHS_Weapons]] declares `WCS_Weapons` as a hard dep — this is why the operator's 2026-05-12 RHS attachment fix had to ALSO declare `WCS_Weapons` in `serverConfig.json`, per [[CLAUDE.md]] §"RHS attachment fix applied 2026-05-12" (line: *"WCS_Weapons `65CF7AE8574E06D2` — base WCS weapon prefabs (dep of bridge)"*).

## 2. Functionality / Features

- WCS-pattern rifle prefabs (likely M4 / AR-15 variants, AK-pattern variants — full list not enumerated on Workshop)
- WCS-pattern MG prefabs
- WCS-pattern pistol prefabs
- Hooks into WCS attachment rail system via `WCS_NATO + WCS_RU` (transitive: those depend on `WCS_Attachments`/`Scopes`/`Sounds` and `WCS_Weapon_Scripts`)

## 3. Configuration

**Config files**: none.

_N/A_ — no tunable keys.

## 4. Operator usage

**In-game**: WCS-pattern weapons appear in WCS_Arsenal under the US/USSR loadout templates. Spawnable via GM Entity Browser → search by weapon name.

**Keybinds / admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content).
- **Must load before**: [[WCS_Arsenal]], [[WCS_RHS_Weapons]], `sTsWCSVanillaArsenal` (reverse-deps).
- **Must load after**: [[WCS_NATO]], [[WCS_RU]] (hard deps per gproj).
- **Conflicts with**: nothing in current stack.
- **Synergies with**: [[WCS_RHS_Weapons]] (the bridge — without WCS_Weapons declared, RHS attachment fix fails).

## 6. Performance impact

Negligible runtime cost; arsenal cache slice on boot.

## 7. Known issues / landmines

- **Must be explicitly declared in `serverConfig.json`** even though [[WCS_Arsenal]] hard-deps it. Per [[CLAUDE.md]] §"RHS attachment fix applied 2026-05-12" the bridge fails when WCS_Weapons is on disk but not in `mods[]` (it was undeclared pre-2026-05-12). Empirically: declaring it explicitly resolved the broken-RHS-attachments symptom.
- **Stale-weapon-prefab refs** in player loadout `.bin` files surface in `WCS_LoadoutEditor/audit/incidents/*.jsonl` after WCS version bumps that change weapon GUIDs (per [[CLAUDE.md]] §"audit/incidents/*.jsonl is the missing-prefab smoking gun"). Concrete example: PCM-era SCAR-H `{24880E53C1ED467A}` and SCAR-H mag `{083483A1C5B8CA13}` no longer exist on disk; operator's Slot1 still references 20+ of these per dump.

## 8. Extending / modding

_N/A_ — content mod.

## 9. Changelog / verified state

- **Installed version**: 6.0.18
- **Folder**: `WCS_Weapons_65CF7AE8574E06D2`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot
- **Last config change**: 2026-05-12 — added to `serverConfig.json` as part of RHS attachment fix

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/65CF7AE8574E06D2) — 83% rating, 1.19M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/65CF7AE8574E06D2/changelog)
- [[CLAUDE.md]] §"RHS attachment fix applied 2026-05-12" — declare-in-serverConfig requirement
- [[CLAUDE.md]] §"audit/incidents/*.jsonl is the missing-prefab smoking gun"
- Companion: [[WCS_NATO]], [[WCS_RU]], [[WCS_RHS_Weapons]]
