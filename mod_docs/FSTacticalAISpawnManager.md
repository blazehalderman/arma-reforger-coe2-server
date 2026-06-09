---
workshop_id: "68494CE78A849933"
workshop_url: https://reforger.armaplatform.com/workshop/68494CE78A849933
version: "2.0.2"
author: "JacksonCoach"
load_order_layer: L9
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps: []
related_memories: []
folder: "FSTacticalAIAMPSpawnManager_68494CE78A849933"
---

# FSTacticalAISpawnManager

> **One-line role**: tactical AI overhaul + dynamic spawn-density scaler — adds context-based combat behaviors and prioritises AI spawns near strategic points based on player population.

## 1. Overview

FSTacticalAISpawnManager (Workshop title "FS Tactical AI & Spawn Manager", internal addon ID `MissionMakerIA`) is a **drop-in AI overhaul** that bolts on two independent systems:
1. **Tactical AI**: contextual behaviors (Defensive / Offensive / Patrol / Off-Duty), eight operational states, flanking, grenade usage, skill-tiered accuracy.
2. **Spawn manager**: scales enemy density to player count, biases spawns to objectives instead of forest noise.

It is **not a scenario controller** — it does not orchestrate objectives. It is a behaviour + spawn-density overlay that "works with all missions" per the author's Workshop description. In this stack, it runs alongside CRX EnfusionAI (also a behavior overlay) and SHSScenarioFramework (the actual objective generator). The two AI overlays do not formally conflict — they tune different surfaces (CRX = perception/aim/formation; FS = contextual state machine + spawn placement) — but operator should monitor for double-tuning artefacts if both are active.

## 2. Functionality / Features

- **Four context modes**: Defensive / Offensive / Patrol / Off-Duty
- **Eight operational states**: per the Workshop description (granular state machine inside the tactical AI)
- **Skill-based accuracy**: tiered marksmanship by AI rank/role
- **Tactical maneuvers**: flanking, grenade usage, cover-to-cover
- **Dynamic spawn scaling**: enemy count scales with player population
- **Strategic spawn placement**: prioritises objective-adjacent spawns over random forest spawns
- **Spawn limiter**: configurable ratios/limits to prevent runaway density

## 3. Configuration

**Config files**: **none documented in `$profile:/`** — the Workshop page states "no configuration needed" and the addon ships its tunables as `.c` script files baked into the data.pak:

| Script file (in pak) | Purpose |
|---|---|
| `FSAutoSpawnLimiter.c` | Spawn ratios and limits |
| `FSSpawnInterceptor.c` | Spawn-priority distances |
| `FSAISkillSystem.c` | Skill keywords / tier assignments |
| `FSTacticalCombatAI.c` | Tactical parameter constants |

**Tunable keys**: not operator-tunable at runtime. The script-baked constants can only be changed by Workbench-forking the mod. No `$profile:/` config files are created on first run.

| Key | Path | Default | Current | Effect |
|---|---|---|---|---|
| _N/A — no runtime config surface_ | — | — | — | tunables live in pak'd `.c` scripts |

## 4. Operator usage

**In-game**: passive — once loaded, the spawn manager and tactical AI engage automatically with any scenario's AI groups. No GM panel, no chat commands.

**Keybinds**: none.

**Admin commands**: none documented.

## 5. Compatibility & load order

- **Load order layer**: **L9** (AI overlays) per `INDEX.md` (the older MASTER_OBJECTIVE.md L9 entry erroneously lists this mod as "removed in COE2 pivot" — that note is stale; mod is in both local + deployed serverConfigs as of 2026-05-16)
- **Must load after**: nothing required by gproj (base-game only); needs L0-L8 content present for spawn manager to know what to spawn
- **Must load before**: scenario controllers at L11 — spawn manager hooks must be in place before COE2/SHS start spawning groups
- **Synergies with**:
  - **SHSScenarioFramework** — SHS picks where to put objectives; FS Spawn Manager biases AI spawn points near those objectives
  - **ConflictNoBaseAILimit** — both lift density restrictions, with FS adding the placement logic and ConflictNoBaseAILimit removing the unit-request cap
- **Conflicts with**:
  - **CRX EnfusionAI** — no hard conflict (both tune different surfaces) but both adjust AI behavior. Operator should monitor for "AI is doing CRX flanking then FS flanking" double-tuning artefacts during long sessions. No incident on record as of 2026-05-16.
  - **Procedural Combat (PCM)** — would conflict if PCM were ever re-added (PCM bypasses the spawn manager). PCM is abandoned (CLAUDE.md) so not a concern.

## 6. Performance impact

Author claim: spawn manager replaces inefficient random forest spawns with objective-biased placement — net result is *fewer* wasted AI ticks (AI no longer wandering empty terrain). No measured tick-cost regression on this stack. The state-machine overhead is per-AI-character; cost scales linearly with active AI count, well within budget at current aiLimit (3500 local / 1500 deployed).

## 7. Known issues / landmines

- **No operator-tunable config surface**: cannot adjust spawn ratios, skill tiers, or context thresholds without a Workbench fork. If FS spawn density ever needs tuning down (e.g. during a low-end-CPU host swap), the only knob is `aiLimit` in `serverConfig.json`.
- **Stale MASTER_OBJECTIVE.md note**: the L9 layer description claims this mod was "removed in COE2 pivot" — that is incorrect as of 2026-05-16. The mod is declared in both `serverConfig.json` (local 103-mod) and `serverconfig-deployed.json` (deployed 117-mod). Verify before purging on the basis of MASTER_OBJECTIVE's L9 note.
- **No documented incidents in any log to date.** No memory references.

## 8. Extending / modding

_N/A_ — closed-source AI overlay. To extend, fork via Workbench Subscribe-to-Source. Operator has not done this.

## 9. Changelog / verified state

- **Installed version**: 2.0.2 (Workshop last modified 07.01.2026)
- **Folder**: `FSTacticalAIAMPSpawnManager_68494CE78A849933` (folder name includes "AMP" — Workshop title is "FS Tactical AI & Spawn Manager"; folder spelling is legacy)
- **Last clean boot**: continuously loaded in 2026-05-16 V5 golden state

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/68494CE78A849933)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/68494CE78A849933/changelog)
- `INDEX.md` — declares mod active in both local + deployed
- `MASTER_OBJECTIVE.md` L9 — note that "removed in COE2 pivot" claim is stale
