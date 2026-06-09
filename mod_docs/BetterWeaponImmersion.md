---
workshop_id: "5A7B79D8A910A4D1"
workshop_url: https://reforger.armaplatform.com/workshop/5A7B79D8A910A4D1
version: "2.8.0"
author: "Ashyl"
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "663A654A6BB0AEA4 # BWI-ADSsway-RHS-TAOcompat"
related_memories: []
folder: "BetterWeaponImmersion2.8_5A7B79D8A910A4D1"
---

# BetterWeaponImmersion

> **One-line role**: weapon-handling overlay (recoil curves + dynamic sway + muzzle device effects + character inertia + camera shake) — the **load-LAST** overlay that the BWI-ADSsway-RHS-TAOcompat bridge wires into the ADSsway chain.

## 1. Overview

BWI 2.8 is Ashyl's overhaul of recoil and sway for both vanilla and RHS weapons (AK family, M16, M27, RPK, PKM, SVD, M21, etc.). It is **explicitly designed to be the last weapon-handling mod loaded** — the author's Workshop note is verbatim:

> "RHS Compability, for servers mods order - last, for SP - last (delete and install mod again to make it last or use ADSsway mods)"

This is why our stack places it at **L10 (GM/admin/QoL/audio-visual overlays + BWI 2.8 override layer)** instead of co-locating with the rest of the L5 sway chain. CLAUDE.md "Mod stack architecture" verbatim: "BWI 2.8 + bridge MOVED to L10 per author's 'load last' Workshop instruction (2026-05-14 research-validated)".

## 2. Functionality / Features

- Enhanced recoil system for rifles and machine guns
- Dynamic weapon sway mechanics (independent from ADSsway-Core; the BWI-ADSsway bridge harmonizes the two)
- Muzzle device effects influence recoil behavior
- Character inertia adjustments
- Camera shake during full-auto fire
- Coverage list (per Workshop): AK series, M16, M27, RPK, PKM, SVD, M21, "and more"

## 3. Configuration

**Server-side config files**: none in `profile_new/profile/`. All tuning is baked into the mod's prefab/config files; per-weapon recoil curves are not externally tweakable.

## 4. Operator usage

_N/A_ — affects every player's weapon handling. There are no GM tools, chat commands, or admin operations.

## 5. Compatibility & load order

- **Load order layer**: **L10** (NOT L5) per `MASTER_OBJECTIVE.md`. Author instruction overrides the natural L5 grouping with the rest of the sway chain.
- **Must load after**: everything in L5 (AimingDeadzone, ADSSway-Core, ADSSway-RHS) and everything in L8 (vehicle/weapon content packs). This is what "load last among weapon-handling overlays" means in practice.
- **Must load before**: scenario controllers at L11 (Kex Scenario Core, COE2).
- **Bridge mod**: `BWI-ADSsway-RHS-TAOcompat` (`663A654A6BB0AEA4`) hard-deps BWI 2.8 and harmonizes its sway/recoil with the ADSsway and TAO chains. The bridge sits **after** BWI in load order (it's a downstream consumer).
- **Conflicts with**: per the author note, version 2.8 supersedes the legacy `Better Weapon Immersion ADSs` mod (`65F76D9612BE5C94`) which targets 1.4.0.48 only. CLAUDE.md verbatim: "The legacy `Better Weapon Immersion ADSs` mod (`65F76D9612BE5C94`) targets only 1.4.0.48 and is NOT the right pick for 1.6 — keep the existing `BetterWeaponImmersion 2.8` (`5A7B79D8A910A4D1`) and use the BWI-ADSsway-RHS-TAOcompat bridge instead."
- **Synergies with**: `ADSSway-Core`, `ADSSway-RHS`, `TacticalAnimationOverhaulTEST` (all wired by the BWI-ADSsway-RHS-TAOcompat bridge mod).

## 6. Performance impact

Negligible server-side — per-client handling math. No AI tick cost, no RPC churn.

## 7. Known issues / landmines

- **Game-version drift**: Workshop page declares game compatibility `1.6.0.54`; the server runs `1.6.0.119`. Continuously loading clean since 2026-05-12 with no observed behavior regression. If a future engine patch breaks weapon-handling APIs, BWI 2.8 is a likely fragile spot — author Workshop URL is the canary.
- **Author "load LAST" instruction is mandatory** — placing BWI 2.8 earlier in the L-order will cause downstream mods (e.g. the L8 RHS-weapon content) to silently override its recoil curves. The 2026-05-14 research that re-validated the L10 placement is summarized in CLAUDE.md "Order-matters evidence (2026-05-14 research)".

## 8. Extending / modding

_N/A_ — the mod is a self-contained overlay. To add coverage for a new weapon pack, author would need to publish a new BWI-compat or ADSsway-compat patch.

## 9. Changelog / verified state

- **Installed version**: 2.8.0 (folder `BetterWeaponImmersion2.8_5A7B79D8A910A4D1`)
- **Game compat declared**: 1.6.0.54 (server is 1.6.0.119 — no observed issue)
- **Last clean boot**: continuously loaded since 2026-05-12

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/5A7B79D8A910A4D1)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/5A7B79D8A910A4D1/changelog)
- Bridge: `[[BWI-ADSsway-RHS-TAOcompat]]`
- Companion ADSsway chain: `[[AimingDeadzone]]` → `[[ADSSway-Core]]` → `[[ADSSway-RHS]]`
- CLAUDE.md: "Mod stack architecture (load order layers)" — L10 placement justification
- CLAUDE.md: "Order-matters evidence (2026-05-14 research)" — BI bug T165829, author's load-last note
- CLAUDE.md: "RHS attachment fix applied 2026-05-12" — legacy ADSs mod warning
