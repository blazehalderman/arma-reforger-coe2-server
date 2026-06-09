---
workshop_id: "60926835F4A7B0CA"
workshop_url: https://reforger.armaplatform.com/workshop/60926835F4A7B0CA
version: "2.3.1"
author: "Kexanone"
load_order_layer: L11
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "5ED61DC0AFE17E8E # Kex Scenario Core"
reverse_deps: []
related_memories:
  - golden_state_2026_05_16_v5.md
  - golden_state_2026_05_14_v4.md
  - golden_state_2026_05_13_v3.md
github: https://github.com/Kexanone/COE2_AR
folder: "COE2_60926835F4A7B0CA"
---

# COE2 - Combat Ops Enhanced 2

> **One-line role**: Kex's next-generation cooperative-infantry scenario with **string-key faction picker** that supports ANY installed faction pack at runtime — the marquee feature replacing IPC's hardcoded 4-faction enum limit.

## 1. Overview

COE2 is the **active scenario** on this stack since the 2026-05-13 COE2 pivot. It is Kex's spiritual successor to Combat Ops Enhanced, drawing design from mbrdmn's Arma 3 *Dynamic Recon Ops*. The headline feature for this operator is **runtime configurable factions via string-key picker**: COE2's mission header exposes `m_sCOE_DefaultPlayerFactionKey`, `m_sCOE_DefaultEnemyFactionKey`, and `m_sCOE_DefaultCivilianFactionKey`, all of which accept any string-keyed faction registered by an installed faction pack (DarkGruFactions, Arma2Factions, BaconZombies on deployed, etc.). This eliminates the architectural ceiling that killed the previous IPC-based stack (see [[landmine-ipc-ignores-modded-enum-scr-ecampaignfaction]] memory: IPC had only 4 hardcoded enum slots).

Active scenario file on this stack: `{EE676FAB9DFA4CF7}Missions/COE2_Eden.conf`. Alternate maps available on deployed: COE2 Anizay, Khanh Trung, Kunar Province, Fallujah (operator switches via `serverconfig-deployed.json` `scenarioId` edit + `#restart`).

## 2. Functionality / Features

- **Dynamic objective generation** — procedural objectives within the configured Area of Operations
- **Runtime string-key faction picker** — `m_sCOE_DefaultPlayerFactionKey` / `m_sCOE_DefaultEnemyFactionKey` / `m_sCOE_DefaultCivilianFactionKey`
- **Configurable AI skill** — `m_eCOE_DefaultEnemyAiSkill` (numeric, default e.g. 50)
- **Configurable AI count** — `m_iCOE_DefaultMinEnemyAICount` + `m_fCOE_DefaultEnemyAICountMultiplier`
- **Configurable AO radius** — `m_fCOE_DefaultAORadius`
- **Configurable armed-vehicle count** — `m_iCOE_EnemyArmedVehicleCount`
- **Support & reinforcements toggles** — `m_bCOE_EnemySupportEnabled` + min/max reinforcement times
- **Civilian toggle** — `m_bCOE_CiviliansEnabled`
- **Votable commander role** — `m_bCOE_CommanderBecomesGM` (commander becomes Game Master)
- **In-game configurability** — commander can adjust parameters during play
- **Multi-map support** — 3 core scenarios (Arland, Everon, Kolguyev) + 11 community add-ons (Anizay, Denali, Fallujah, Khanh Trung, Kunar Province, Mussalo, Nizla Island, Novka, Ruha, Worthy Islands, Zimnitrita) + 5 community contributions

## 3. Configuration

