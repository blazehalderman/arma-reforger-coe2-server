---
workshop_id: "61D57616CAFBB23D"
workshop_url: https://reforger.armaplatform.com/workshop/61D57616CAFBB23D
version: "6.0.29"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "615CC2D870A39838 # WCS_Arsenal"
related_memories: []
folder: "WCS_LoadoutEditor_61D57616CAFBB23D"
---

# WCS_LoadoutEditor

> **One-line role**: per-player personal loadout editor — saves named slots (Slot1, etc.) per player UID + faction; replaces [[BaconLoadoutEditor]] as the canonical loadout UI in this stack.

## 1. Overview

`WCS_LoadoutEditor` is the **canonical loadout editor** for this stack (MOTD steers players to prefer it over [[BaconLoadoutEditor]]). It writes per-player loadout slots into `$profile:/WCS_LoadoutEditor/loadouts/<player-UID>/<slot>` and emits skip-and-continue incident reports to `audit/incidents/` when stale prefab refs are detected on load — the **only mod in this stack** that surfaces missing-prefab failures cleanly per [[CLAUDE.md]] §"audit/incidents/*.jsonl is the missing-prefab smoking gun".

The audit pipeline is the **operator's primary diagnostic** for "why is my saved loadout coming back partly empty" — the engine itself doesn't log these; only this mod's audit subdir does.

## 2. Functionality / Features

- Per-player loadout slots (Slot1, Slot2, ...) keyed by `playerGUID + factionKey`
- Save/load loadouts via in-game UI
- Skip-and-continue loader (if a prefab GUID in a saved loadout no longer exists on disk, skip it and continue rather than crashing — graceful failure)
- `audit/incidents/YYYY-MM-DD.jsonl` — daily JSONL of skip events with full context (`incidentType: SkippedItems`, count, dump-file pointer)
- `audit/incidents/dumps/skipped/<timestamp>_<UID>_<faction>_<slot>.log` — per-incident dumps listing every missing prefab GUID with slot index
- Localization in 12+ languages

## 3. Configuration

**Config files & storage** (paths under server root):

- `profile_new/profile/WCS_LoadoutEditor/loadouts/<player-UID>/<slot>` — per-player loadout binaries. Currently observed: 2 player UIDs (`ccb8d5ae-5eb1-4393-8d93-ed43f072adb3` = AcridVaporiZe = operator; `6141e5d0-c147-46cb-b2fa-c817b019fcad` = another player). Each has a `default` slot file.
- `profile_new/profile/WCS_LoadoutEditor/audit/incidents/2026-05-12.jsonl` — daily JSONL of skip events
- `profile_new/profile/WCS_LoadoutEditor/audit/incidents/2026-05-13.jsonl` — same
- `profile_new/profile/WCS_LoadoutEditor/audit/incidents/dumps/skipped/` — 16 incident dump files (as of 2026-05-16). Operator's `Slot1` for faction `US` reproducibly logs `Skipped Items: 22` referencing PCM-era prefab GUIDs `{083483A1C5B8CA13}` (×20 — likely a magazine), `{24880E53C1ED467A}`, `{6B42F5E6DC8C7E47}`.

**Tunable keys**: none. Storage-format only.

## 4. Operator usage

**In-game**:
- Open the WCS Loadout Editor via the arsenal's "Loadout Editor" tab (or the bound keybind — engine-default, not mod-defined)
- Edit gear, weapons, attachments
- Save to a slot (Slot1 is the default-load slot; saved loadouts apply on respawn)

**Diagnostics for the operator**:
- After every session, scan `audit/incidents/*.jsonl` for `SkippedItems` events
- For each event, open the linked `dumpFile` to see which prefab GUIDs are missing
- Fix: either delete the player's stale slot (their next save will be clean) OR add the missing mod back

**Admin commands**: none specific to this mod.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content).
- **Must load before**: [[WCS_Arsenal]] (gproj reverse-dep).
- **Must load after**: base game only.
- **Conflicts with**: nothing in current stack. **Coexists with** [[BaconLoadoutEditor]] (re-added first-class 2026-05-13 because [[GRS-Apparel]] and [[sTsRHSVanillaArsenal]] hard-dep BLE via gproj) — MOTD warns players to prefer WCS_LoadoutEditor over BLE because BLE has no skip-and-continue (a stale GUID in a BLE loadout = client crash on open, per [[CLAUDE.md]] §"Known landmines" BaconLoadoutEditor row).
- **Synergies with**: [[WCS_Arsenal]] (renders loadout slots in arsenal UI).

## 6. Performance impact

Negligible. I/O is event-driven (save / load actions) — no per-tick cost.

## 7. Known issues / landmines

- **Stale loadout dump-evidence trail** (operator's `Slot1`, US faction): 22 missing PCM-era prefabs per dump, dating from 2026-05-12 to 2026-05-13. See dumps at `profile_new/profile/WCS_LoadoutEditor/audit/incidents/dumps/skipped/2026-05-1[23]_*_US_Slot1.log`. **Fix**: delete the operator's Slot1 file (`profile_new/profile/WCS_LoadoutEditor/loadouts/ccb8d5ae-5eb1-4393-8d93-ed43f072adb3/Slot1`) and resave fresh in-game. See [[CLAUDE.md]] §"State summary as of 2026-05-16" → "Known unresolved gaps" → "WCS Slot1 per-player convention exists but user's saved Slot1 .bin files have 22 dead PCM-era prefab refs".
- **Same `audit/incidents/*.jsonl` is the smoking gun** for ANY upstream mod that changes a prefab GUID — this mod's logging is shared across all WCS content. Use it as the first investigation surface for missing-prefab issues.
- **No client-crash risk** — unlike BLE, the skip-and-continue loader means a stale loadout just loses items, never crashes.

## 8. Extending / modding

_N/A_ — closed UI editor.

## 9. Changelog / verified state

- **Installed version**: 6.0.29 (Workshop current as of 2026-05-05)
- **Folder**: `WCS_LoadoutEditor_61D57616CAFBB23D`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot
- **Last audit-dump event**: 2026-05-13 (16 dumps total in skipped/)

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/61D57616CAFBB23D) — 80% rating, 1.76M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/61D57616CAFBB23D/changelog)
- [[CLAUDE.md]] §"audit/incidents/*.jsonl is the missing-prefab smoking gun" — the smoking-gun rule
- [[CLAUDE.md]] §"State summary as of 2026-05-16" — Slot1 stale-blob context
- [[CLAUDE.md]] §"Known landmines" BaconLoadoutEditor row — the contrast with BLE's no-skip-and-continue
- Companion: [[BaconLoadoutEditor]] (sibling loadout editor, BLE is less safe), [[WCS_Arsenal]]
