---
workshop_id: "5F268647F8A1A1F4"
workshop_url: https://reforger.armaplatform.com/workshop/5F268647F8A1A1F4
version: "1.3.71"
author: "ATiM-"
load_order_layer: L9
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps: []
related_memories:
  - golden_state_2026_05_16_v5.md
  - golden_state_2026_05_14_v4.md
  - golden_state_2026_05_13_v3.md
  - golden_state_2026_05_12_v2.md
folder: "CRXEnfusionA.I._5F268647F8A1A1F4"
---

# CRX_EnfusionAI

> **One-line role**: behavioral overlay for vanilla AI — adds perception, flanking, fireteam splits, suppression, and a GM tuning UI without replacing the base AI system.

## 1. Overview

CRX Enfusion A.I. is the **PCM-replacement behavior overlay** on this stack (replaced `IPCHigherAISkill` 2026-05-12; replaced PCM behavior expectations after the PCM abandonment 2026-05-12). It is a non-invasive overlay — it does NOT swap out the vanilla AI; it tunes vanilla AI by feeding modifiers into perception, aim, combat mode, formation, and reaction-delay parameters. Configuration lives in **three plaintext .txt files** under `profile_new/profile/CRX_EAI/` that are auto-regenerated with defaults if deleted.

The current tuning (2026-05-14 realism pass — preserved in 2026-05-16 V5 golden) trades raw lethality for human-like behavior: AI no longer sees better than humans, no longer aims tighter than humans, no longer reacts faster than humans, and now retreats under bad conditions. See § 3 for the full tunable table.

## 2. Functionality / Features

- **Perception system** (3-state — Safe / Vigilant / Alerted) with separate values per state and a global additive modifier
- **Aim accuracy modifier** — symmetric scale around 0; positive = worse aim, negative = better aim
- **Combat mode** — RED (aggressive) / YELLOW (moderate) / GREEN (defensive) / WHITE (very defensive)
- **Formation scale** — group dispersion multiplier (affects burst-fire/artillery survivability)
- **Suppression** — AI uses suppressive fire AND reacts to it (audible-distance tunable separately for suppressed vs unsuppressed)
- **Investigate behavior** — AI groups investigate sounds/contacts
- **Combat movement type** — GROUP / FIRETEAM / INDIVIDUAL / AUTONOMOUS (currently FIRETEAM = group splits to 4-man fireteams)
- **Flee chance** — % chance to retreat under bad conditions
- **Rearm behavior** — None / Default / Weapons / Magazines
- **Environment-aware modifiers** (Experimental config) — weather, movement, low-light, perceived-faction
- **Rank system override** — Rank_Type 0 (CRX-internal) or 1 (Vanilla; defers to NoRankRequirements)
- **Game Master UI panel** — per-group / per-character settings (stance, combat mode, formation, flee chance, hold position)

## 3. Configuration

**Config files** (all live under `profile_new/profile/CRX_EAI/`):
- `CRX_EAICharacterConfig.txt` — per-character tunables (perception, aim, stance, flee, reaction delay, rank type)
- `CRX_EAIGroupConfig.txt` — per-group tunables (formation, combat mode, suppression, investigation, weapon-reaction distances)
- `CRX_EAIExperimentalConfig.txt` — environmental modifiers (weather, movement, low-light, comms)

Each file is plaintext `KEY=VALUE` format with `#` for comments. **Delete the file to regenerate with defaults.** Edit and restart mission for changes to apply.

**Tunable keys** (current state — verified 2026-05-16, all values realism-tuned 2026-05-14 per CLAUDE.md "Density tuning knobs" table):

### Character config (`CRX_EAICharacterConfig.txt`)

