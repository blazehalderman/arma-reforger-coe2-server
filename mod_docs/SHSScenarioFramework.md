---
workshop_id: "687B6840885E539D"
workshop_url: https://reforger.armaplatform.com/workshop/687B6840885E539D
version: "1.0.22"
author: "Shadow_Haven_Studios"
load_order_layer: L11
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
folder: "SHSScenarioFramework_687B6840885E539D"
---

# SHSScenarioFramework

> **One-line role**: **SDRC controller** ("Endless Objectives PVE") — drop-in dynamic-objective system running ON TOP of COE2, with operator-tunable enemy/vehicle catalogs at `$profile:/DarcMods/dc_*.json`.

## 1. Overview

SHSScenarioFramework is the **SDRC (Shadow Haven Studios "Drop-in Combat" / "Dynamic Combat" / similar acronym — exact expansion not documented; operator notation in CLAUDE.md is "SDRC controller")** layer that runs on top of COE2. SHS auto-discovers locations on any loaded map, spawns objectives, and manages AI intensity **without map-specific setup**. The framework reads three operator-tunable JSON config files under `profile_new/profile/DarcMods/` (note: "DarcMods" is the directory name despite SHS being authored by Shadow_Haven_Studios — the file naming convention is borrowed from the `darc` ecosystem).

The SDRC controller is what populates the **G_*** group buckets (`G_LIGHT`, `G_SNIPER`, `G_LAUNCHER`, `G_HEAVY`, `G_SPECIAL`, etc.) and **C_*** character buckets (`C_RIFLEMAN`, `C_HEAVY`, `C_RECON`, etc.) and the **VEHICLE_*** vehicle buckets from installed faction packs. Per CLAUDE.md "State summary 2026-05-16" → "Shared across local + deployed": *"SDRC populates G_* group lists (78 G_LIGHT + 76 G_HEAVY etc.) from installed factions + C_* character lists (799 C_RANDOMIZED). Vehicle lists: ~2000+ entries."*

In-game admin interaction is via the **`#shs` chat command family**.

## 2. Functionality / Features

- **Auto-location discovery** on any map (no scenario-author setup)
- **Procedural objective spawn** within discovered locations
- **AI intensity scaling** based on player count + difficulty setting
- **Endless PVE / PVPVE loop** — objectives regenerate as completed
- **G_* / C_* / VEHICLE_* bucket population** — reads installed faction prefabs and slots them into category buckets
- **In-game chat commands** — `#shs help / status / difficulty / spawn / clear / pause / resume / aicount / locations`
- **Drop-in** — "works on any map" with zero pre-config

## 3. Configuration

**Config files** (paths under server root):
- `profile_new/profile/DarcMods/dc_coreConfig.json` — SDRC core settings (logLevel, subDir, debug toggles, **`fallbackEnemyFaction`**, building/object filters)
- `profile_new/profile/DarcMods/default/dc_enemyList.json` — bucket definitions for groups (G_LIGHT, G_SNIPER, G_HEAVY etc.) and characters (C_RIFLEMAN, C_HEAVY etc.) + zombie buckets (G_ZOMBIE_SMALL/MEDIUM/LARGE, C_ZOMBIE, C_DEMON, C_DEMON_BOSS, C_BEASTS) with `include`/`exclude` filters and `modDir` mod-specific lookup paths
- `profile_new/profile/DarcMods/default/dc_vehicleList.json` — bucket definitions for vehicles (VEHICLE_WHEELED_ALL, VEHICLE_HELICOPTER_ALL, VEHICLE_CHOPPER_ARMED, etc.)
- **Backup files exist** with `.pre-fix-2026-05-15.json` and `.pre-fallback-fix-2026-05-15.json` suffixes (iter3 SDRC config rollback baseline per CLAUDE.md "Revision 2026-05-16")

**Tunable keys** (current state — verified 2026-05-16):

### `dc_coreConfig.json`

