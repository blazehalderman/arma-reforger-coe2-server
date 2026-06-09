---
workshop_id: "595F2BF2F44836FB"
workshop_url: https://reforger.armaplatform.com/workshop/595F2BF2F44836FB
version: "0.14.4899"
author: "Red Hammer Studios"
load_order_layer: L1
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
  - "1337C0DE5DABBEEF # RHS_Content_01"
  - "BADC0DEDABBEDA5E # RHS_Content_02"
reverse_deps:
  - "5F396C4F713595DB # Arma2Factions"
  - "615CC2D870A39838 # WCS_Arsenal"
  - "656B3A0955474CB7 # ADSSway-RHS"
  - "65F929DF622BAD50 # WCS_RHS_Weapons"
  - "663A654A6BB0AEA4 # BWI-ADSsway-RHS-TAOcompat"
  - "69075EC0BD287A6E # sTsRHSVanillaArsenal"
related_memories: []
folder: "RHS-StatusQuo_595F2BF2F44836FB"
---

# RHS_Status_Quo

> **One-line role**: the primary RHS content controller for Reforger 1.6 — registers characters, vehicles, weapons, factions (US + Russian Federation, ~2017 era) using assets from Content Pack 01/02. This is what makes "RHS" actually appear in-game.

## 1. Overview

`RHS: Status Quo` is the **canonical Red Hammer Studios mod for Arma Reforger 1.6.0.119** — per the Workshop description, it "focuses on contemporary sphere of things: 2000 - present with the main core around 2017 with US and RF taking center stage." The mod ships characters, vehicles, weapons, scenarios, terrains and the SCR_Faction registrations that surface them in-game. **It is the central hard-dep node of this server's realism chain**: 6 other declared mods reverse-depend on it. The `addon.gproj` declares 3 hard deps — base game plus the two RHS content packs — and ships the runtime localization stringtable (`rhs_localization.st`) in 3 languages (en_us, ru_ru, pl_pl).

The "Status Quo" name reflects RHS's choice to **redo** their long-running A3 content for Reforger rather than port one-to-one — these are Reforger-native prefabs, not A3 imports. The mod is under active development; recruiting notices on the Workshop page suggest "Phase 1" is the immediate target.

## 2. Functionality / Features

- **Characters**: US (M81 woodland, OEF-CP, OCP camo loadouts) + Russian Federation infantry. Specific unit list is not published by RHS but is enumerable via Game Master Entity Browser (F1).
- **Vehicles**: RHS-modeled US + RF ground vehicles and helicopters at varying coverage.
- **Weapons**: M4/M4A1 family, M16A4, M249, M240, M2010, AK-74M, AKM, RPK, PKM, RPG-7, etc. (the lineup that `WCS_RHS_Weapons` bridges into the WCS attachment ecosystem — see [[WCS_RHS_Weapons]]).
- **Factions**: registers `RHS_USAF` and `RHS_AFRF` as full `SCR_Faction` instances with their own item catalogs, group prefabs and faction colors.
- **Scenarios + terrains**: ships some but neither is the active scenario on this server (active = COE2 Eden via Kex Scenario Core).
- **Localization**: en_us / ru_ru / pl_pl stringtables (verified `addon.gproj` `StringTables` block).

## 3. Configuration

**Config files**: none in `$profile:/`. No `profile_new/profile/RHS_Status_Quo/` directory exists — all RHS configuration is baked into prefabs at Workshop publish time.

**Tunable keys**: none operator-side. Behavior is per-prefab and shipped read-only.

## 4. Operator usage

**In-game (Game Master)**:
1. Open GM (`M` then GM mode).
2. Entity Browser → filter Faction = `RHS_USAF` or `RHS_AFRF`.
3. Place characters / vehicles / weapons directly.
4. Spawn an arsenal entity (or use `WCS_LoadoutEditor`) to surface RHS weapons in the player loadout UI — note WCS_Arsenal only registers loadout templates for vanilla US + USSR factions (see CLAUDE.md "WCS arsenal only registers 2 loadout templates" landmine).

**Keybinds**: none specific.

**Admin commands**: none specific. Standard GM/admin.

## 5. Compatibility & load order

