---
workshop_id: "61C57D80C78AE1C1"
workshop_url: https://reforger.armaplatform.com/workshop/61C57D80C78AE1C1
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

# COE2 - Khanh Trung

> **One-line role**: COE2 scenario configuration for the **Khanh Trung** map — Vietnam-era jungle/village terrain. Tiny scenario shim; Steam auto-pulls the Khanh Trung map dep.

## 1. Overview

Per [[golden_state_2026_05_16_v5]] iter3 table: "Vietnam-era alternate scenario". One of four iter3-added COE2 alt-map scenarios. Khanh Trung gives operators a thick-jungle/village environment for tropical PvE setups — pairs naturally with the iter3 `HushedWoodlands` mod for proper jungle ambient dampening.

## 2. Functionality / Features

- Adds the COE2 scenario variant pointing at the Khanh Trung map (~Vietnam-era jungle/village environment)
- Inherits ALL COE2 features: configurable faction picker, SDRC dynamic difficulty, CRX EAI behaviors
- Map: **Khanh Trung** — dense vegetation, jungle paths, rural village structures (Vietnam-era styling)
- Steam auto-pulls the Khanh Trung map mod as a transitive dep on first deploy

## 3. Configuration

**Config files**: none specific to this scenario beyond COE2 framework configs.

**Tunable keys**: surfaced via COE2's in-game scenario menu.

**Scenario activation**: set `serverconfig-deployed.json scenarioId` to this scenario's `.conf` resource path. See `mod_docs/COE2_-_Anizay.md` §4 for the activation workflow.

## 4. Operator usage

**In-game**: scenario itself — operator interacts via COE2's scenario menu.

**Switching workflow**: snapshot → edit scenarioId → restart container → verify GAME state.

**Admin commands**: standard COE2 admin commands.

## 5. Compatibility & load order

- **Load order layer**: **L11** (scenario controllers — LAST).
- **Must load AFTER**: `COE2 - Combat Ops Enhanced 2` + `Kex Scenario Core` (transitive).
- **Must load BEFORE**: nothing.
- **Conflicts with**: other scenarios only at scenarioId selection time.
- **Synergies with**: `HushedWoodlands` (perfect fit for jungle ambient), `BattlefieldAmbienceMod`, `CRX_EnfusionAI` (perception tuning for foliage-heavy maps).

## 6. Performance impact

Negligible scenario shim itself. Khanh Trung map dep is the heavy delivery — dense jungle terrain typically carries higher prefab counts and foliage LOD than open-terrain maps, so expect slightly elevated GPU load client-side. Server-side AI tick cost is unchanged.

## 7. Known issues / landmines

- **Map dep delivery risk** per `[[landmine_steam_dedicated_addon_gproj_missing]]`.
- **AI navmesh quirks in dense foliage** — Kex/COE2 scenarios rely on the map's navmesh; jungle terrain often has gaps the AI gets stuck on. Watch error.log for `Agent requires automatic orientation` storms (similar to the IPCHigherAISkill incident pattern in CLAUDE.md § "Known landmines"). If observed, may need to tune CRX EAI Formation_Scale or aiLimit downward for this map specifically.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: `version: ""`.
- **Declared in `serverconfig-deployed.json`**: yes (iter3 2026-05-15/16).
- **Declared in `serverConfig.json` (local)**: no.
- **Active scenarioId**: no — current is COE2_Eden.
- **Last clean boot**: pre-verification.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/61C57D80C78AE1C1)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/61C57D80C78AE1C1/changelog)
- **Companion docs**:
  - `mod_docs/COE2_-_Combat_Ops_Enhanced_2.md`, `mod_docs/COE2_-_Anizay.md`, `mod_docs/COE2_-_Kunar_Province.md`, `mod_docs/COE2_-_Fallujah.md`
  - `mod_docs/HushedWoodlands.md` — jungle ambient pairing
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 rationale
