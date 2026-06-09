---
workshop_id: "663A654A6BB0AEA4"
workshop_url: https://reforger.armaplatform.com/workshop/663A654A6BB0AEA4
version: "1.0.16"
author: "Ashyl"
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "6632F94B46173164 # RayziUtils"
  - "5A7B79D8A910A4D1 # BetterWeaponImmersion (BWI 2.8)"
  - "6608FD6F58F3B90A # ADSSway-PIPDOF-TEST (transitive on disk, undeclared)"
  - "65735C5643CCC0A6 # ADSSway-Conf-LOW (transitive on disk, undeclared)"
  - "648D682E7038491E # ADSSway-Core"
  - "58D0FB3206B6F859 # base game"
  - "61ECB5EFAA346151 # TacticalAnimationOverhaulTEST (transitive on disk, undeclared)"
  - "595F2BF2F44836FB # RHS_Status_Quo"
reverse_deps: []
related_memories: []
folder: "BWI-ADSsway-RHS-TAOcompat_663A654A6BB0AEA4"
---

# BWI-ADSsway-RHS-TAOcompat

> **One-line role**: the apex bridge mod that wires Better Weapon Immersion 2.8, the ADSSway chain (Core + RHS + the two undeclared transitive deps), RayziUtils, RHS Status Quo, and the Tactical Animation Overhaul TEST build into one coherent weapon-handling stack — including TAO-aware blind-fire recoil.

## 1. Overview

This is the "everything-talks-to-everything" compat mod for the sway/recoil stack. It re-implements recoil curves across primary weapons (including RHS variants), adds TAO-compatible blind-fire recoil that varies by firing technique, and binds ADSsway behavior to BWI 2.8's recoil model. **All 8 of its gproj deps must register first** — three of which are *transitive* on disk only (not declared in `serverConfig.json mods[]`).

Workshop note: "all weapons recoils will be overhauled soon" — the version is still pre-2.0, expect ongoing balance shifts from the upstream author.

## 2. Functionality / Features

- Recoil implementation for main weapons and RHS-equipped firearms
- TAO-compatible blind fire recoil with technique-dependent variation
- ADSsway integration via ADSSway-Core
- Camera shake adjustments for explosion feedback
- Acts as the synthesis point of the entire sway/recoil chain

## 3. Configuration

**Server-side config files**: none. Tuning is baked into the mod's prefab overrides. Per-weapon recoil curves are not exposed as JSON tunables.

## 4. Operator usage

_N/A_ — no GM tools, no chat commands. Affects every player's handling of every covered weapon.

## 5. Compatibility & load order

- **Load order layer**: **L10** (per the BWI 2.8 author's "load last" instruction — this bridge tags along since it hard-deps BWI). Per `MASTER_OBJECTIVE.md`: "BWI 2.8 + bridge MOVED to L10".
- **Must load after** (per `addon.gproj` Dependencies):
  - `RayziUtils` (`6632F94B46173164`) — declared in `mods[]` at L0
  - `BetterWeaponImmersion` 2.8 (`5A7B79D8A910A4D1`) — declared in `mods[]` at L10
  - `ADSSway-Core` (`648D682E7038491E`) — declared in `mods[]` at L5
  - `RHS_Status_Quo` (`595F2BF2F44836FB`) — declared in `mods[]` at L1
  - **Three undeclared transitive deps** (folders only): `ADSSway-PIPDOF-TEST` (`6608FD6F58F3B90A`), `ADSSway-Conf-LOW` (`65735C5643CCC0A6`), `TacticalAnimationOverhaulTEST` (`61ECB5EFAA346151`). All three live in `profile_new/addons/` but are NOT in `serverConfig.json mods[]`. The engine resolves them via folder-presence + gproj chain.
- **Chain (verbatim from CLAUDE.md DAG fixes)**: "ADSSway-Core → ADSSway-RHS → BWI-ADSsway-RHS-TAOcompat (bridge chain)" — the bridge is the tail end.
- **Conflicts with**: none observed. The mod IS the conflict-resolution layer.

## 6. Performance impact

Negligible server-side. All work is per-client handling math.

## 7. Known issues / landmines

- **Three undeclared transitive deps on disk** (the surprise): `ADSSway-PIPDOF-TEST` + `ADSSway-Conf-LOW` + `TacticalAnimationOverhaulTEST` are all gproj-hard-required by this mod but **none are in `serverConfig.json mods[]`**. They are reachable today only because Steam happened to download them earlier (via Workshop dep resolution at the time of installing the bridge). **CLAUDE.md folder-presence landmine applies**: scripts execute regardless of declaration; if Steam ever evicts these folders between sessions, this bridge fails to register and downstream weapon handling breaks silently.
  - **Mitigation**: add the three GUIDs explicitly to `serverConfig.json mods[]` with `version: ""` so Steam keeps them refreshed. This has not been done yet on this server — flagged 2026-05-16.
- **Game-version drift**: Workshop declares 1.6.0.95; server is 1.6.0.119. No observed issues since 2026-05-12.
- **Per author**: "all weapons recoils will be overhauled soon" — expect Workshop updates to change feel without warning.

## 8. Extending / modding

_N/A_ — to extend coverage to a new weapon pack, author a sister compat mod or pressure the upstream maintainer.

## 9. Changelog / verified state

- **Installed version**: 1.0.16
- **Folder**: `BWI-ADSsway-RHS-TAOcompat_663A654A6BB0AEA4`
- **Game compat declared**: 1.6.0.95 (server is 1.6.0.119)
- **Last clean boot**: continuously loaded since 2026-05-12

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/663A654A6BB0AEA4)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/663A654A6BB0AEA4/changelog)
- Apex dep: `[[BetterWeaponImmersion]]`
- Chain: `[[AimingDeadzone]]` → `[[ADSSway-Core]]` → `[[ADSSway-RHS]]` → this
- CLAUDE.md "Mod stack architecture (load order layers)" — L10 placement
- CLAUDE.md "RHS attachment fix applied 2026-05-12" — first appeared in stack here