| Key | Default | Current | Effect |
|---|---|---|---|
| `jsonVersion` | 2 | 2 | Schema version |
| `author` | "darc" | "darc" | Config provenance string |
| `logLevel` | 3 | 3 | Verbosity (higher = more logs) |
| `subDir` | "default" | "default" | Sub-directory under DarcMods/ for enemyList/vehicleList |
| `debugShowWaypoints` | false | false | Debug overlay toggle |
| `debugShowMarks` | false | false | Debug overlay toggle |
| `debugShowSpheres` | false | false | Debug overlay toggle |
| `debugShowLines` | false | false | Debug overlay toggle |
| `debugShowInfo` | false | false | Debug overlay toggle |
| **`fallbackEnemyFaction`** | "FIA" | **"USSR"** | **iter3 fix 2026-05-15** — when modded faction lookup fails, fallback now spawns vanilla Soviets instead of vanilla FIA insurgents (CLAUDE.md "Revision 2026-05-16") |
| `showOnGMMapNonValidArea` | true | true | GM map overlay |
| `showOnGMMapMissionMarker` | true | true | GM map overlay |
| `buildingExcludeFilter` | (list) | (list, ~45 entries) | Building name fragments excluded from objective spawn (BrickPile, WoodPile, etc.) |
| `emptyPos.limit` | 5 | 5 | Empty-position search budget |
| `emptyPos.ignoreFilter` / `.stopFilter` / `.classFilter` / `.objectFilter` | (lists) | (lists) | Entity-class filters for empty-position checks |
| `locationAkas` | (list) | (list) | Type→name aliases for location discovery (military / airport / harbour) |
| `buildingAkas` | (list) | (list) | Type→name aliases for buildings (Church / Mosque, Police) |

### `dc_enemyList.json` — bucket structure

Each bucket entry shape:
```json
{
  "id": "G_LIGHT",
  "modDir": ["Prefabs/Groups", "<MODGUID>/Prefabs/Groups"],
  "include": ["LightFire", "FireTeam", "RifleSquad", "Group_Zombies_*", ...],
  "exclude": ["_Base", "_NotSpawned", "_Remnants", "_Random", "_Heavy"],
  "items": [],
  "factions": []
}
```

Buckets defined (verified by `grep '"id"' dc_enemyList.json`):
- **Groups**: G_LIGHT, G_SNIPER, G_LAUNCHER, G_ADMIN, G_MEDICAL, G_RECON, G_HEAVY, G_SPECIAL, G_SMALL
- **Characters**: C_RIFLEMAN, C_HEAVY, C_RECON, C_OFFICER, C_CREW, C_SNIPER, C_LAUNCHER, C_MEDIC, C_SPECIAL
- **Zombies** (BaconZombies content — deployed only): G_ZOMBIE_SMALL, G_ZOMBIE_MEDIUM, G_ZOMBIE_LARGE, C_ZOMBIE, C_DEMON, C_DEMON_BOSS, C_BEASTS

The `modDir` entry `"622120A5448725E3/Prefabs/Groups"` is the BaconZombies GUID — that's how SDRC pulls the zombie groups into the buckets without hard-coding faction names.

### `dc_vehicleList.json` — bucket structure

Buckets defined: VEHICLE_WHEELED_ALL, VEHICLE_WHEELED_MILITARY_ALL, VEHICLE_WHEELED_CIVILIAN_ALL, VEHICLE_WHEELED_ARMED, VEHICLE_WHEELED_UNARMED, VEHICLE_WHEELED_ARMOR, VEHICLE_WHEELED_CIVILIAN_TRUCK, VEHICLE_WHEELED_MILITARY_TRUCK, VEHICLE_WHEELED_CIVILIAN_CAR, VEHICLE_WHEELED_MILITARY_CAR, VEHICLE_HELICOPTER_ALL, VEHICLE_CHOPPER_ALL, VEHICLE_CHOPPER_TRANSPORT, VEHICLE_CHOPPER_ARMED.

## 4. Operator usage

**In-game chat commands** (from Workshop documentation):

| Command | Effect |
|---|---|
| `#shs help` | Show command list |
| `#shs status` | Print SDRC status (active objectives, AI count, difficulty) |
| `#shs difficulty <N>` | Set difficulty level |
| `#shs spawn` | Manually trigger objective spawn |
| `#shs clear` | Clear current objectives |
| `#shs pause` | Pause SDRC loop |
| `#shs resume` | Resume SDRC loop |
| `#shs aicount` | Show current AI count |
| `#shs locations` | List discovered locations |

**Operator JSON-edit workflow** (e.g., to widen a bucket):
1. `snapshot_state.ps1 -Label "pre-sdrc-tune"`
2. Edit `dc_enemyList.json` or `dc_vehicleList.json` `include`/`exclude` arrays
3. Write back as UTF-8 no-BOM (CLAUDE.md "Operational conventions")
4. Restart server (config is read at scenario init)

## 5. Compatibility & load order

