---
workshop_id: "615806DC6C57AF02"
workshop_url: https://reforger.armaplatform.com/workshop/615806DC6C57AF02
version: "6.0.8"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "61C74A8B647617DA # WCS_Attachments"
  - "62A668F513428630 # WCS_Scopes"
  - "631C3C1AEE9C90BC # WCS_Sounds"
reverse_deps:
  - "615CC2D870A39838 # WCS_Arsenal"
  - "65CF7AE8574E06D2 # WCS_Weapons"
related_memories: []
folder: "WCS_NATO_615806DC6C57AF02"
---

# WCS_NATO

> **One-line role**: NATO faction + full NATO-side small-arms / gear arsenal for the WCS stack (one half of the WCS faction pair; pairs with WCS_RU).

## 1. Overview

WCS_NATO is the NATO **faction registration + content** half of the Worst Case Scenario weapon system. It declares an SCR_Faction entry for "NATO" and ships the NATO-side weapons, characters, and gear that the rest of the WCS pipeline binds to. **Note**: gproj declares only `WCS_Attachments`, `WCS_Scopes`, `WCS_Sounds`, `WCS_Weapon_Scripts` (transitively via Attachments/Scopes) — it does NOT hard-dep `WCS_Weapons`; instead, `WCS_Weapons` depends on `WCS_NATO + WCS_RU`. So this is a content-providing leaf, not a script framework.

The pair `WCS_NATO + WCS_RU` is the foundation of the WCS arsenal — without them, `WCS_Weapons` won't register, and `WCS_Arsenal` can't build templates. **However, see CLAUDE.md §"WCS arsenal only registers 2 loadout templates"**: WCS only ships templates for these two vanilla-aligned factions, which is why DarkGru/Arma2/PMC unit prefabs DO load (visible in GM F1 entity browser) but DO NOT surface in arsenal UI.

## 2. Functionality / Features

- Registers `SCR_Faction` for **NATO** (used by WCS_Arsenal as the basis for the US/NATO loadout template)
- Ships NATO-side weapon prefabs (M4 family, M249, M240, M1911, etc. — full list not enumerated on Workshop page)
- Ships NATO-side character prefabs (uniformed soldiers wired through `WCS_Clothing` assets)
- Ships NATO-side gear (mags, grenades, IFAKs, etc.)
- All assets binding into the WCS attachment system (rails, optics-rail compatible with WCS_Scopes/WCS_Attachments)

## 3. Configuration

**Config files**: none in `$profile:/`. WCS_NATO is content-only. All tuning happens via `WCS_LoadoutEditor` audit/loadout files (see [[WCS_LoadoutEditor]]) and `WCS_Arsenal` (no operator-visible JSON).

_N/A_ — no tunable keys.

## 4. Operator usage

**In-game**: NATO/US faction is selected via the scenario faction-picker (COE2 supports it as a player faction string-key). NATO weapons appear in any WCS_Arsenal box on a US-affiliated base or via GM-spawned arsenal. Character prefabs are spawnable via Game Master Entity Browser (F1 → search "NATO" or "US_Army_*").

**Keybinds**: none — content-only mod.

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content) per `MASTER_OBJECTIVE.md` Layer 3 row.
- **Must load before**: `WCS_Weapons` (which hard-deps NATO+RU per gproj), `WCS_Arsenal` (top of WCS DAG)
- **Must load after**: `WCS_Attachments`, `WCS_Scopes`, `WCS_Sounds` (its declared deps), `WCS_Weapon_Scripts` (transitive)
- **Conflicts with**: nothing in current stack. **Note**: WCS_NATO is the canonical "NATO faction" registration — any other mod that registers an "NATO" or "US" SCR_Faction with the same key risks override-ordering surprises (resolved by `mods[]` array order per [[CLAUDE.md]] "Order-matters evidence").
- **Synergies with**: `WCS_RHS_Weapons` bridge (gives RHS guns WCS-compatible attachment slots so they pull from this catalog), `sTsRHSVanillaArsenal` (adds vanilla→RHS bridging on the same NATO faction).

## 6. Performance impact

Negligible at runtime — content loads once at engine init, populates the arsenal cache (one slice of the `Cached 608 items` total). 758 MB on-disk download is the heaviest single cost. Per-tick: 0.

## 7. Known issues / landmines

- **NATO is one of only 2 factions with a SCR_LoadoutTemplate** (the other is RU). See [[CLAUDE.md]] §"WCS arsenal only registers 2 loadout templates" — modded faction packs (DarkGru, Arma2, PMC) don't get arsenal coverage without GM-spawned unfiltered arsenal or `Arsenal Box - Soft Adding Mods`.
- **No standalone version-pin landmine known** for WCS_NATO. Workshop ships current 6.0.8 only. Always declare with `version: ""` per [[CLAUDE.md]] §"Landmines discovered 2026-05-13" general rule.
- See `WCS_LoadoutEditor/audit/incidents/*.jsonl` (per [[CLAUDE.md]] "audit/incidents/*.jsonl is the missing-prefab smoking gun") for prefab-not-found errors when stale player loadout `.bin` files reference dead NATO prefab GUIDs from prior versions/PCM era.

## 8. Extending / modding

_N/A_ — this is content, not a framework. To add new NATO-side weapons/characters, fork via Workbench and inherit prefabs from this mod's catalog (license is non-commercial, no redistribution per Workshop page — operator-only forks ok, no public republish).

## 9. Changelog / verified state

- **Installed version**: 6.0.8 (on-disk; Workshop current as of 2026-05-05)
- **Folder**: `WCS_NATO_615806DC6C57AF02`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot
- **Last config change**: declared in `serverConfig.json` with `version: ""`

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/615806DC6C57AF02) — 82% rating, 1.77M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/615806DC6C57AF02/changelog)
- [[CLAUDE.md]] §"WCS arsenal only registers 2 loadout templates" — relevant arsenal limitation
- [[MASTER_OBJECTIVE.md]] Layer 3 row
- Companion mod: [[WCS_RU]] (the OPFOR half)
