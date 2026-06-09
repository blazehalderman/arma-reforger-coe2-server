---
workshop_id: "661D33952728B63D"
workshop_url: https://reforger.armaplatform.com/workshop/661D33952728B63D
version: "4.6.11"
author: "Ashyl"
load_order_layer: L10
status: active
last_verified: 2026-05-17
declared_in:
  - local
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps: []
related_memories: []
folder: "BHE_EXP_4.3Beta_661D33952728B63D"
---

# BHE_EXP (Better Hits Effects — Experimental 4.3 Beta)

> **One-line role**: physical-particles hit-effects system + reworked impact / fragmentation / vehicle-pen decals. The supported successor to Ashyl's abandoned `BetterHitsEffects`.

## 1. Overview

Active-maintenance branch of Ashyl's hit-effects line (Better's Mods family). Replaces vanilla impact particle systems with denser, more directional effects and adds a script-driven "physical particles" system that emits shrapnel/spalling fragments with real trajectories rather than static decal sprays.

Installed 2026-05-17 as the replacement for `[[RealismOverhaulEffects]]` (removed in the same iter — see §7).

## 2. Functionality / Features

- Physical hit particles (script-driven impact fragments).
- Reworked muzzle smoke / flash particle prefabs.
- Reworked explosion + grenade detonation VFX.
- Vehicle penetration / non-pen decals + spalling.
- Co-designed for compatibility with `[[Shrapnel]]` 2.1 (sibling mod by same author).

## 3. Configuration

_No config file._ Particle asset overrides + script behavior only.

## 4. Operator usage

Passive — visuals change automatically. No keybinds or admin commands.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio-visual overlay).
- **Must load after**: all WCS/RHS weapon content (their weapons fire the impacts BHE renders).
- **Synergies with**: `[[Shrapnel]]` 2.1 (Ashyl's co-designed sibling — physics fragmentation pairs with physical particles).
- **Conflicts with**: `[[RealismOverhaulEffects]]` (head-on collision on impact/explosion particle prefabs — silent half-injection per CLAUDE.md). Removed RO-Effects in the same iter to resolve.

## 6. Performance impact

Non-trivial: scripted physical-particles fire per-impact. On AI-dense COE2 firefights (100+ active AI under CRX `Formation_Scale=2.0`) expect measurable particle volume. Author's Shrapnel sibling explicitly optimized fragmentation lifetime/counts; BHE inherits that philosophy. Boot test 2026-05-17 boot 7-8 showed no FPS regression at idle.

## 7. Known issues / landmines

- **Beta status** — v4.6.11 cadence is fast (last update was 2026-05-17, the same day this doc was written). Version churn = CRC mismatch risk for clients on different revisions. Pin `version: ""` per CLAUDE.md to let engine accept any disk revision.
- **Surface conflict with `[[RealismOverhaulEffects]]`** — resolved by removing RO-Effects in this iter. Re-adding RO-Effects without removing BHE would re-introduce silent half-injection.

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 4.6.11
- **Folder**: `profile_new/addons/BHE_EXP_4.3Beta_661D33952728B63D`
- **Last clean boot**: 2026-05-17 boot 8 (GAME at 15:13:02, arsenal 6689)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/661D33952728B63D)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/661D33952728B63D/changelog)
- Bohemia forums — [Better's Mods thread](https://forums.bohemia.net/forums/topic/239232-betters-mods/)
- Related: `[[Shrapnel]]`, `[[BetterCasings]]` (sibling Ashyl mods), `[[RealismOverhaulEffects]]` (removed predecessor)