| Key | Default | Current | Effect |
|---|---|---|---|
| `Rank_Type` | 0 (CRX) | **1 (Vanilla)** | Honors NoRankRequirements rank bypass — see § 7 landmine |
| `Rearm_Type` | 1 | 1 (Default) | AI rearms with default item set |
| `Perception_Safe` | 1.0 | 2.0 | Detection speed in SAFE state |
| `Perception_Vigilant` | 2.0 | 3.0 | Detection speed in VIGILANT state |
| `Perception_Alerted` | 1.5 | 2.5 | Detection speed in ALERTED state |
| `Perception_Modifier` | 0.0 | **0.0** | Additive global perception modifier (was 0.3 pre-realism pass) |
| `Aim_Accuracy_Error_Modifier` | 0.0 | **0.8** | Spread multiplier — was 0.4 pre-realism pass; 0.8 = noticeable miss at range |
| `Stance` | 3 | 3 (Autonomous) | AI picks stance per situation |
| `Flee_Chance` | 0 | **20** | % chance to retreat under bad conditions — was 0 (unbreakable) pre-realism pass |
| `Danger_Reaction_Chance` | 80 | 80 | % chance AI reacts to danger events |
| `Magazine_Consumption_Chance` | 100 | 100 | % AI consumes full mag before reload |
| `Attack_Reaction_Delay_Modifier` | 0 | **800** | ms delay from spot to fire — was 200 (robot-fast) pre-realism pass |

### Group config (`CRX_EAIGroupConfig.txt`)

| Key | Default | Current | Effect |
|---|---|---|---|
| `Formation_Scale` | 1.0 | **2.0** | Group dispersion — was 1.5 pre-realism pass; 2.0 = artillery survivability |
| `Weapon_Fired_Reaction_Distance` | 400 | 400 | Meters AI reacts to unsuppressed gunfire |
| `Suppressed_Weapon_Audible_Distance` | 80 | 80 | Meters AI hears suppressed weapons |
| `Investigate` | true | true | Groups investigate sounds/contacts |
| `Investigate_Duration` | -1 | -1 (dynamic) | -1 = engine calculates from group knowledge |
| `Suppress` | true | true | Groups use suppressive fire |
| `Suppress_Duration` | -1 | -1 (dynamic) | -1 = engine calculates from threat level |
| `Combat_Mode` | 1 (YELLOW) | **2 (GREEN)** | Pace of advance — was YELLOW pre-realism pass; GREEN = realistic |
| `Combat_Move_Chance` | 100 | 100 | % chance group moves during combat |
| `Combat_Cover_Chance` | 100 | 100 | % chance group seeks cover during combat |
| `Combat_Movement_Type` | 3 (AUTONOMOUS) | 1 (FIRETEAM) | Group splits into fireteams |
| `Combat_In_Cover_Dynamic_Cover_Search_Chance` | 70 | 70 | % chance to look for new cover while already in cover |

### Experimental config (`CRX_EAIExperimentalConfig.txt`)

| Key | Default | Current | Effect |
|---|---|---|---|
| `Comms_Handler_Timeout` | 10 | 10 | Seconds between AI radio comms (randomized upward) |
| `Weather_Conditions_Affects_AI` | true | true | Rain/fog reduces perception |
| `Movement_Affects_AI_Aim_Accuracy` | true | true | Running AI shoots worse |
| `Low_Light_Environment_Affects_AI` | true | true | Night reduces perception |
| `Low_Light_Environment_Modifier` | 2.0 | 2 | Divisor applied to perception in low-light |
| `Perceived_Faction_Changes_Affects_AI` | true | **false** | Disabled — prevents disguise-mod interaction noise |

**Backup files exist with `.GOLDEN-2026-05-12_23-30_HighDensity_PCM-CRX` suffix** (pre-realism-pass snapshot when CRX was tuned for high-density / aggressive AI). Restore via filename swap if realism tuning ever needs reverting.

## 4. Operator usage

**In-game (Game Master)**:
1. Open GM panel (`M`)
2. Select an AI group or character
3. Per CRX's GM UI panel: adjust stance, combat mode, formation type, investigate/suppress toggles, hold-position, flee chance, flashlight toggles
4. Changes apply live without scenario restart

**Chat / admin**: no CRX-specific `#commands`.

**Keybinds**: no CRX-specific keybinds beyond standard GM UX.

## 5. Compatibility & load order

- **Load order layer**: **L9** (AI overlays) per `MASTER_OBJECTIVE.md`
- **Must load after**: nothing required by gproj (base-game only) — but L0-L8 mods (faction packs, vehicle content, weapon packs) must be present so CRX can apply behaviors to their prefabs
- **Must load before**: scenario controllers (L11 Kex + COE2) — CRX hooks AI lifecycle and needs to be initialized before scenarios spawn groups
- **Synergies with**:
  - **NoRankRequirements** — only effective when CRX `Rank_Type=1`; CRX `Rank_Type=0` silently overrides any external rank-bypass mod (see § 7 landmine)
  - **COE2 / SHSScenarioFramework** — CRX behaviors apply to all AI spawned by either controller
  - **AIMortarFireSupportSystem / AiMortarPve / DarcChopper** — CRX modifies their crew/AI perception identically
