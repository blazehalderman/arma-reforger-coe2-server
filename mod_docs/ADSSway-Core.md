---
workshop_id: "648D682E7038491E"
workshop_url: https://reforger.armaplatform.com/workshop/648D682E7038491E
version: "0.3.42"
author: "Rayzi_63"
load_order_layer: L5
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "6608FD6F58F3B90A # ADSSway-PIPDOF-TEST (transitive on disk, undeclared)"
  - "684608DD7C7E0DFB # AimingDeadzone"
reverse_deps:
  - "656B3A0955474CB7 # ADSSway-RHS"
  - "65735C5643CCC0A6 # ADSSway-Conf-LOW (transitive on disk, undeclared)"
  - "663A654A6BB0AEA4 # BWI-ADSsway-RHS-TAOcompat"
related_memories: []
folder: "ADSSway-Core_648D682E7038491E"
---

# ADSSway-Core

> **One-line role**: core engine of the ADSsway weapon-handling overlay — adds visual sway when aiming down sights and weight-y recoil response. Requires the AimingDeadzone primitive to register; needs per-weapon compat mods (e.g. ADSSway-RHS) to actually act on modded weapons.

## 1. Overview

ADSSway-Core ships the sway-while-ADS animation system and recoil curves that the Rayzi_63 immersion stack is built around. By itself it acts only on the base-game weapons set; modded weapons get the behavior only via dedicated compat patches (`ADSSway-RHS` ships RHS coverage on this server). Workshop note: "If you use modded weapons, you will need the corresponding compatibility mod, 'ADSSway - mod' Otherwise it wont work on these weapons."

## 2. Functionality / Features

- Visual sway when aiming down sights (breathing-style cone wander)
- Recoil curves that add perceived weight to shots and full-auto bursts
- Skill-based handling — players must control sway and manage recoil
- Provides the base classes that compat patches like ADSSway-RHS and the BWI bridge extend

## 3. Configuration

**Server-side config files**: none in `profile_new/profile/`. Tuning is client-side via in-game settings; per-weapon curves are baked into the mod's prefabs/configs.

**Companion config mod on disk** (transitive, undeclared in `mods[]`): `ADSSway-Conf-LOW` (`65735C5643CCC0A6`) is in `profile_new/addons/` and is gproj-required by `BWI-ADSsway-RHS-TAOcompat` — it ships a "LOW" preset profile. Folder presence is enough for the engine to consume it.

## 4. Operator usage

_N/A_ — there is no GM tool, chat command, or admin operation. The mod's effect is purely on weapon handling for every player.

## 5. Compatibility & load order

- **Load order layer**: **L5** (sway/aiming chain) per `MASTER_OBJECTIVE.md`.
- **Must load before**: `ADSSway-RHS` (gproj-declared dep). The bridge chain is **`ADSSway-Core → ADSSway-RHS → BWI-ADSsway-RHS-TAOcompat`** per CLAUDE.md.
- **Must load after**: `AimingDeadzone`, `RayziUtils` — both verbatim from CLAUDE.md DAG fixes:
  - "AimingDeadzone MUST precede ADSSway-Core (gproj-verified 2026-05-14)"
  - "RayziUtils MUST precede ADSSway-Core (gproj-verified 2026-05-14)"
- **Transitive deps undeclared in `mods[]`**: `ADSSway-PIPDOF-TEST` (`6608FD6F58F3B90A`) is gproj-required and present on disk only. CLAUDE.md folder-presence rule applies — engine resolves it from disk; if Steam ever evicts that folder, ADSSway-Core registration will fail.
- **Conflicts with**: BetterWeaponImmersion 2.8 wants to load LAST among weapon-handling overlays (see [[BetterWeaponImmersion]] §5). Tiebreaker is the L5 layer ordering — the chain registers first, BWI overrides later at L10.

## 6. Performance impact

Negligible server-side. Sway animation is a per-client effect; no AI-side tick cost.

## 7. Known issues / landmines

- **Two transitive deps live as undeclared addons** — `ADSSway-PIPDOF-TEST` and `ADSSway-Conf-LOW`. They're on disk and the engine compiles them via gproj resolution, BUT they are NOT in `serverConfig.json mods[]`. **CLAUDE.md folder-presence landmine applies**: their scripts execute regardless of declaration. If a Steam re-download evicts either folder between sessions, the registration chain breaks. Mitigation: add them to `mods[]` explicitly if either is ever observed missing from `addons/` post-purge.
- The mod's `0.3.x` version indicates pre-release / WIP — behavior may shift between Workshop updates without warning.

## 8. Extending / modding

If a future weapon pack ships without a matching `ADSSway - <mod>` patch, those weapons will use the engine's default handling (no ADSsway behavior). Per the author: "you will need the corresponding compatibility mod, 'ADSSway - mod'".

## 9. Changelog / verified state

- **Installed version**: 0.3.42
- **Folder**: `ADSSway-Core_648D682E7038491E`
- **Game compat**: 1.6.0.119
- **Last clean boot**: continuously loaded since 2026-05-12

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/648D682E7038491E)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/648D682E7038491E/changelog)
- License: Arma Public License No Derivatives (APL-ND)
- Required dep: `[[AimingDeadzone]]`
- Downstream consumers: `[[ADSSway-RHS]]`, `[[BWI-ADSsway-RHS-TAOcompat]]`
