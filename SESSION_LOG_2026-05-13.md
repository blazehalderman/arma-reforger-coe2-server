# Session Log — 2026-05-13

> **STATUS 2026-05-14: HISTORICAL one-off log.** Captures state at end of the 2026-05-13 session when the stack was 114 mods on PVE Remixed + IPC. The 2026-05-14 session ended at 121 mods on COE2 — see memory `golden_state_2026_05_14_v4.md` for the current state.

## State at session end (03:46)

- **Server PID active** on log `logs_2026-05-13_03-35-21` (114 mods, aiLimit 3500)
- **Arsenal cache**: 608 items (verified across 8 boots)
- **Density observed this session**: 30-37 IPC groups (peak 56 earlier in session, capped by player movement)
- **Final golden snapshot**: `state_snapshots/GOLDEN_2026-05-13_*_session-end-2026-05-13/`
- **Monitors stopped**: `b5qlh1iub` (general), `bn9vgn73i` (peak watcher)

## Major accomplishments today

1. **Regression-prevention infrastructure built**:
   - `snapshot_state.ps1` + `restore_state.ps1` — labeled snapshots with optional `-Golden` flag
   - `state_snapshots/` directory now holds 9+ golden recovery points + many incremental
   - MASTER_OBJECTIVE.md "[REGRESSION PREVENTION PROTOCOL]" mandates snapshot-before-change
   - Memory: `feedback_snapshot_before_changes.md`

2. **5-section MOD EVALUATION GATE made mandatory**:
   - Every candidate mod must pass: Workshop ID + Conflict Analysis + Risk Assessment + Execution Strategy + Troubleshooting Checklist + Final Recommendation
   - MASTER_OBJECTIVE.md "[MOD EVALUATION GATE — MANDATORY]"
   - Memory: `feedback_mod_evaluation_gate.md`

3. **Launcher CWD bug fixed**: `start_server.ps1` now passes `-WorkingDirectory $ServerRoot` to `Start-Process`. Fixed the misleading `Game addon '58D0FB3206B6F859' not found` cascade that fired when running from any subdirectory.

4. **Major recovery from evening cascade**: 8+ consecutive boot failures earlier in session. Root causes identified + fixed:
   - WCS_Earplugs version pin (1.0.4 vs installed 6.0.2)
   - Over-aggressive disk cleanup deleted CapsWeaponPack + BaconSuppressors + 5 ADSSway test variants needed by PMCFaction / BWI / 3DRSFaction
   - Launcher CWD inheriting deep subdir
   - All-In-One Arsenals swap broke arsenal cache (94 vs 608)

5. **Iterated through 8 batches** restoring all today's intended additions, snapshot-between-each:
   - Batch 1: aiLimit 3500
   - Batch 2: WCS_Arsenal + sTs duo (cache restored 94 → 608)
   - Batch 3: BLE first-class re-add
   - Batch 4: WCS_Earplugs + 2 rank-override mods
   - Batch 5: PMCFaction + DarkGruMPPCamos-GRS + MisfitsClothing
   - Batch 6: 3 Misfits standalones (Vests, Belts, GhillieSuits)
   - Batch 7: 3 sister AI mods (DarcChopper + 2 mortar)
   - Batch 8: Modern Russians (`65252242719E5A1B`) at Layer 6 tail per evaluation gate

6. **Documentation refreshed**: CLAUDE.md, MASTER_OBJECTIVE.md, experiment.md, golden_state_2026_05_13_v3 memory all updated by docs agent earlier in session

7. **Memory index updated** with 4 new entries (feedback rules + reference pointers)

## OPEN ISSUE — RESOLVED + FIX STAGED before sleep

**🟢 Arsenal universal blank — ROOT CAUSE IDENTIFIED + FIX APPLIED**

Investigation agent `a28696533c1c94928` returned with smoking gun:

