---
workshop_id: "61BB79ADF3596AEA"
workshop_url: https://reforger.armaplatform.com/workshop/61BB79ADF3596AEA
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

# COE2 - Kunar Province

> **One-line role**: COE2 scenario configuration for the **Kunar Province** map — Afghanistan-style mountainous terrain. Tiny scenario shim; Steam auto-pulls the Kunar map dep.

## 1. Overview

Per [[golden_state_2026_05_16_v5]] iter3 table: "Afghanistan-style alternate scenario". One of four iter3-added COE2 alt-map scenarios. Kunar gives operators a mountainous/valley environment for long-range engagement setups — pairs well with the iter3 DarcChopper compat shim work since gunship CAS thrives on open mountain terrain.

## 2. Functionality / Features

- Adds the COE2 scenario variant pointing at the Kunar Province map
- Inherits ALL COE2 features: configurable faction picker, SDRC dynamic difficulty, CRX EAI behaviors
- Map: **Kunar Province** — high-altitude Afghan-style terrain, narrow valleys, rocky compounds, sparse forest
- Steam auto-pulls the Kunar Province map mod as a transitive dep on first deploy

## 3. Configuration

**Config files**: none specific to this scenario beyond COE2 framework configs.

**Tunable keys**: surfaced via COE2's in-game scenario menu.

**Scenario activation**: set `serverconfig-deployed.json scenarioId` to this scenario's `.conf` resource path.

## 4. Operator usage

**In-game**: scenario itself — operator interacts via COE2's scenario menu.

**Switching workflow**: snapshot → edit scenarioId → restart container.

## 5. Compatibility & load order

- **Load order layer**: **L11** (scenario controllers — LAST).
- **Must load AFTER**: `COE2 - Combat Ops Enhanced 2` + `Kex Scenario Core` (transitive).
- **Must load BEFORE**: nothing.
- **Conflicts with**: other scenarios only at scenarioId selection time.
- **Synergies with**: `DarcChopper` + `KA52forDarcChopper` (mountain CAS), `CRX_EnfusionAI` (long-range perception is the dominant CRX surface here), `AIMortarFireSupportSystem` (mountain IDF).

## 6. Performance impact

Negligible scenario shim itself. Kunar map terrain is dense (mountainous LODs are heavier than flat-terrain maps) — moderate GPU impact client-side.

## 7. Known issues / landmines

- **Map dep delivery risk** per `[[landmine_steam_dedicated_addon_gproj_missing]]`.
- **AI pathing on steep terrain** — Reforger AI struggles with very steep slopes. Watch error.log for `Agent requires automatic orientation` storms; if observed at higher rate than on Eden, the map's navmesh has problem zones.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: `version: ""`.
- **Declared in `serverconfig-deployed.json`**: yes (iter3 2026-05-15/16).
- **Declared in `serverConfig.json` (local)**: no.
- **Active scenarioId**: no — current is COE2_Eden.
- **Last clean boot**: pre-verification.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/61BB79ADF3596AEA)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/61BB79ADF3596AEA/changelog)
- **Companion docs**:
  - `mod_docs/COE2_-_Combat_Ops_Enhanced_2.md`, `mod_docs/COE2_-_Anizay.md`, `mod_docs/COE2_-_Khanh_Trung.md`, `mod_docs/COE2_-_Fallujah.md`
  - `mod_docs/DarcChopper.md`, `mod_docs/KA52forDarcChopper.md` — gunship CAS pairing
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 rationale
