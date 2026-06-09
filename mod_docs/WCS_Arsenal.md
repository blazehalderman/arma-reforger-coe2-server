---
workshop_id: "615CC2D870A39838"
workshop_url: https://reforger.armaplatform.com/workshop/615CC2D870A39838
version: "6.0.39"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "64610AFB74AA9842 # WCS_Core"
  - "1337C0DE5DABBEEF # RHS_Content_01"
  - "BADC0DEDABBEDA5E # RHS_Content_02"
  - "595F2BF2F44836FB # RHS_Status_Quo"
  - "6602C1EC7E5A4A87 # WCS_Clothing_Assets"
  - "6152CB0BD0684837 # WCS_Clothing"
  - "61E42AE6714A3CC2 # WCS_Armbands"
  - "61C74A8B647617DA # WCS_Attachments"
  - "62A668F513428630 # WCS_Scopes"
  - "631C3C1AEE9C90BC # WCS_Sounds"
  - "615806DC6C57AF02 # WCS_NATO"
  - "615818DA7C0343FD # WCS_RU"
  - "65CF7AE8574E06D2 # WCS_Weapons"
  - "65F929DF622BAD50 # WCS_RHS_Weapons"
  - "61D57616CAFBB23D # WCS_LoadoutEditor"
  - "629B2BA37EFFD577 # WCS_Armaments"
reverse_deps: []
related_memories: []
folder: "WCS_Arsenal_615CC2D870A39838"
---

# WCS_Arsenal

> **One-line role**: WCS arsenal catalog assembler — registers the `SCR_LoadoutTemplate` entries for US + USSR (two templates only) and builds the inventory/vehicle catalogs consumed by arsenal boxes and the loadout editor. Top-of-stack convergence point for the entire WCS DAG.

## 1. Overview

`WCS_Arsenal` is the **17-hard-dep convergence point** of the WCS stack — its gproj declares almost every other WCS mod plus the RHS Status Quo trio as required. This is the mod that takes "all of WCS+RHS" and turns it into the actual arsenal-box / loadout-editor UI content.

**THE central WCS-stack landmine** lives here, per [[CLAUDE.md]] §"WCS arsenal only registers 2 loadout templates (US + USSR vanilla) for 4 factions on the map": even though faction packs like DarkGru / Arma2 / PMC ship character prefabs that DO load (visible via Game Master F1 entity browser), they DO NOT surface in arsenal UI because **WCS_Arsenal only registers `SCR_LoadoutTemplate` for US and USSR vanilla factions** — there's no template for the modded factions. PCM-era cross-faction merging is no longer reproducible on the WCS_Arsenal-strict pipeline. Workarounds: GM-spawned arsenal entity (unfiltered) OR `Arsenal Box - Soft Adding Mods` (`66DED7D8E3BF7E8D`) for partial coverage.

## 2. Functionality / Features

- Registers `SCR_LoadoutTemplate` for **US (NATO)** and **USSR (RU)** factions — that's it; 2 total templates regardless of modded faction count on map
- Builds the `EntityCatalog/InventoryItems_*` catalogs from all dependent WCS content (weapons, attachments, scopes, clothing, armbands, armaments, plus RHS via the bridge)
- Wires arsenal boxes to those catalogs (US-affiliated bases get the US catalog; USSR-affiliated bases get USSR)
- Provides the runtime that `WCS_LoadoutEditor` writes loadouts against
- 3.37 MB on disk — the heavy content is all in deps, this is the orchestrator

## 3. Configuration

**Config files**: none in `$profile:/`. Per-player loadouts live in [[WCS_LoadoutEditor]]'s storage; per-faction templates are baked into this mod's prefabs.

_N/A_ — no operator-tunable keys.

## 4. Operator usage

**In-game**:
- Arsenal boxes on US/USSR bases auto-populate with this mod's templates
- GM Entity Browser → spawn `ArsenalEntity` for an unfiltered full-catalog arsenal (per the workaround above for showing modded-faction gear)
- Players use [[WCS_LoadoutEditor]] to save personal slots against these templates

**Admin commands**: none specific to this mod.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content) — must be the **LAST WCS-content mod** in `mods[]` since its gproj declares 17 hard deps spanning the entire L3 cluster.
- **Must load before**: nothing in current stack (no reverse-deps).
- **Must load after**: all 17 listed deps in frontmatter. The trio `RHS_Content_01 + RHS_Content_02 + RHS_Status_Quo` are L1 (realism cores), so they're automatically before L3 — but the ordering rule still applies inside the resolver.
- **Conflicts with**: any mod that tries to register a competing US/USSR `SCR_LoadoutTemplate` (override-order dependent — see [[MASTER_OBJECTIVE.md]] BI feedback bug T165829 about mods[] order being partly authoritative for symbol overrides).
- **Synergies with**: `Arsenal Box - Soft Adding Mods` (`66DED7D8E3BF7E8D`) and any GM-spawned arsenal — both offer partial coverage of the modded-faction template gap.

## 6. Performance impact

Negligible at runtime. Boot cost: builds the arsenal cache (`Cached 608 items` per stability-check threshold in [[CLAUDE.md]] §"Standing snapshot/cleanup agent" — 608 is the magic number that signals a healthy WCS_Arsenal cache load).

## 7. Known issues / landmines

- **2-template hard cap** (above, §1) — fundamental architectural limit; mod authors fork required to extend. Workaround documented in [[CLAUDE.md]] §"WCS arsenal only registers 2 loadout templates".
- **`Cached 608 items` is the health signal** — any other count means arsenal cache failed to build correctly. See [[CLAUDE.md]] §"Cosmetic noise" → 608-item count was the resolution of the 94-item undercache regression. The standing-monitor stack alerts on deviation from 608.
- **17 hard deps means high purge sensitivity** — if any single WCS dep is purged, this mod fails to register and the arsenal is gone. Always run the [[CLAUDE.md]] §"Mod purge safety protocol" dep audit before touching anything in the L3 cluster.
- **`Cached 94 items` (historical, fixed)** — was the symptom of an arsenal undercache that fired thousands of `RpcError: Calling a RPC from an unregistered item! itemType='script::Game::SCR_ArsenalComponent'` per session. Now resolved at 608; residual RpcError rate is cosmetic per [[CLAUDE.md]] §"Cosmetic noise".

## 8. Extending / modding

To add a third template (e.g. for FIA or a modded faction): fork this mod in Workbench, add a new `SCR_LoadoutTemplate` configured for the target faction, build its `EntityCatalog/InventoryItems_<FactionKey>.conf` listing every weapon/clothing/attachment prefab to include. This is non-trivial (~2-4 h per faction) and the operator should use `Arsenal Box - Soft Adding Mods` for quick partial coverage instead.

## 9. Changelog / verified state

- **Installed version**: 6.0.39 (Workshop current)
- **Folder**: `WCS_Arsenal_615CC2D870A39838`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot
- **Arsenal cache**: `Cached 608 items` (golden-state health signal)

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/615CC2D870A39838) — 84% rating, 1.06M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/615CC2D870A39838/changelog)
- [[CLAUDE.md]] §"WCS arsenal only registers 2 loadout templates" — the central limit
- [[CLAUDE.md]] §"Standing snapshot/cleanup agent" — the 608-item cache health signal
- [[CLAUDE.md]] §"Cosmetic noise" — RpcError history
- [[CLAUDE.md]] §"Mod purge safety protocol" — required before any L3 purge
- Companion: all of L3 (this is the convergence point), plus L1 RHS Status Quo trio