- **Load order layer**: **L1** (Realism cores) per `MASTER_OBJECTIVE.md` table.
- **Must load before**: `WCS_RHS_Weapons` (bridge mod, L4, gproj-verified hard dep on `595F2BF2F44836FB`), `WCS_Arsenal` (L3), `ADSSway-RHS` + `BWI-ADSsway-RHS-TAOcompat` (L10 weapon-handling overlays), `sTsRHSVanillaArsenal` (L3), `Arma2Factions` (L6).
- **Must load after**: `RHS_Content_01` + `RHS_Content_02` (hard deps per `addon.gproj` Dependencies block).
- **Conflicts with**: none documented in the current 103-mod stack.
- **Synergies with**:
  - `WCS_RHS_Weapons` — REQUIRED to make RHS attachment slots functional in WCS pipeline (see §7 landmine below).
  - `BetterWeaponImmersion 2.8` + `BWI-ADSsway-RHS-TAOcompat` bridge — handles RHS-specific sway/aiming math.
  - `sTsRHSVanillaArsenal` — merges RHS items into the vanilla arsenal UI.

## 6. Performance impact

- Boot cost: substantial — Status Quo + Pack 01 + Pack 02 together are the largest single-vendor asset load in the stack (~6.75 GB combined).
- Runtime cost: negligible at framework level; per-character-tick cost is whatever the prefab demands (same as vanilla characters). RHS uses standard Bohemia AI behavior trees on its character prefabs.

## 7. Known issues / landmines

- **The 2026-05-12 "RHS weapons spawn but attachments are useless" incident** (CLAUDE.md, "RHS attachment fix applied 2026-05-12"): RHS weapons rendered in-game with no scope/grip/suppressor render or equip. **Root cause**: the bridge mod `WCS_RHS_Weapons` was downloaded on disk but **not declared in `serverConfig.json mods[]`** — without it, RHS weapon prefabs do not advertise WCS attachment slots, so `WCS_Attachments` + `WCS_Scopes` have nothing to bind to on RHS guns. Fix was to declare `WCS_RHS_Weapons` + `WCS_Weapons` + supporting sway chain. See [[WCS_RHS_Weapons]] §7 for the full chronology.
- **WCS arsenal template gap**: WCS_Arsenal only registers 2 `SCR_LoadoutTemplate` for US + USSR vanilla. RHS_USAF / RHS_AFRF unit prefabs DO load (Entity Browser visible) but do NOT appear in the arsenal loadout UI because no template references them. PCM-era cross-faction merging is no longer reproducible on the WCS_Arsenal-strict pipeline. Workaround: GM-spawned arsenal entity (unfiltered) — CLAUDE.md "WCS arsenal only registers 2 loadout templates" landmine.
- **Cosmetic noise**: `'RHS_USAF' is not a valid SCR_Faction` / `'RHS_AFRF' is not a valid SCR_Faction` warnings can fire at scenario init from other mods that reference these factions before their registration completes. Cosmetic; gameplay unaffected per CLAUDE.md cosmetic-noise section.
- **License gotcha**: CC BY-NC-ND 4.0 — any derivative work is forbidden by license. Don't recommend forking or modifying RHS content; build companion bridge mods that consume its prefabs instead (the pattern used by `WCS_RHS_Weapons`).

## 8. Extending / modding

- **To add attachments to RHS weapons**: that's already done via `WCS_RHS_Weapons` — extending further requires building a separate bridge mod in Workbench. CC BY-NC-ND license forbids modifying RHS assets directly; the legal path is creating a new mod that adds your component layer on top of inherited prefabs (same Workbench inherit-and-override pattern documented in `[[DarcChopper]]` §8 Option B).
- **To add a new faction skin**: don't repaint RHS textures (ND clause). Build a separate faction pack that uses RHS character prefabs via SCR_Faction inheritance — pattern used by `Arma2Factions` (`5F396C4F713595DB`, reverse-dep) and the operator's Bridge Factions v1.0.3 mod (see `memory/bridge_mod_v103_architecture.md`).

## 9. Changelog / verified state

- **Installed version**: 0.14.4899 (per `ServerData.json` and Workshop page — last modified 20.04.2026)
- **Folder**: `RHS-StatusQuo_595F2BF2F44836FB`
- **Last clean boot**: continuously loaded since 2026-05-12 attachment fix. Verified active in both `serverConfig.json` (local) and `serverconfig-deployed.json` (deployed iter3, 117 mods).

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/595F2BF2F44836FB)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/595F2BF2F44836FB/changelog)
- [RHS website](https://www.rhsmods.org/) — upstream documentation
- License: CC BY-NC-ND 4.0 (no derivatives, no commercial, attribution required)
- CLAUDE.md "RHS attachment fix applied 2026-05-12" — root-cause + fix log
- CLAUDE.md "WCS arsenal only registers 2 loadout templates" — arsenal template gap
- Related memories: `[[bridge_mod_v103_architecture]]`, `[[golden_state_2026_05_16_v5]]`
