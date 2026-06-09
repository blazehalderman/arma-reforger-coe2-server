---
workshop_id: "64610AFB74AA9842"
workshop_url: https://reforger.armaplatform.com/workshop/64610AFB74AA9842
version: "6.0.59"
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
  - "615CC2D870A39838 # WCS_Arsenal"
related_memories: []
folder: "WCS_Core_64610AFB74AA9842"
---

# WCS_Core

> **One-line role**: the foundational framework mod for the entire WCS (Worst Case Scenario) family — provides shared assets, classes, and localization that every other WCS_* mod consumes.

## 1. Overview

`WCS_Core` is the Workshop's official tagline-verbatim: **"Internal core framework and essential assets required for all WCS server mods to function properly."** It is the root of the L1 WCS realism chain in this stack. The mod is small (~356 KB pak), script-light, and intentionally undocumented at the operator level — it exists so that the dozen-plus WCS sister mods (Arsenal, NATO, RU, Weapons, Attachments, Scopes, Sounds, Earplugs, LoadoutEditor, Armaments, Clothing, Clothing_Assets, Armbands, RHS_Weapons, AH-64D, Mi-24V, AH-1S, KA-52, AH-6M) can share a single class taxonomy + localization namespace. Per the `addon.gproj`, its only dep is the base game (`58D0FB3206B6F859`) and it ships 13-language stringtables under `wcs_core_localization.st`.

In our stack only `WCS_Arsenal` (`615CC2D870A39838`) declares WCS_Core as an `addon.gproj` hard dep, but the *transitive* reverse-dep set covers every WCS_* mod present — they all bind to WCS_Core's shared classes/strings indirectly.

## 2. Functionality / Features

- Provides shared C# script classes used by all WCS sister mods (SCR_Faction extensions, SCR_LoadoutTemplate scaffolding, internal data definitions).
- Ships 13-language localization (`cs_cz / de_de / en_us / es_es / fr_fr / it_it / ja_jp / ko_kr / pl_pl / pt_br / ru_ru / uk_ua / zh_cn`) — verified in `addon.gproj` `WidgetManagerSettings` → `StringTableDefinition` block.
- Carries shared resource paths (icons, fallback meshes) referenced by sister mods.
- Acts as the **WCS modded-class registration entry point** — its compile-time class bindings define the WCS_* namespace for the engine.

## 3. Configuration

**Config files**: none in `$profile:/`. Verified — no `profile_new/profile/WCS_Core/` directory exists.

**Tunable keys**: none operator-side. All config is per-prefab and baked at publish.

## 4. Operator usage

_N/A_ — invisible to operators. WCS_Core has no GM entities, no menus, no chat commands. Its presence is detected only via the WCS prefab family being functional.

## 5. Compatibility & load order

- **Load order layer**: **L1** (Realism cores) per `MASTER_OBJECTIVE.md`. Listed alongside RHS Status Quo + Content Packs and `WCS_Weapon_Scripts`.
- **Must load before**: every other WCS_* mod (transitively, via shared class graph). `WCS_Arsenal` declares it directly in its `addon.gproj`.
- **Must load after**: base game only.
- **Conflicts with**: none documented.
- **Synergies with**: every L3 WCS content mod (`WCS_NATO`, `WCS_RU`, `WCS_Weapons`, `WCS_Attachments`, `WCS_Scopes`, `WCS_Sounds`, `WCS_Armbands`, `WCS_Clothing*`, `WCS_LoadoutEditor`, `WCS_Armaments`, `WCS_Earplugs`); the L4 bridge `WCS_RHS_Weapons`; and L8 WCS vehicle mods (`WCS_AH-64D`, `WCS_Mi-24V`, etc.).

## 6. Performance impact

- Boot cost: trivial (~356 KB pak; 1.1M downloads on Workshop attests to robust well-tested code).
- Runtime cost: negligible — pure framework / data; no tick work.

## 7. Known issues / landmines

- **WCS arsenal template gap** (CLAUDE.md "WCS arsenal only registers 2 loadout templates"): the WCS framework's loadout template registration is strict — only US + USSR vanilla templates exist by default, so modded factions (DarkGru, Arma2Factions's CHDKZ/CDF/NAPA/TKM, RHS_USAF, RHS_AFRF) don't appear in the arsenal UI even when their prefabs load. This is a WCS-pipeline-wide constraint, surfaced by WCS_Arsenal but rooted in how the WCS_Core class taxonomy expects templates to be registered. Workaround: GM-spawned arsenal entity (unfiltered) or `Arsenal Box - Soft Adding Mods`.
- **WCS license**: non-commercial only, no redistribution, no modification without written permission — note when considering forks/extensions.
- **Steam re-download eviction**: like all on-disk mods, Steam can re-pull WCS_Core under the `version: ""` mod entry. Confirmed harmless on this stack — no breakage observed.

## 8. Extending / modding

_N/A operator-side_. As a closed framework under non-commercial license, extensions must be sister Workshop mods that consume WCS_Core's classes via gproj dep declaration — same pattern WCS_NATO, WCS_RU, etc. already use.

## 9. Changelog / verified state

- **Installed version**: 6.0.59 (per Workshop page; last modified 2026-05-05 per WebFetch)
- **Folder**: `WCS_Core_64610AFB74AA9842`
- **Last clean boot**: continuously loaded since 2026-05-12 RHS attachment fix; carried through COE2 pivot (2026-05-13) and current 103-mod baseline (2026-05-16).

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/64610AFB74AA9842) — 1,115,278 downloads, 82% rating
- [Workshop changelog](https://reforger.armaplatform.com/workshop/64610AFB74AA9842/changelog)
- License: WCS proprietary — non-commercial use in ARMA only; redistribution / modification require written author permission
- CLAUDE.md "WCS arsenal only registers 2 loadout templates" — template-gap landmine
- Related memories: `[[golden_state_2026_05_16_v5]]`
