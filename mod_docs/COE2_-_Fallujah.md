---
workshop_id: "21209DA9CF32FBE9"
workshop_url: https://reforger.armaplatform.com/workshop/21209DA9CF32FBE9
version: ""
author: "Kex (COE2 author)"
load_order_layer: L11
status: deployed-only
last_verified: 2026-05-16
declared_in:
  - deployed
hard_deps:
  - "60926835F4A7B0CA # COE2 - Combat Ops Enhanced 2"
  - "5ED61DC0AFE17E8E # Kex Scenario Core (transitive via COE2)"
reverse_deps: []
related_memories:
  - golden_state_2026_05_16_v5.md
folder: ""
---

# COE2 - Fallujah

> **One-line role**: COE2 scenario configuration for the **Fallujah** map — Iraq-style dense urban terrain. Heaviest dependency weight of the four iter3 alt-map scenarios.

## 1. Overview

Per [[golden_state_2026_05_16_v5]] iter3 table: "Iraq urban alternate scenario (heaviest dep weight)". One of four iter3-added COE2 alt-map scenarios. Fallujah is the heaviest of the four because urban maps carry the highest prefab counts (buildings, props, urban detail) — operators choosing this scenario should expect the longest first-deploy download and the highest steady-state memory footprint.

## 2. Functionality / Features

- Adds the COE2 scenario variant pointing at the Fallujah map
- Inherits ALL COE2 features: configurable faction picker, SDRC dynamic difficulty, CRX EAI behaviors
- Map: **Fallujah** — Iraq-style dense urban warfare environment, multi-story buildings, alleys, tight LoS lanes, courtyards
- Steam auto-pulls the Fallujah map mod (substantial size) as a transitive dep on first deploy

## 3. Configuration

**Config files**: none specific to this scenario beyond COE2 framework configs.

**Tunable keys**: surfaced via COE2's in-game scenario menu.

**Scenario activation**: set `serverconfig-deployed.json scenarioId` to this scenario's `.conf` resource path.

## 4. Operator usage

**In-game**: scenario itself — operator interacts via COE2's scenario menu.

**Switching workflow**: snapshot → edit scenarioId → restart container. **Note**: first switch to Fallujah will trigger the Steam map download — expect a longer-than-usual deploy boot the first time.

## 5. Compatibility & load order

- **Load order layer**: **L11** (scenario controllers — LAST).
- **Must load AFTER**: `COE2 - Combat Ops Enhanced 2` + `Kex Scenario Core` (transitive).
- **Must load BEFORE**: nothing.
- **Conflicts with**: other scenarios only at scenarioId selection time.
- **Synergies with**: `BattlefieldAmbienceMod` (urban war ambience), `GCSuppression` (close-quarters near-misses are common in urban CQB), `CRX_EnfusionAI` (Combat_Mode=2 GREEN defensive pairs well with corner-by-corner urban clearing).

## 6. Performance impact

**Heaviest of the four iter3 alt-map scenarios** per [[golden_state_2026_05_16_v5]]. Urban maps carry the highest building/prop count → highest GPU draw + highest memory footprint. Server-side AI tick cost may also be elevated since AI in dense urban environments fragment into more sub-groups (room-by-room clearing) than in open terrain.

Watch monitor #2 (PEAK density alert) when running this scenario — the 95 active-AI ceiling may be hit sooner than on Eden/Anizay.

## 7. Known issues / landmines

- **Heaviest first-deploy download** — Fallujah map mod is substantial; budget extra time on first switch.
- **Map dep delivery risk** per `[[landmine_steam_dedicated_addon_gproj_missing]]` — bigger map = bigger surface for an addon.gproj-missing failure.
- **AI navmesh in dense urban** can produce more frequent "Agent requires automatic orientation" entries vs open-terrain maps. Monitor `error.log` post-switch.
- **Player draw distance** in urban maps is shorter than open maps — engagements feel different. Adjust expectations.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: `version: ""`.
- **Declared in `serverconfig-deployed.json`**: yes (iter3 2026-05-15/16).
- **Declared in `serverConfig.json` (local)**: no.
- **Active scenarioId**: no — current is COE2_Eden.
- **Last clean boot**: pre-verification.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/21209DA9CF32FBE9)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/21209DA9CF32FBE9/changelog)
- **Companion docs**:
  - `mod_docs/COE2_-_Combat_Ops_Enhanced_2.md`, `mod_docs/COE2_-_Anizay.md`, `mod_docs/COE2_-_Khanh_Trung.md`, `mod_docs/COE2_-_Kunar_Province.md`
  - `mod_docs/BattlefieldAmbienceMod.md`, `mod_docs/GCSuppression.md` — urban warfare immersion pairing
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 rationale + "heaviest dep weight" flag