**Config files**:
- **Scenario file**: `<scenarioId>.conf` (e.g. `Missions/COE2_Eden.conf` — embedded in COE2 mod's data.pak; not operator-editable without Workbench fork)
- **Operator selection**: `serverConfig.json scenarioId` — currently `{EE676FAB9DFA4CF7}Missions/COE2_Eden.conf`. Switching is a `serverConfig.json` edit + restart.
- **In-memory only**: scenario parameters and player state live in RAM during the session. **NO PERSISTENCE LAYER** — every server restart resets all state. EPF was removed 2026-05-11 (CLAUDE.md "Persistence — removed 2026-05-11"); do not re-add without a scenario-side integration.

**Mission-header parameters** (set in scenario `.conf` — operator changes via Workbench fork or by picking a different `scenarioId`):

| Parameter | Type | Effect |
|---|---|---|
| `m_sCOE_DefaultPlayerFactionKey` | string | Player faction key — accepts any installed faction's key |
| `m_sCOE_DefaultEnemyFactionKey` | string | **Marquee feature** — enemy faction key, accepts any installed faction pack at runtime |
| `m_sCOE_DefaultCivilianFactionKey` | string | Civilian faction key |
| `m_eCOE_DefaultEnemyAiSkill` | int | Enemy AI skill numeric (e.g. 50) |
| `m_iCOE_DefaultMinEnemyAICount` | int | Minimum enemy AI count |
| `m_fCOE_DefaultEnemyAICountMultiplier` | float | Multiplier applied to base count |
| `m_fCOE_DefaultAORadius` | float | Area of Operations radius (meters) |
| `m_iCOE_EnemyArmedVehicleCount` | int | Number of armed vehicles enemy gets |
| `m_bCOE_EnemySupportEnabled` | bool | Reinforcements toggle |
| `m_fCOE_MinEnemyReinforcementTime` | float | Min reinforcement delay (seconds) |
| `m_fCOE_MaxEnemyReinforcementTime` | float | Max reinforcement delay (seconds) |
| `m_bCOE_CiviliansEnabled` | bool | Spawn civilians |
| `m_bCOE_CommanderBecomesGM` | bool | Votable commander gets GM rights |

**Runtime override**: the votable commander can adjust parameters in-game via COE2's "Ingame Configurability" UI.

## 4. Operator usage

**Switching scenarios** (e.g. COE2_Eden → COE2_Anizay on deployed):
1. Snapshot first: `snapshot_state.ps1 -Label "pre-scenario-switch"`
2. Edit `serverConfig.json` (local) or `serverconfig-deployed.json` (deployed) → change `scenarioId` value
3. Restart server / `#restart` chat command
4. Verify in-game scenario name matches expected

**In-game**:
- Vote a commander; commander gets GM (if `m_bCOE_CommanderBecomesGM = true`) AND scenario parameter editor
- Commander adjusts AO radius, enemy density, faction picks during the session
- **No state persists across server restart.**

**Keybinds / Admin commands**: standard GM keybinds (`M` for entity manager) once commander is granted GM. No COE2-specific `#commands` beyond the votable-commander UI.

## 5. Compatibility & load order

- **Load order layer**: **L11** (Scenario controllers — LAST per `MASTER_OBJECTIVE.md`)
- **Hard deps** (per `addon.gproj`): base game + Kex Scenario Core. Kex Scenario Core in turn hard-deps **ACE Core Dev + ACE Captives Dev** (which is why stable ACE was REMOVED in the 2026-05-13 COE2 pivot — Kex requires the Dev pair specifically; see CLAUDE.md "What this is" + § "Active scenario behavior — COE2 Eden")
- **Must load after**: ALL L0-L10 mods (engine frameworks, realism cores, ACE Dev pair, WCS content, RHS↔WCS bridge, sway chain, faction packs, apparel, vehicle/weapon content packs, AI overlays). **Kex Scenario Core MUST precede COE2** (DAG fix 2026-05-14 per CLAUDE.md "DAG fixes").
- **Must load before**: nothing — COE2 is the terminal node in the load order
- **Synergies with**:
  - **CRX EnfusionAI** — applies behavior overlay to all COE2-spawned enemies
  - **SHSScenarioFramework** — SDRC controller running on top of COE2; reads `$profile:/DarcMods/dc_*.json` for enemy/vehicle bucket populations (see `SHSScenarioFramework.md`)
  - **Any installed faction pack** — COE2 picks up new factions automatically via string-key. Add a faction pack to mods[] and COE2's faction picker can use it immediately, no scenario fork needed.
  - **DarcChopper / AIMortarFireSupportSystem** — GM-fired sister assets, useful during COE2 sessions
- **Conflicts with**:
  - **Stable ACE** (removed 2026-05-13 COE2 pivot) — Kex hard-deps ACE Dev pair specifically; stable ACE and Dev ACE cannot coexist
  - **IPC AutonomousCaptureAI** (removed 2026-05-13) — replaced by COE2 entirely; do not re-add IPC

## 6. Performance impact

COE2 is a full scenario controller — it runs procedural objective generation, reinforcement timers, AO radius enforcement, faction enumeration, and vehicle spawn loops. Combined with `aiLimit 3500` (local) and CRX EAI overlay, server tick load is the dominant performance constraint on this stack. Peak observed: 100+ active AI groups during high-density engagements (golden state 2026-05-16 V5 verified). No frame-time regression vs the prior IPC stack at equivalent density; COE2 scales engagement to player count.

## 7. Known issues / landmines

- **String-key picker accepts ANY string** — if the operator (or commander UI) picks a faction key that no installed mod registers, COE2's fallback behavior is scenario-specific. On the SHSScenarioFramework + COE2 deployment this is mediated by `dc_coreConfig.json fallbackEnemyFaction` (currently `"USSR"` per iter3 2026-05-15 — see `SHSScenarioFramework.md` § 3).
- **No persistence layer** — repeating for emphasis. Players who expect their loadouts/positions to survive a restart will be disappointed. EPF is deliberately not in the stack (CLAUDE.md "Persistence — removed 2026-05-11").
- **Kex's hard-dep on ACE Dev pair** — replacing ACE Dev with stable ACE will crash boot at the gproj resolution stage. This was the cause of the 2026-05-14 121-mod revert (CLAUDE.md "Revision 2026-05-16 (golden state V5)").
- **Scenario `.conf` is in pak'd data** — to fine-tune COE2 Eden's mission-header parameters beyond what the in-game UI exposes, must Workbench-fork COE2 (currently planned not undertaken). Alternative: pick a different shipped `.conf` (COE2 Anizay / Khanh Trung / etc. on deployed).
- **In-memory parameter changes lost on restart** — commander's in-session tuning resets to scenario defaults on next boot.

## 8. Extending / modding

**Adding a new faction to COE2**: trivial — install the faction pack (e.g., a new faction mod that registers its faction with a string key like "MY_FACTION"), add to `serverConfig.json mods[]`, and COE2's enemy picker can target it immediately. No scenario fork needed. **This is the killer feature** that retired the planned IPC custom-faction Workbench bridge mod (`WORKBENCH_BRIDGE_MOD_PLAN.md` is now lower-priority per CLAUDE.md "What this is" footnote).

**Adding a new map**: subscribe a COE2 alt-map scenario (Anizay, Khanh Trung, Kunar Province, Fallujah are 3 KB scenario configs — Steam auto-pulls map deps). Then edit `serverConfig.json scenarioId` to the new `.conf` path.

**Custom scenario fork**: Workbench fork COE2_AR (GitHub: `Kexanone/COE2_AR`), edit mission-header parameters, build + publish or load locally.

## 9. Changelog / verified state

- **Installed version**: 2.3.1 (Workshop last modified 02.12.2025)
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot
- **Active scenario file**: `{EE676FAB9DFA4CF7}Missions/COE2_Eden.conf`
- **Last config change**: 2026-05-15 — `dc_coreConfig.json fallbackEnemyFaction "FIA" → "USSR"` on deployed (iter3 fix; see `SHSScenarioFramework.md`)

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/60926835F4A7B0CA)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/60926835F4A7B0CA/changelog)
- [GitHub: Kexanone/COE2_AR](https://github.com/Kexanone/COE2_AR)
- CLAUDE.md "What this is" — COE2 marquee role
- CLAUDE.md "Active scenario behavior — COE2 Eden" — full scenario behavior summary
- CLAUDE.md "Landmines discovered 2026-05-13" — historical IPC alternative documented
- `MASTER_OBJECTIVE.md` L11 — Kex Scenario Core → COE2 ordering
- Sister docs: `Kex_Scenario_Core.md` (hard-dep framework), `SHSScenarioFramework.md` (SDRC overlay), `CRX_EnfusionAI.md` (behavior overlay)
- Related memories: `[[golden_state_2026_05_16_v5]]`, `[[golden_state_2026_05_14_v4]]`, `[[golden_state_2026_05_13_v3]]`, `[[landmine_ipc_ignores_modded_enum_scr_ecampaignfaction]]`
