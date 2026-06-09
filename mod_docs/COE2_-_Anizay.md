---
workshop_id: "65734D75BC584950"
workshop_url: https://reforger.armaplatform.com/workshop/65734D75BC584950
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

# COE2 - Anizay

> **One-line role**: tiny (~3 KB) COE2 scenario configuration that points the COE2 framework at the **Anizay** map; Steam auto-pulls the map dependency on first declare.

## 1. Overview

Per [[golden_state_2026_05_16_v5]] iter3 table: "Alternate map scenario (Steam auto-pulls Anizay map dep)". This is one of four iter3-added COE2 alt-map scenarios (alongside `COE2_-_Khanh_Trung`, `COE2_-_Kunar_Province`, `COE2_-_Fallujah`) that give the operator runtime variety without rebuilding the COE2 framework. The actual map content (terrain, prefab placements, navmesh) is delivered by a separate map mod that Steam pulls automatically when this scenario mod is declared.

## 2. Functionality / Features

- Adds the COE2 scenario variant `{<GUID>}Missions/COE2_Anizay.conf` (or similar) — selectable via `serverconfig-deployed.json scenarioId` field
- Inherits ALL COE2 features: configurable faction picker, SDRC dynamic difficulty, CRX EAI behaviors
- Map: **Anizay** — Afghan-style terrain (mountainous, sparse vegetation, mud-walled villages)
- Steam auto-pulls the Anizay map mod as a transitive dep on first deploy

## 3. Configuration

**Config files**: none specific to this scenario beyond the COE2 framework's existing configs (`$profile:/DarcMods/dc_*.json` for SDRC, `$profile:/CRX_EAI/*.txt` for AI behavior).

**Tunable keys**: per-scenario knobs are typically surfaced via COE2's in-game scenario menu rather than disk-side config.

**Scenario activation**: set `serverconfig-deployed.json scenarioId` to this scenario's `.conf` resource path. Operators can swap between the 5 COE2 scenarios (Eden + 4 iter3 alternates) by editing scenarioId and `#restart`'ing.

## 4. Operator usage

**In-game**: not directly interacted with — it IS the scenario. Operator usage is via the COE2 scenario menu inside the game when this scenario is active.

**Switching to this map** (deployed only):
1. Snapshot config first (per `[[feedback_snapshot_before_changes]]`)
2. Edit `serverconfig-deployed.json scenarioId` → set to this scenario's resource path
3. Restart the deployed container via Pterodactyl panel (or `#restart` via admin chat if engine supports)
4. Watch monitor stack for `OnGameStateChanged = GAME`

**Admin commands**: standard COE2 admin commands; no scenario-specific additions.

## 5. Compatibility & load order

- **Load order layer**: **L11** (scenario controllers — LAST) per CLAUDE.md § "Mod stack architecture".
- **Must load AFTER**: `COE2 - Combat Ops Enhanced 2` (`60926835F4A7B0CA`), which itself requires `Kex Scenario Core` (`5ED61DC0AFE17E8E`).
- **Must load BEFORE**: nothing — scenarios are leaves of the DAG.
- **Conflicts with**: only one scenario can be `scenarioId` at a time; declaring multiple scenarios in mods[] is fine (they coexist on disk), but only one is "active" per scenario load.
- **Synergies with**: `SHSScenarioFramework` (SDRC overlay), `CRX_EnfusionAI`, `DarcChopper`, `AIMortarFireSupportSystem` — full COE2-stack interplay.

## 6. Performance impact

Negligible from the scenario config itself (~3 KB of data). The MAP dep that Steam pulls is heavier — Anizay terrain assets typically run 200-500 MB. Once on disk, per-tick cost is whatever the map's terrain LOD + AI density combine to produce.

## 7. Known issues / landmines

- **Map dep download is the failure surface, not the scenario config.** If the Anizay map mod fails to deliver `addon.gproj` on Steam re-download (per `[[landmine_steam_dedicated_addon_gproj_missing]]`), this scenario will fail to register with a `Cannot create entity` or `Unable to initialize the game` cascade.
- **First-deploy boot may take longer** while Steam pulls the map content; subsequent boots are normal.
- **Verify map compatibility with current COE2 version** — if COE2's scenario API changed and this alt-map scenario wasn't bumped to match, the scenario may load but objectives won't populate. Verify via in-game scenario start.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: `version: ""`.
- **Declared in `serverconfig-deployed.json`**: yes (iter3 2026-05-15/16).
- **Declared in `serverConfig.json` (local)**: no.
- **Active scenarioId**: no — current `scenarioId` remains `COE2_Eden.conf`. This alt is available for runtime switching.
- **Last clean boot**: pre-verification.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/65734D75BC584950)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/65734D75BC584950/changelog)
- **Companion docs**:
  - `mod_docs/COE2_-_Combat_Ops_Enhanced_2.md` — parent scenario framework
  - `mod_docs/COE2_-_Khanh_Trung.md`, `mod_docs/COE2_-_Kunar_Province.md`, `mod_docs/COE2_-_Fallujah.md` — iter3 alt-map siblings
  - `mod_docs/SHSScenarioFramework.md` — SDRC overlay
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 rationale
  - `[[landmine_steam_dedicated_addon_gproj_missing]]` — map-dep delivery risk
