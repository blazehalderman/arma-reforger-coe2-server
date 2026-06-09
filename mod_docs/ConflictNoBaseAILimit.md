---
workshop_id: "60E547E88A9221E5"
workshop_url: https://reforger.armaplatform.com/workshop/60E547E88A9221E5
version: "0.0.2"
author: "c0da"
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
folder: "ConflictNoBaseAILimit_60E547E88A9221E5"
---

# ConflictNoBaseAILimit

> **One-line role**: lifts vanilla Conflict's hard AI cap so unit requests are constrained only by available supply.

## 1. Overview

Vanilla Conflict imposes a per-base AI-unit-request cap (originally ~200 active AI per base, used as a runaway-density guard). ConflictNoBaseAILimit is a **tiny script patch** (mod size: 0.82 KB) that strips that cap — players can now request as many units as their supply permits.

Mod is targeted at the vanilla Conflict game mode but its hook is small enough that it co-exists with COE2 / SHSScenarioFramework on this stack without measurable interaction. It does NOT raise the engine-level `aiLimit` (that's a `serverConfig.json` knob) — it raises the per-base *request* cap so squad-call requests don't get gated.

## 2. Functionality / Features

- Removes the per-base unit-request cap in vanilla Conflict
- No new entities, no new UI, no new commands — pure script behaviour patch

## 3. Configuration

**Config files**: none. **No tunables.** Mod is on/off via mods[] declaration.

| Key | Path | Default | Current | Effect |
|---|---|---|---|---|
| _N/A — no configuration surface_ | — | — | — | — |

The relevant engine knob is `aiLimit` in `serverConfig.json` (currently **3500** local / **1500** deployed per CLAUDE.md "State summary"). That cap is independent of this mod.

## 4. Operator usage

**In-game**: no operator action required. Players in a Conflict-style scenario can now request unlimited squads via the vanilla request menu (subject to supply).

**Keybinds / Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L9** (AI overlays — density-cap-bypass)
- **Must load after**: nothing required by gproj (base-game only)
- **Must load before**: scenario controllers at L11 — the patch must apply before scenario init
- **Synergies with**:
  - `aiLimit` in `serverConfig.json` — together these raise both the engine-level AI ceiling AND the per-base request floor
  - **FSTacticalAISpawnManager** — both lift density-side constraints (FS adds placement intelligence)
- **Conflicts with**: none on this stack. The mod targets vanilla Conflict hooks that COE2/SHS don't actively override.

## 6. Performance impact

Negligible code footprint (0.82 KB). The performance question is downstream — if players actually request enough units to push past `aiLimit 3500`, the engine starts rejecting additional spawns at the global level. Operator should monitor for `Cannot spawn entity, AI limit exceeded` lines in `script.log` if density complaints arise.

## 7. Known issues / landmines

- **Built against game version 1.1.0.34** (March 2024). The mod has not been re-versioned for 1.6.0.119. The patch is small enough that it has continued to apply across engine updates, but this is a candidate for "silent breakage on next major engine version." Verify by spamming squad requests in-game during a test session — if requests cap at vanilla limits, mod has stopped applying.
- **Targets vanilla Conflict mechanics specifically** — on this stack the active scenario is COE2 (not vanilla Conflict). The mod's effect on COE2 is minimal-to-none since COE2 doesn't use vanilla Conflict's per-base squad-request gate. Mod is effectively dormant on the COE2 stack but harmless.
- **No documented incidents in any log to date.**

## 8. Extending / modding

_N/A_ — tiny single-purpose patch. No extensibility surface.

## 9. Changelog / verified state

- **Installed version**: 0.0.2 (game version 1.1.0.34 target — see § 7)
- **Workshop**: released March 18, 2024; 7,042 downloads
- **Last clean boot**: continuously loaded in 2026-05-16 V5 golden state

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/60E547E88A9221E5)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/60E547E88A9221E5/changelog)
- `INDEX.md` — `ai:density-cap-bypass`
