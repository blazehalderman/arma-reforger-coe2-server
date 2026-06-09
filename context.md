# Iteration Context Log

> **STATUS 2026-05-16: HISTORICAL.** Stack pivoted to COE2 Eden + iter3 deployed adds (117 mods). See CLAUDE.md and golden_state_2026_05_16_v5 memory for current state.
>
> **STATUS 2026-05-14: HISTORICAL.** This log covers early 2026-05 iteration around IPC scenario tuning that was abandoned. The operator's current goal is satisfied by COE2 + CRX EAI realism tuning — see `MASTER_OBJECTIVE.md` and memory `golden_state_2026_05_14_v4.md` for the current state.

Goal: Find the configuration the user remembered — "plentiful AI but standing still" on a working server. User answer (via question): IPC_DynamicCombat over vanilla CTI.

## Iteration 1 — IPC_DynamicCombat_Rework + IPCAutonomousCaptureAI + IPC Higher AI Skill + FS Tactical AI on vanilla CTI Everon
- Date/time: 2026-05-12 20:41
- Config: scenarioId `{ECC61978EDCC2B5A}Missions/23_Campaign.conf`, 86 mods
- Result: **FAIL** — engine refused init
- Cause: `SCRIPT (E): scripts/GameCode/IPC/Modded/IPC_ModdedRadio.c,48: Ambiguous function call 'RecalculateRadioRange'` — two overloads visible (`()` and `(float)`), can't disambiguate. `Can't compile "Game" script module!` → `Cannot create game!`
- Root cause hypothesis: IPC_DynamicCombat_Rework calls `RecalculateRadioRange()` no-arg expecting one definition, but base game 1.6.0.119 added the no-arg variant making both visible — so IPC's call is ambiguous.

## Iteration 2 — Removed IPC Higher AI Skill (modId 64DCE52D2F882ED2) from config
- Date/time: 2026-05-12 20:43
- Result: **FAIL** — same compile error
- Cause: Engine auto-loads addon folders even when not in serverConfig — IPCHigherAISkill folder still on disk so still loaded.
- Lesson: Removing from config alone doesn't disable a mod; must move folder out of `addons/`.

## Iteration 3 — Moved IPCHigherAISkill folder to addons_disabled/
- Date/time: 2026-05-12 20:44
- Result: **FAIL** — same compile error
- Cause: `RecalculateRadioRange(float)` overload still defined somewhere visible to IPC. IPC Higher AI Skill is NOT the source of the conflicting overload. The bug is in IPC_DynamicCombat_Rework's own code being incompatible with current Reforger 1.6.0.119 base game (which now exposes a no-arg overload too).
- Lesson: IPC_DynamicCombat_Rework is incompatible with game version 1.6.0.119 — the compile-time conflict is intra-IPC.

## Iteration 4 — Moved IPC_DynamicCombat_Rework folder out + removed from config; kept IPCAutonomousCaptureAI + FS Tactical AI
- Date/time: 2026-05-12 20:46
- PID: 43484
- Result: **SUCCESS** — boot reached GAME state
  - 20:46:43 Game successfully created
  - 20:47:02 Entered online game state
  - 20:47:04 SCR_BaseGameMode::OnGameStateChanged = GAME
- Note: Steam auto-re-downloaded IPCHigherAISkill (loaded as IPCAutonomousCaptureAI dep) — does NOT trigger compile error alone. The Rework was the sole source of the `RecalculateRadioRange` ambiguous call.
- Active mod stack now: vanilla Conflict Everon (`23_Campaign.conf`) + IPCAutonomousCaptureAI (`6550E750653AA699`) + IPCHigherAISkill (`64DCE52D2F882ED2`) + FSTacticalAISpawnManager (`68494CE78A849933`). 84 mods configured.
- Pending: user in-game verification of "lots of AI standing still" (or moving with FS overlay) signature.

### Iteration 4 Live Diagnostics (post-boot probe)
- 20:48:43+ — `Virtual Machine Exception: NULL pointer to instance. Variable '#return'` in `SCR_CampaignMilitaryBaseComponent.EvaluateDefenders` at `IPC_CampaignMilitaryBaseComponent.c:110`. Fires every ~100-300ms. 234 traces in 80s.
- Despite the exception, IPC IS spawning groups. Logged at 20:48:50:
  - US:   basic=1, withVehicle=1, patrol=1, patrolWithVehicle=2 (5 groups)
  - USSR: basic=1, withVehicle=1 (2 groups)
  - FIA:  defender=5, patrol=2, patrolWithVehicle=2 (9 groups)
- Total: ~16 IPC groups across 3 factions. Each group typically 4-6 AI = ~80 AI minimum.
- Diagnosis: IPC's `EvaluateDefenders` was written for a custom Conflict variant scenario shape; called against vanilla `SCR_CampaignMilitaryBaseComponent`, the base lookup returns NULL → no defenders assigned → spawned groups stand idle. **EXACTLY matches user's "plentiful AI but just standing still" memory.**
- FS Tactical AI Spawn Manager (`68494CE78A849933`) overlay is active in parallel — its hooks should drive AI behavior independent of IPC's broken EvaluateDefenders.

### USER CONFIRMED 2026-05-12 20:51
**"Okay great, so I think everything is working well, dont make major changes now, this is solid progress and document this configuration somewhere"**

Configuration is locked. Saved to memory as `golden_state_2026_05_12.md`. Next focus: expand AI count without breaking the working config.

## Next iteration target — AI expansion (no breaking changes)

User wants to grow the live AI population. Current ~24 groups (~120 AI) vs aiLimit 1000 = significant headroom. Options ranked by risk:

### Low risk (config-only knobs)
1. **Edit `profile_new/profile/IPC/IPC_Settings.json`** — IPC mod's runtime config. Likely contains squad allocation per faction, base defense respawn delays, max group counts. Changing values should not break loading.
2. **Add workshop mod `Conflict No Base AI Limit` (`60E547E88A9221E5`)** — pure overlay that removes vanilla Conflict's per-base AI cap. Doesn't change scenario or core mods.

### Medium risk (additional mod overlay)
3. **Add SHS Scenario Framework (`687B6840885E539D`)** alongside vanilla Conflict. SHS auto-spawns AI everywhere on the map (we tested it earlier — 100+ AI spawned in seconds). Risk: SHS overrides vanilla Conflict scenarios at certain GUIDs; might conflict with vanilla 23_Campaign.conf.

### High risk (do not without explicit ask)
4. Replace scenario with PCM Eden / SHS Everon / Conflict 2.0 PVE — all previously failed. Skip.

## Iteration 5 — IPC density 4x scale-up (USER REQUESTED)
- Date/time: 2026-05-12 20:54
- PID: 46044
- Edits to `profile_new/profile/IPC/IPC_Settings.json`:
  - All 9 squad-allocation strings quadrupled (US/USSR/FIA × PRIMARY/SECONDARY/SEIZING_PATROL)
  - `baseDefenseRespawnDelay`: 5000ms → **1500ms** (3.3x faster respawn)
  - `enemyDetectionRadius`: 500m → **800m** (1.6x further engagement)
  - `spawnSafetyRadius`: 300m → **200m** (more bases usable as spawn points)
- New squad totals (was 34):
  - US: 12+12+24 = 48 squads
  - USSR: 12+12+24 = 48 squads
  - FIA: 12+12+16 = 40 squads
  - **TOTAL: 136 squads ~ 680 AI estimate** (vs aiLimit 1000)
- Restart required. Server re-launched PID 46044, log folder `logs_2026-05-12_20-54-55`.
- Pending: user in-game verification of expanded density.

### Iteration 5 Result (verified by 21:00)
- 4x squad alloc DID NOT translate to 4x live groups. Steady at US 5 / USSR 2 / FIA 17 = 24 groups — **same as pre-scale baseline**.
- **Root cause identified:** IPC uses `IPC_PatrolSpawnPointComponent.c` and `IPC_PatrolSpawnPointWithVehicleComponent.c` — patrols spawn from physical spawn-point entities placed at each base. Defenders too (FIA `defender=6` matches 6 FIA-owned bases = 1 defender squad per base, hard cap).
- The squad alloc strings define WHAT to spawn (template variety), not HOW MANY (count is limited by base entity count).
- FS Tactical AI / Mission Maker has no profile config; behavior-only mod, no spawn density knobs.

## Iteration 6 — Squad size-up (template swap, not alloc count)
- Date/time: 2026-05-12 21:02
- PID: 44344
- Strategy: replace small templates with large ones inside the alloc strings:
  - `INF_PATROL` (2 men) → `INF_ASSAULT` (8 men) [4x AI per slot]
  - `INF_RECON` (4 men) → `INF_COMBAT` (6 men) [1.5x]
  - `INF_RECON_FIA` (3 men) → `INF_ASSAULT_FIA` (6 men) [2x]
  - `VEH_MOTOR_*` (vehicle+4 men) → `VEH_TRUCK_*` (vehicle+8 men) [2x]
- Net effect: same ~24 live groups but each group has ~7-8 men instead of ~2-4 = ~2-3x total AI on map without changing group count.
- Restart required (IPC reads alloc at init).
- Pending: user in-game verification.

## Iteration 7 — Return to SHS PvPvE Everon (USER REQUESTED)
- Date/time: 2026-05-12 21:06
- PID: 44360
- User clarified the "AI all over Everon" mod was NOT IPC — confirmed by empirical retest: IPC only spawned ~24 groups bound to base spawn-point entities, while SHS earlier showed 23+ spawn waves across the entire map in 80s.
- Config change:
  - scenarioId: `{ECC61978EDCC2B5A}Missions/23_Campaign.conf` → `{B12D0B37FF171B03}Missions/Conflict_Everon_US.conf` (SHS Everon)
  - Added SHSScenarioFramework (`687B6840885E539D`)
  - Kept IPC + FS Tactical mods (won't actively run on SHS scenario but won't break it)
- Tradeoff: lose IPC's structured base-capture war for SHS's "AI everywhere" density
- Result: SHS spawned but the user said "this is not right, the mod we ran had enemies literally all over the map at every single town and in between"

## Iteration 8 — ConflictPVERemixedVanilla2.0 Everon 4x ⭐ USER CONFIRMED ⭐
- Date/time: 2026-05-12 21:16
- PID: 42800
- Researched workshop community-standard PVE scenarios. Top hit: **ConflictPVERemixedVanilla2.0** by Gramps303 (modId `61B514B96692C049`, **525,653 downloads / 91% rating**) — the de facto community-standard PVE Conflict.
- Config change:
  - scenarioId: `{B12D0B37FF171B03}Missions/Conflict_Everon_US.conf` → `{3197BE0E6932DFAD}Missions/ConflictPVERemixedVanilla2_US4x.conf` (Everon 4x = highest-density variant)
  - Added ConflictPVERemixedVanilla2.0 mod (`61B514B96692C049`)
  - Kept IPC + SHS + FS Tactical (run in parallel, all contribute to density)
- Result: **GAME state at 21:17:15** ✓
- Live behavior:
  - PVE Remixed `!! [AC] patrol find roads` cycles 17-21 road patrols every ~30s
  - IPC dynamically grew US 3→7, FIA 7→26, CIV 0→13 over 6 min = 46 IPC groups
  - SHS spawned a 3-vehicle 30-crew FIA convoy crossing 6km
  - Total ~65-70 active groups across all 4 factions (US/USSR/FIA/CIV)
- **USER CONFIRMED 21:24:** "this is close ... Make this our new baseline and document the findings"
- Configurability answer: PVE Remixed config baked in data.pak (no profile JSON). Tweakable via in-game scenario params menu only. IPC density knobs in `profile_new/profile/IPC/IPC_Settings.json` already tuned (4x squad alloc, bigger templates, faster respawn).
- See `memory/golden_state_2026_05_12.md` for full lock-in record.


## Known landmines for this session

- Steam dedicated-download can deliver mods missing `addon.gproj`. Reconstruct from `ServerData.json` template.
- Engine auto-loads ALL folders in `profile_new/addons/` regardless of serverConfig. To disable, move the folder to `profile_new/addons_disabled/`.
- IPC_DynamicCombat_Rework (modId 68B0F1527A825B69) **broken on game v1.6.0.119** — `RecalculateRadioRange()` ambiguous call.
- Removing a mod from serverConfig requires ALSO moving its folder out of addons/ to truly disable.

## Untried high-AI candidates (next iterations if needed)

- **Conflict: Escalation revisit** — gave dense AI but spawn-protection-area filter made them passive. Matches "lots of AI standing still" but documented broken on Everon (Iron Front data mismatch).
- **PCM Eden** with random factions (params menu bug — accept fallback)
- **CO-OP Conflict PVE** (modId 62E960A6A1BA0985)
- **FS Tactical AI** alone overlaying vanilla CTI Conflict
