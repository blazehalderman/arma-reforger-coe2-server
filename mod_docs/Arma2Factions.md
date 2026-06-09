---
workshop_id: "5F396C4F713595DB"
workshop_url: https://reforger.armaplatform.com/workshop/5F396C4F713595DB
version: "0.0.65"
author: "Seskel"
load_order_layer: L6
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "595F2BF2F44836FB # RHS_Status_Quo"
  - "5D550926D43F1409 # TacticalFlava"
reverse_deps: []
related_memories: []
folder: "Arma2Factions_5F396C4F713595DB"
---

# Arma2Factions

> **One-line role**: faction pack ports of the canonical Arma 2 factions — CDF, ChDKZ, NAPA, Takistan Army, Takistan Guerrillas — with characters, weapons, vehicles, and props, plus localization for 13 languages.

## 1. Overview

Seskel's Arma II Factions adds the five Arma 2 factions back into Reforger as fully-fledged factions (characters, weapons, vehicles, props). On this server they're one of two L6 faction sources COE2's runtime string-key faction picker can select. Marked as Work-in-Progress at version `0.0.65` — operators should not pin a version.

## 2. Functionality / Features

**Factions added** (per Workshop):
- **CDF** — Chernarussian Defence Force
- **ChDKZ** — Chernarussian Movement of the Red Star
- **NAPA** — North Atlantic Peace Alliance
- **Takistan Army**
- **Takistan Guerrillas** (TKM — Takistani Militia in CLAUDE.md context)

Each faction ships:
- Character prefabs
- Faction-flavored weapons (pulled from RHS Status Quo + TacticalFlava deps where appropriate)
- Vehicles
- Props
- Localization for 13 languages (cs_cz, de_de, en_us, es_es, fr_fr, it_it, ja_jp, ko_kr, pl_pl, pt_br, ru_ru, uk_ua, zh_cn — confirmed via `Arma2Factions/addon.gproj` Configurations.WidgetManagerSettings.StringTables block)

## 3. Configuration

**Server-side config files**: none in `profile_new/profile/`. Faction selection is via COE2's in-game picker.

## 4. Operator usage

- **In-game (COE2)**: pick `CDF` / `ChDKZ` / `NAPA` / `TKM` / etc. from the COE2 enemy-faction string-key picker.
- **In-game (Game Master)**: Entity Browser → search "CDF" / "ChDKZ" / "NAPA" / "Takistan" to spawn the unit prefabs directly.

## 5. Compatibility & load order

- **Load order layer**: **L6** (faction packs) per `MASTER_OBJECTIVE.md`. Sibling in L6: `DarkGruFactions`. CLAUDE.md verbatim: "**L6** Faction packs (DarkGruFactions, Arma2Factions only — PMC chain and Misfits blocked 2026-05-14)".
- **Must load after** (per `addon.gproj`):
  - `RHS_Status_Quo` (`595F2BF2F44836FB`) — at L1
  - `TacticalFlava` (`5D550926D43F1409`) — declared in `mods[]` (see `[[TacticalFlava]]`)
- **Must load before**: L7 apparel and L11 scenario controllers.
- **Conflicts with**: no known conflicts. The "stale friendly-faction references" cosmetic-noise items in CLAUDE.md (e.g. `'NATO' / 'MPP' / 'RHS_USAF' / ... is not a valid SCR_Faction`) include references to factions Arma2Factions does NOT register — they originate from other faction-perception mods, not from Arma2Factions itself.

## 6. Performance impact

105 MB content pack — asset-load cost at scenario init only. No per-tick cost.

## 7. Known issues / landmines

- **WIP version** (`0.0.65`) — operator should NOT pin a `version` field in `serverConfig.json mods[]` for this mod; per CLAUDE.md 2026-05-13 landmine "ALWAYS use empty `version: ""` for new mods unless you have a specific frozen-revision reason". Currently uses empty `version` field.
- Workshop description is minimal ("Uhhh something something") — when a future operator needs to verify unit-prefab availability for a new faction key, they should boot the server and use the GM Entity Browser as the authoritative source.

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 0.0.65
- **Folder**: `Arma2Factions_5F396C4F713595DB`
- **Game compat declared**: 1.6.0.119 (matches server)
- **Workshop last updated**: 2026-02-20
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/5F396C4F713595DB)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/5F396C4F713595DB/changelog)
- License: Arma Public License (APL)
- Sibling L6 mod: `[[DarkGruFactions]]`
- Required dep: `[[RHS_Status_Quo]]`, `[[TacticalFlava]]`
- CLAUDE.md "Mod stack architecture (load order layers)" — L6 placement
- CLAUDE.md "Active scenario behavior — COE2 Eden" — runtime faction picker usage
- CLAUDE.md "Landmines discovered 2026-05-13" — `version: ""` policy