**`AllArsenalItemsToPrivate` (`66C751946DC58A1A`) is MISLABELED on Workshop.** Its actual `addon.gproj` declares `ID "SGCPvEConflictOverrides"` / `TITLE "SGC PvE Conflict Overrides"`. The author published a PVE Conflict arsenal-override pak (SGC's curated allow-list) under a misleading "All Arsenal Items To Private" Workshop name. The override re-filters per-box arsenal display lists to SGC's allow-list, which doesn't intersect with our RHS+WCS arsenal mods → every arsenal box renders empty even though server-side cache (`Cached 608 items`) is healthy.

Smoking-gun log line in `console.log:419`:
```
ENGINE: FileSystem: Adding package '...AllArsenalItemsToPrivate_66C751946DC58A1A/' to filesystem under name SGCPvEConflictOverrides
```

`NoRankRequirements_66D55C5BEC1BD82F` is **NOT the culprit** — it correctly registers as `NoRankRequirements` and only treats players as General rank.

**FIX APPLIED (config-only, snapshot taken)**:
- Removed `66C751946DC58A1A` from `serverConfig.json` mods[]
- Snapshot: `state_snapshots/2026-05-13_*_pre-AllArsenalItemsToPrivate-removal-MISLABELED-mod/`
- Mods 114 → 113

**Takes effect on next `start_server.ps1` restart.** You're already done for the night so the fix is staged for tomorrow's first launch.

**Verification step** when you restart tomorrow:
1. Run `start_server.ps1` (PID will change; arsenal cache should still report `608 items`)
2. Join, open any HQ arsenal box
3. Expected: full RHS/WCS item list (hundreds of weapons) instead of blank

**Bonus follow-up** (optional, separate issue): the 22 missing-prefab skips in `WCS_LoadoutEditor/audit/incidents/` are a SEPARATE issue — your saved Slot1 loadout references 3 prefab GUIDs from an unloaded mod. Cosmetic; doesn't affect blank-arsenal fix. To clear the noise, reset Slot1 in-game or delete the saved loadout file.

**Permanent record** — should add this to `feedback_no_procedural_combat.md` style memory or to the experiment.md as a new entry: "MISLABELED Workshop mod landmine — `AllArsenalItemsToPrivate` (`66C751946DC58A1A`) is actually `SGCPvEConflictOverrides`; do NOT re-add."

## Other open items

- **CIV faction count fluctuates** — by design of PVE Conflict Remixed, no config fix
- **DarcChopper / AI Mortar mods** load but don't auto-spawn — require GM placement or scenario fork (per agent finding `aa35438341c68d95f`)
- **Modern Russians** added at Layer 6 tail — confirm in-game whether USSR units now visibly carry RHS modern gear (needs operator to spawn USSR via GM)

## Next session start checklist

1. Check chat for agent `a28696533c1c94928` result on arsenal-blank issue
2. Apply that agent's recommended fix
3. Restart server, verify arsenal works
4. Take golden snapshot post-fix
5. Resume normal operation

## Recovery points (newest first)

```
GOLDEN_2026-05-13_*_session-end-2026-05-13                         <- TONIGHT (114 mods, working baseline + arsenal-blank symptom)
GOLDEN_2026-05-13_03-01-04_verified-stable-114mod-FINAL-all-batches-complete
GOLDEN_2026-05-13_02-59-16_verified-stable-113mod-batch7-sister-AI-mods
GOLDEN_2026-05-13_02-57-20_verified-stable-110mod-batch6-misfits-trio
GOLDEN_2026-05-13_02-56-11_verified-stable-107mod-batch5-PMC-DarkGruCamos-MisfitsClothing
GOLDEN_2026-05-13_02-53-22_verified-stable-104mod-batch4-earplugs-rankoverrides    <- pre-rank-mod-issue baseline
GOLDEN_2026-05-13_02-52-08_verified-stable-101mod-batch3-BLE-firstclass            <- rollback to before rank mods
GOLDEN_2026-05-13_02-43-46_verified-stable-100mod-batch2-arsenal-restored
GOLDEN_2026-05-13_02-32-25_verified-stable-97mod-baseline-post-nuke                <- post-nuclear-cleanup baseline
```

Use `restore_state.ps1 -Snapshot <name>` for instant rollback to any point.

---

Goodnight. Pick up where we left off — the arsenal blank fix should be the first thing tomorrow.