- **Conflicts with**: nothing in current stack. Replaced `IPCHigherAISkill` 2026-05-12 (latter had hardcoded skill 70-100 + perception 1.5-2.0 → "across the map laser AI" + NULL `targetFaction` deref crash — see CLAUDE.md "Known landmines" table).

## 6. Performance impact

CRX overlays vanilla AI's update loop — each AI tick now passes through CRX's perception/comms/aim modifier hooks. At PCM-era densities (40-60 active groups) the cost was unmeasurable; at COE2 peak densities (100+ active groups via aiLimit 3500) CRX's `OnUpdate` hook fires per-character per-tick. Cosmetic VM exceptions are emitted from `CRX_EAI/SCR_AIHelpers/ArmaReforgerScripted.c:153 OnUpdate` when CRX's update calls into a NULL `targetFaction` perception state (see CLAUDE.md § Cosmetic noise) — non-fatal, fires once per drop-weapon event.

No measured frame-time regression on the current 103-mod local / 117-mod deployed stack.

## 7. Known issues / landmines

- **`Rank_Type=0` silently overrides NoRankRequirements**: CRX's CRX-internal rank system (Rank_Type=0) runs orthogonal to any external rank-bypass mod. With Rank_Type=0, NoRankRequirements is silently ignored and players cannot bypass rank gates for building/spawning. **Fix: keep `Rank_Type=1` (Vanilla)** so NoRankRequirements is honored. Verified set correctly at `CRX_EAICharacterConfig.txt:13` (CLAUDE.md "Landmines discovered 2026-05-13"). This is the single most important CRX tuning landmine.
- **CRX cosmetic VM exceptions** (CLAUDE.md § Cosmetic noise): `SCRIPT (E): Virtual Machine Exception` from `CRX_EAI/SCR_AIHelpers/ArmaReforgerScripted.c:153 OnUpdate` is the perception-state NULL deref. Non-fatal, ignore unless density regresses or process freezes.
- **Pre-realism-pass tuning still on disk** as `.GOLDEN-2026-05-12_23-30_HighDensity_PCM-CRX` files — these were the high-density / aggressive defaults paired with PCM expectations. If a future operator restores them without thinking, AI will be back to laser perception + zero flee + 200ms reactions. **Do not restore those files without an explicit feature request.**
- **Default-regenerated files lose all tuning**: deleting any CRX_EAI*.txt regenerates it with vanilla defaults — operator must re-apply the realism-pass values. Snapshot before deletion.
- **Folder name oddity**: addon folder is `CRXEnfusionA.I._5F268647F8A1A1F4` (literal period-A-period-I) — Workshop title contains periods. Search by GUID, not by name.

## 8. Extending / modding

CRX is a **closed framework** — it's a runtime behavior overlay, not an extensibility API. Operator tuning is via the 3 .txt files only; there is no scripting hook to add custom behaviors without a Workbench fork of the mod itself.

Per-group GM UI overrides ARE the official extension surface: any non-default value set in-game via the CRX GM panel applies only to that group/character for the session (no persistence — resets on restart since this stack has no persistence layer).

## 9. Changelog / verified state

- **Installed version**: 1.3.71 (Workshop "Stable v.1.6.0.119")
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot
- **Last config change**: 2026-05-14 realism pass (Perception_Modifier 0.3→0.0, Aim_Error 0.4→0.8, Flee 0→20, ReactionDelay 200→800, Formation 1.5→2.0, Combat_Mode 1→2)
- **Workshop last modified**: 05.04.2026

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/5F268647F8A1A1F4)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/5F268647F8A1A1F4/changelog)
- CLAUDE.md "Density tuning knobs — current values (2026-05-14 golden state V4)" — canonical source for current tuning values
- CLAUDE.md "Landmines discovered 2026-05-13" → "CRX_EAI Rank_Type — keep at 1"
- CLAUDE.md § Cosmetic noise — CRX perception/`weapMgr` NULL exceptions
- Related memories: `[[golden_state_2026_05_16_v5]]`, `[[golden_state_2026_05_14_v4]]`, `[[golden_state_2026_05_13_v3]]`, `[[golden_state_2026_05_12_v2]]`