- **Load order layer**: **L11** (Scenario controllers — runs on top of COE2)
- **Hard deps** (per `addon.gproj`): base game only — SHS is intentionally light on dependencies ("drop-in" claim)
- **Must load after**: COE2 + faction packs + vehicle content packs (SDRC enumerates prefabs from these at init)
- **Must load before**: nothing — terminal node in load order
- **Synergies with**:
  - **COE2** — SDRC runs on top of COE2's GameMode; COE2 provides the scenario shell, SDRC provides the endless-objective loop
  - **BaconZombies** (deployed only) — explicitly referenced by GUID in `dc_enemyList.json modDir` to populate zombie buckets (iter3 add per CLAUDE.md "Revision 2026-05-16")
  - **All installed faction packs** — SDRC enumerates prefabs from every faction pack's `Prefabs/Groups` and `Prefabs/Characters` folders. Adding a faction pack to mods[] automatically widens the bucket pool.
  - **CRX EnfusionAI** — SDRC-spawned AI gets CRX behavior overlay applied
- **Conflicts with**:
  - **DarcMissions** (`5ED0FAC84A48D018`) — per `INDEX.md`: "reads `dc-missionConfig_Chopper`; we don't use; use SHSScenarioFramework instead". Not in current stack.

## 6. Performance impact

SDRC's auto-discovery + procedural objective generation runs at scenario init (one-shot expensive) + an ongoing tick for AI intensity management + objective regeneration (cheap). Bucket enumeration is the init-cost driver: ~78 G_LIGHT entries × 76 G_HEAVY × etc. populated from 100+ active mod prefab folders. Init time has been within budget on every boot since 2026-05-13. Runtime cost is sub-CRX (CRX's per-tick perception update dominates the AI budget).

## 7. Known issues / landmines

- **`fallbackEnemyFaction` matters**: when modded factions fail prefab catalog lookup (catalog gaps, missing prefabs, etc.), SDRC falls back to this faction. Was `"FIA"` (vanilla insurgents) pre-2026-05-15; changed to `"USSR"` (vanilla Soviets) in iter3 because vanilla FIA was visually jarring and underleveled vs the modded enemy intent. Backup: `dc_coreConfig.pre-fallback-fix-2026-05-15.json`.
- **`dc_enemyList.json` / `dc_vehicleList.json` use string-include/exclude filters** — adding a new faction pack may pull unintended prefabs into a bucket if the faction's prefab name contains a matched substring. Audit by checking `script.log` for SDRC's bucket-count enumeration after adding a faction.
- **Backups exist** with `.pre-fix-2026-05-15.json` suffix on all three configs (iter3 SDRC rollback baseline). Do not delete without verifying current state is golden.
- **`DarcMods` directory naming is intentional** despite SHS being a Shadow_Haven_Studios mod — the SDRC config naming convention was inherited from the `darc` ecosystem (DarcCore / DarcChopper / DarcMissions). Confusing but stable; do not rename the directory.
- **Remote may have CRX defaults regenerated** per CLAUDE.md "Shared across local + deployed" — note that `dc_coreConfig.json` is a similar local-state file; verify the deployed file matches the local tuned values before assuming iter3 fix is applied remotely.

## 8. Extending / modding

**Adding a new bucket** (e.g., a custom `G_PARATROOPER` for parachute drops):
1. Snapshot current SDRC configs
2. Add a new bucket entry to `dc_enemyList.json` `lists[]` array
3. Define `id`, `modDir` (paths SDRC should scan for matching prefabs), `include` (substring filters), `exclude` (negation filters)
4. Restart — SDRC will populate the bucket at next init
5. The new bucket is now usable by any scenario component that references it by ID (requires scenario-side wiring; not just operator-side)

**Adding faction pack prefabs to existing buckets**: usually automatic — SDRC's `modDir` defaults scan `Prefabs/Groups`. For faction-specific paths use the GUID-prefixed form like BaconZombies does: `"622120A5448725E3/Prefabs/Groups"`.

## 9. Changelog / verified state

- **Installed version**: 1.0.22 (Workshop last modified 19.02.2026)
- **Last clean boot**: continuously loaded in 2026-05-16 V5 golden state
- **Last config change**: 2026-05-15 — `dc_coreConfig.json fallbackEnemyFaction "FIA" → "USSR"` (iter3 fix on deployed; same edit applied locally for consistency)

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/687B6840885E539D)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/687B6840885E539D/changelog)
- CLAUDE.md "State summary as of 2026-05-16" → "Shared across local + deployed" — SDRC inventory + dc_coreConfig fallbackEnemyFaction note
- CLAUDE.md "Revision 2026-05-16 (golden state V5)" — iter3 fallbackEnemyFaction change
- `INDEX.md` — `scenario:sdrc-framework`
- Sister docs: `COE2_-_Combat_Ops_Enhanced_2.md` (the scenario controller SDRC sits on top of), `BaconZombies.md` (referenced by GUID in `dc_enemyList.json`)
- Related memories: `[[golden_state_2026_05_16_v5]]`
