---
workshop_id: "59BA048FA618471A"
workshop_url: https://reforger.armaplatform.com/workshop/59BA048FA618471A
version: "2.1.3"
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
folder: "Shrapnel2.1_59BA048FA618471A"
---

# Shrapnel 2.1

> **One-line role**: spawns real physics-driven shrapnel projectiles from explosive detonations (grenades, RPGs, mines) — adds true lethal-radius behavior instead of decorative-only particle puffs.

## 1. Overview

Ashyl's physics-fragmentation mod. When an explosive weapon detonates, the mod spawns physics entities (real projectiles with collision + damage) that travel along realistic arcs and can wound nearby characters. Fills a capability gap in the existing stack: `[[RealismOverhaulEffects]]` (now removed) and `[[BHE_EXP]]` handle visual particles, but neither produces actual damaging physics fragments.

Installed 2026-05-17. Active maintenance (95% rating, 12k+ subscribers, 1.6.0.119 native).

## 2. Functionality / Features

- Physics fragments spawned per detonation (grenades, RPG warheads, demo charges, mines).
- Lethal radius determined by fragment count + travel distance, not just blast radius.
- RHS compatibility per author description.
- v2.1 remake explicitly optimized fragment lifetime + count for 1.6.

## 3. Configuration

_No config file._ Detonation events trigger automatic fragment spawn.

## 4. Operator usage

Passive — fragments spawn automatically on explosive detonations. Operator can test via GM by spawning RPGs/grenades.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio-visual / physics overlay).
- **Must load after**: explosive content mods (the weapons whose detonations trigger fragments).
- **Synergies with**: `[[BHE_EXP]]` (Ashyl co-designed pair — BHE handles visual particles, Shrapnel handles physics fragments).
- **No known conflicts**: additive, not prefab-overwrite. Doesn't compete for explosion particle slots.

## 6. Performance impact

Per-tick physics on each spawned fragment. On AI-dense COE2 firefights with frequent grenade/RPG use, monitor `error.log` for `Agent requires automatic orientation` storm (the IPCHigherAISkill 2026-05-13 incident pattern, but caused by entity-spawn pressure rather than perception fault). Author's v1.6 remake optimization should keep this in check; no regression observed on 2026-05-17 boot 8.

## 7. Known issues / landmines

- **Entity-spawn pressure** under high-density explosive combat is the theoretical risk. Watch error.log on first heavy-combat session.
- **ACE Captives Dev interaction** — frag-causes-incapacitation is the kind of edge that may produce unexpected unconscious states. Test before declaring fully stable.

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 2.1.3 (scaffold detected; may be newer than agent-reported 2.1.2)
- **Folder**: `profile_new/addons/Shrapnel2.1_59BA048FA618471A`
- **Last clean boot**: 2026-05-17 boot 8 (GAME at 15:13:02, arsenal 6689)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/59BA048FA618471A)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/59BA048FA618471A/changelog)
- Related: `[[BHE_EXP]]` (co-designed sibling), `[[BetterCasings]]` (same author family)
