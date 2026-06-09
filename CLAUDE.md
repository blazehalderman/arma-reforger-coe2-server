# Arma Reforger Dedicated Server — Operator's Notes

## 📡 Standing monitor agents — spin up at session start

**Default behavior**: when the user begins a session or asks for work on this server, spawn the full monitor stack BEFORE the first response unless explicitly told to skip them. These keep both server and client log streams flowing into the conversation so we catch regressions in real time.

The standing 5-monitor stack:

| # | Purpose | Tool | Pattern / target |
|---|---|---|---|
| 1 | **Server density + cache + crash + new-mod init** (auto-rotating) | `Monitor` | tail `profile_new/logs/<newest>/script.log`; re-attach on new folder; alternation pattern: `OnGameStateChanged\|VM Exception\|FATAL\|Recursive call\|Stack trace\|COE_\|Kex\|Cached \d+ items\|Mod found:\|Unable to initialize\|Addon is blocked\|blocked dependencies` (post-COE2-pivot pattern; the `IPC Groups of Faction` and `SpawnPoint . Faction affliated` tokens from the IPC era no longer fire) |
| 2 | **Server PEAK density alert** (auto-rotating) | `Monitor` | tail script.log; alert on sustained AI tick spikes (COE2 doesn't emit per-faction group-count lines like IPC did; monitor for >95 active AI entities via aiLimit telemetry instead) |
| 3 | **Client error.log + script.log critical errors** | `Monitor` | tail the operator's client log dir (`$LOCALAPPDATA/Arma Reforger/logs/logs_*`); **TIGHT pattern only** — `VM Exception\|FATAL\|Recursive call\|Cannot create\|Game addon\|MissionHeader::\|RplConnection::ValidationError\|prefab .* missing at index\|Error when creating entity\|RESOURCES \(E\): Failed to load$`. **DO NOT include bare `Stack trace` token** — it floods at thousands per second when client hits a recurring VM exception (BLE corrupt-loadout interactions etc) and the monitor self-stops with "output rate too high". Suppress via `grep -v "^Stack trace:$"` after the main filter. |
| 4 | **Client arsenal/rank/loadout warnings** | `Monitor` | tail client script.log; pattern: `Cached \d+\|SCR_ArsenalManagerComponent\|WCS_LoadoutEditor\|BaconLoadoutEditor\|SCR_EArsenalItemType\|E_ArsenalBox_\|GunBuilderUI` |
| 5 | **Server + client crash dump file watcher** | `Monitor` | watch `profile_new/crashes/*.dmp` and `%LOCALAPPDATA%\Arma Reforger\crashes\*.dmp`; alert on new file with byte size |

**Rotation behavior**: server-side monitors must auto-rotate to new log folders (each server restart creates `logs/logs_<timestamp>/`). They print `[MONITOR] switched to <foldername>` on rotation — verified working today. Client-side monitors don't rotate per server restart — they tail one persistent client log per Reforger session.

**Re-spawning rule**: if any monitor's last event was more than 10 min old AND the relevant process is alive, the monitor died silently — relaunch it. Don't sleep-poll for monitor health; spot-check at the top of each turn.

## 🤖 Standing snapshot/cleanup agent — `snapshot_agent.ps1`

**Purpose**: take Golden snapshots automatically when the server hits stability thresholds, and prune obsolete state files so the working tree stays clean without operator intervention.

**Behavior** (every 15 min by default):
1. **Stability check**: process alive ≥20 min + arsenal cache = 608 + zero VM exceptions in last 5 min + no crash dump newer than process start → **eligible for Golden**.
2. **Golden cooldown**: don't take another Golden if one was created in the last 2 h (prevents minor-restart spam).
3. **Auto-purge old non-Golden snapshots** > 24 h old.
4. **Auto-purge Golden snapshots** beyond the 10 newest.
5. **Auto-purge root-level `serverConfig*.json` backups** not on the whitelist (only `serverConfig.json` + `serverConfig.pre-restoration-2026-05-10.json` survive).
6. Logs every action to `snapshot_agent.log`.

**Run modes**:
- One-shot pass (Task Scheduler): `powershell.exe -File snapshot_agent.ps1`
- Foreground loop: `powershell.exe -File snapshot_agent.ps1 -Loop -LoopIntervalMin 15`
- **Detached background loop (preferred): `Start-Process snapshot_agent_loop.cmd -WindowStyle Hidden`** — `start_server.ps1` step [6/6] uses this. The .cmd wrapper is mandatory because `Start-Process powershell.exe -File ... -Loop -WindowStyle Hidden` silently dies within seconds on PS 5.1 (verified 2026-05-13 multiple times). Routing through cmd.exe makes the child genuinely detached.

**Recommended install** (run once as Administrator):
```powershell
$action  = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server\snapshot_agent.ps1"'
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 15)
Register-ScheduledTask -TaskName "Reforger Snapshot Agent" -Action $action -Trigger $trigger -RunLevel Highest
```

The thresholds in the agent script are tunable knobs at the top of `snapshot_agent.ps1` (`STABILITY_THRESHOLD_MIN`, `NON_GOLDEN_RETENTION_HOURS`, `GOLDEN_RETENTION_COUNT`, `GOLDEN_COOLDOWN_HOURS`, `CONFIG_WHITELIST`).

## 🛑 CRITICAL — Mod purge safety protocol (READ FIRST)

**Reforger's mod system is dependency-aware. Never delete an addon folder without auditing its `addon.gproj Dependencies` first.** A purged folder that another active mod hard-deps will cascade-fail: the engine compiles the depper's scripts, sees the missing dep, and either silently disables it (best case: features go dark) or refuses to register the depper entirely (worst case: cascading "Cannot create game" boot failure with the misleading `Game addon '58D0FB3206B6F859' not found` symptom).

**Two pre-purge audits are MANDATORY.** Both must pass for a folder to be safe to delete:

1. **Not in `serverConfig.json mods[]`** — if it's declared as an active mod, Steam will re-download it on the next boot anyway. Remove from `mods[]` first, then audit deps.
2. **Zero hard-deps from any active mod's `addon.gproj`** — every declared mod's `addon.gproj` lists its dependency GUIDs in plaintext. The audit pattern that worked 2026-05-13:

```powershell
# For each undeclared folder in addons/, count how many declared mods' gprojs reference its GUID
$declared = (Get-Content serverConfig.json | ConvertFrom-Json).game.mods.modId
$undeclared = Get-ChildItem profile_new/addons -Directory | Where { $_.Name -match '_([A-F0-9]{16})$' -and $matches[1] -notin $declared }
foreach ($folder in $undeclared) {
    $myGuid = ($folder.Name -split '_')[-1]
    $deppers = $declared | Where {
        $depGproj = Get-Content "profile_new/addons/*_$_/addon.gproj" -Raw -ErrorAction SilentlyContinue
        $depGproj -match $myGuid
    }
    # PURGE-SAFE ONLY IF $deppers.Count -eq 0
}
```

**Example dep chains in the active stack** (do NOT purge any of these — they're hard-depped by multiple active mods):
- `BaconLoadoutEditor` ← hard-depped by `GRS-Apparel` + `sTsRHSVanillaArsenal`. Removing it kills loadout UI for those mods.
- `LeesWeaponFramework` ← `LeesUH-1Y`. Lees vehicle dep chain.
- `PR_UTILS` ← `PRMaxxpro`. PR mod family dep.
- `DarcCore` ← `DarcChopper`. Darc mod family dep.
- `RedactedCore` ← `DarkGruMPPCamos-GRS`. GRS dep chain.
- `BaconSuppressors` + `CapsWeaponPack` + `MisfitsGearCryeG4` + `MisfitsSquadGear` ← all transitively pulled by `PMCFaction`. Removing any one breaks PMC loadouts.

**The "folder-presence triggers scripts even without declaration" landmine** (proven by the IPCHigherAISkill crash 2026-05-13 13:34) is the WHY: just removing a mod from `serverConfig.json mods[]` does NOT stop its scripts from compiling. Engine scans every folder in `addons/` and compiles `addon.gproj` scripts regardless of declaration. The `mods[]` array controls Steam updates and client CRC validation, not script execution. **Folder removal is the only durable disable.**

**The "delete locked pak destroys the mod" landmine** (proven by GRS apparel reconstruction 2026-05-12): `Remove-Item` on a folder whose `data.pak` is held open by the running server process will leave the locked pak orphaned and remove only the manifest stubs — clients will then fail `RplConnection::ValidationError remote script source code checksum does not match!`. **Always kill the server and wait 3-5 seconds for handle release before any folder operation.**

### Safe purge procedure (memorize this)

1. `snapshot_state.ps1 -Label "pre-purge-<modname>"` — atomic rollback baseline.
2. Run the audit above. If `$deppers.Count -gt 0`, **STOP** and identify the depper chain. Either purge it bottom-up (purge the leaf depper first) or accept the folder stays.
3. `Get-Process ArmaReforgerServer | Stop-Process -Force; Start-Sleep 5` — release pak file handles.
4. `Remove-Item profile_new/addons/<folder> -Recurse -Force`.
5. Restart and verify `OnGameStateChanged = GAME` + arsenal cache count unchanged.
6. If boot fails, `restore_state.ps1 -Snapshot pre-purge-<modname>` recovers in seconds.

This protocol is integral to maintaining a healthy Reforger modded server. The cost of skipping the dep audit is hours of debugging mysterious load failures.

## What this is

A modded Arma Reforger v1.6.0.119 dedicated server running **111 explicit mods** (golden state 2026-05-14). **Active scenario: Combat Ops Enhanced 2 (COE2) on Eden**, scenario ID `{EE676FAB9DFA4CF7}Missions/COE2_Eden.conf`. The scenario stack is:

- **Kex Scenario Core** (`5ED61DC0AFE17E8E`) — framework that COE2 builds on
- **COE2 (Combat Ops Enhanced 2)** (`60926835F4A7B0CA`) — Kex's runtime-flexible PvE scenario with string-key faction picker, supports all installed faction packs as configurable enemies
- **CRX Enfusion AI** (`5F268647F8A1A1F4`) — behavioral overlay (sound reaction, flanking, fireteam splits, perception tuning). PCM-style behavior without PCM.
- **ACE Core Dev + ACE Captives Dev** (`65AD7D0D9941A380`, `65AD7C249E4ECDFB`) — minimal ACE Dev pair paired with COE2 (replaced the full stable ACE stack in the 2026-05-13 COE2 pivot)

The realism stack is **RHS Status Quo + WCS + ACE Dev + AttachmentFramework**. **No persistence layer** — player state and scenario parameters are in-memory only and reset on server restart (see "Persistence" below).

**DO NOT recommend or re-add**:
- **Procedural Combat** (PCM 180s submit-RPC bug — abandoned 2026-05-12)
- **PVE Conflict Remixed Vanilla 2.0 + IPC AutonomousCaptureAI + LinearConflictPVE + PVEConflictwithRHSandWCS** stack — replaced by COE2 in 2026-05-13 pivot (COE2 delivers configurable-faction AI battles without IPC's hardcoded 4-faction enum limit; see [[landmine-ipc-ignores-modded-enum-scr-ecampaignfaction]] memory)
- **PMCFaction + Misfits chain** — blocked at Workshop 2026-05-14 (Bohemia takedown)
- **3DRSMODERNRUSSIANSFACTION** — removed in earlier session
- **The legacy `addons_disabled/` folder** — abandoned 2026-05-13; folder-presence triggers script execution regardless of declaration, so blacklisted mods must be DELETED not moved

The server is hosted on a Windows machine. Public address `76.235.218.202:2001`, LAN `192.168.0.x:2001`, A2S query `0.0.0.0:17777`. BattlEye off, PC-only, crossplay off.

## File map

| Path | Role |
|---|---|
| `serverConfig.json` | **Live config** the engine reads. Edit this to change scenario, mods, ports, name. Updated 2026-05-14: COE2_Eden scenario, 121 mods, 12-layer ordered. |
| `serverConfig.pre-restoration-2026-05-10.json` | **Known-good baseline.** Do not modify. Recovery snapshot. |
| `start_server.ps1` | Launcher. Kills existing process, validates config, starts server, probes AI activity, runs mod_health_check after GAME state. Blacklist (`$DisabledModFolderPrefixes`) is empty as of 2026-05-13 per operator decision — purge-on-launch deferred to manual cleanup. |
| `analyze_logs.ps1` | Log summarizer invoked by the launcher; categorizes errors by class. |
| `mod_health_check.ps1` | Post-boot validator: declared-vs-folder count, arsenal cache count, GAME state reached, VM exception count. |
| `snapshot_state.ps1` / `restore_state.ps1` | Atomic snapshot + rollback of all configs (serverConfig.json + profile/* JSONs). Run before any config change per operator-mandated protocol. |
| `snapshot_agent.ps1` + `snapshot_agent_loop.cmd` | Background loop (15-min cadence): auto-Golden snapshots when stable, prunes old non-Golden snapshots, prunes orphan backup configs. |
| `last_session_errors.txt` / `last_session_errors_raw.txt` | Output of analyze_logs.ps1. Regenerated each launch. |
| `profile_new/` | Working server profile (addons, logs, configs). |
| `profile_new/addons/` | Active mods (downloaded by Steam). |
| `profile_new/logs/logs_<timestamp>/` | One log folder per server boot. Contains `console.log`, `script.log`, `error.log`. |
| `profile_new/profile/ServerAdminTools_Config.json` | Admin list, MOTD/serverMessage, ban list, scheduled chat. Updated 2026-05-14 to COE2 stack. |
| `profile_new/profile/CRX_EAI/CRX_EAI*.txt` | CRX AI behavior config (Character / Group / Experimental). Realism-tuned 2026-05-14: Perception_Modifier=0.0, Aim_Accuracy_Error_Modifier=0.8, Flee_Chance=20, Attack_Reaction_Delay_Modifier=800, Formation_Scale=2.0, Combat_Mode=2 (GREEN defensive). |
| `profile_new/profile/GRS_ATAK/server_config.json` | ATAK (situational awareness) system config. Well-tuned, leave alone. |
| `profile_new/profile/.save/playersave/` | Engine player-profile sync files (`PlayerData.<uuid>.json`, ~200 B each). Vanilla engine — not a save game. Safe to wipe. |
| `state_snapshots/` | Snapshot history. Snapshot-agent retains 10 newest Goldens + non-Goldens <24h. |
| `MASTER_OBJECTIVE.md` | **Canonical 12-layer load order + golden state spec.** Single source of truth for the stack architecture. Read this for the per-layer mod assignments. |
| `WORKBENCH_BRIDGE_MOD_PLAN.md` | Living plan for a future Workbench-built faction bridge mod. Now lower-priority since COE2 delivers configurable factions out of the box. |
| ~~`profile_new/profile/IPC/`~~ | **Stale.** IPC AutonomousCaptureAI removed in COE2 pivot. Config files remain on disk but are inert (no IPC mod loaded). Safe to delete. |
| ~~`profile_new/profile/LinearConflictPVEConfig/`~~ | **Stale.** LinearConflictPVE removed in COE2 pivot. Config files inert. Safe to delete. |
| ~~`profile_new/addons_disabled/`~~ | **Abandoned 2026-05-13.** Folder-presence triggers script compilation regardless of declaration. Blacklisted mods must be DELETED, not moved. |

## Mod stack architecture (load order layers)

**Canonical 12-layer scheme lives in `MASTER_OBJECTIVE.md`** (golden state 2026-05-14 revision). The serverConfig.json `mods[]` array is ordered Layer 0 → Layer 11 top-to-bottom for human readability + tiebreaker resolution of symbol overrides (per BI Feedback Tracker T165829: array order is partly authoritative when gproj deps are satisfied).

**Quick reference (full table + per-mod assignments in MASTER_OBJECTIVE.md)**:
- **L0** Engine/utility frameworks (SpaceCore, AKI_Core, AUS_CORE, MFDFramework, AFWCore, AttachmentFramework, LeesWeaponFramework, RayziUtils, GRS-DevFramework, ZeliksCharacter, PR_UTILS, DarcCore, RedactedCore, TacticalAnimationOverhaul) — 14 mods
- **L1** Realism cores (RHS Content 01/02 → RHS_Status_Quo, WCS_Core, WCS_Weapon_Scripts)
- **L2** ACE Dev pair (ACE Core Dev → ACE Captives Dev — Dev branch only; stable ACE removed in COE2 pivot)
- **L3** WCS content (NATO/RU before Weapons; Clothing_Assets MUST precede Clothing per DAG fix)
- **L4** RHS↔WCS bridge (WCS_RHS_Weapons)
- **L5** Sway/aiming chain (AimingDeadzone → ADSSway-Core → ADSSway-RHS chain). **BWI 2.8 + bridge MOVED to L10** per author's "load last" Workshop instruction (2026-05-14 research-validated)
- **L6** Faction packs (DarkGruFactions, Arma2Factions only — PMC chain and Misfits blocked 2026-05-14)
- **L7** Apparel/loadouts (GRS-Patches MUST precede GRS-Apparel per DAG fix; BaconLoadoutEditor)
- **L8** Vehicle/weapon content packs (36 mods — aircraft, ground vehicles, projectile/weapon packs)
- **L9** AI overlays + sister AI mods (CRX_EnfusionAI, DarcChopper, AIMortarFireSupportSystem, NoRankRequirements). IPC chain removed in COE2 pivot
- **L10** GM/admin/QoL/audio-visual overlays + BWI 2.8 override layer
- **L11** Scenario controllers LAST (Kex Scenario Core → COE2 — Workshop deps verified)

**Order-matters evidence (2026-05-14 research)**: BI bug T165829 (still open in 2026) admits client/server can load mods in different order. BWI 2.8 author Workshop note explicitly says "for servers mods order - last". Engine builds DAG from gproj deps, then mods[] array order is the **tiebreaker for symbol overrides** (entity prefabs, params). Wrong order with satisfied deps → silent mis-overrides (bridge bridging wrong layer). Wrong order with unsatisfied deps → boot failure cascade.

**DAG fixes** (mods that must precede other mods within their layer even though gproj doesn't declare it):
1. WCS_Clothing_Assets MUST precede WCS_Clothing (DAG fix 2026-05-13)
2. GRS-Patches MUST precede GRS-Apparel (DAG fix 2026-05-13)
3. ConflictPVERemixedVanilla2.0 → LinearConflictPVE → PVEConflictwithRHSandWCS bridge (DAG fix 2026-05-13 — no longer applicable post-COE2-pivot)
4. AimingDeadzone MUST precede ADSSway-Core (gproj-verified 2026-05-14)
5. RayziUtils MUST precede ADSSway-Core (gproj-verified 2026-05-14)
6. ADSSway-Core → ADSSway-RHS → BWI-ADSsway-RHS-TAOcompat (bridge chain)
7. BWI 2.8 should load LAST among weapon-handling overlays (author Workshop instruction 2026-05-14)
8. Kex Scenario Core MUST precede COE2 (Workshop deps verified 2026-05-14)

## Abandoned: IPC Proxy War via IPC_SoldierList.json (2026-05-13)

> **HISTORICAL — IPC removed in COE2 pivot 2026-05-13.** Section retained as anti-regression reference; the entire IPC stack is no longer in the mod list. Do not reinstate IPC AutonomousCaptureAI for any reason — COE2's runtime string-key faction picker delivers the same outcome without IPC's hardcoded 4-faction enum limit.

A shortcut was tested to avoid the Workbench bridge mod work: edit `profile_new/profile/IPC/IPC_SoldierList.json` to swap WCS_RU prefabs into the FIA bucket → IPC commands FIA but spawns Russian-looking enemies. **Confirmed dead end**, do not retry.

Reasons:
1. **WCS_RU is weapons-only**, no character prefabs — `addon.gproj` deps are only base game + WCS_Attachments + WCS_Scopes + WCS_Sounds. The mod doesn't ship characters to use as proxies. Same for WCS_NATO.
2. **IPC has its own auto-discovery of OPFOR character prefabs** — booted server's script.log enumerates 98+ USSR_Army prefabs from folder scan (Spetsnaz/Naval_Infantry/KLMK), most never declared in `IPC_SoldierList.json`. The JSON is a supplement/override, not the canonical source of truth.
3. **Even minimal-change test (8 vanilla USSR_Army prefabs into FIA bucket) crashed boot silently** at IPC's prefab enumeration phase (~index [98]). No `Cached 608 items`, no `OnGameStateChanged = GAME`, no crash dump — process exited. IPC's init has unsafe assumptions about FIA bucket contents.
4. **Active scenario's FIA defenders come from the scenario's own SCR_Faction registration**, not IPC_SoldierList.json. Even if the JSON edit had booted, it would only have controlled IPC-spawned reinforcements, not base-game FIA defender prefabs.

**Path forward unchanged**: build Workbench bridge mod from `BohemiaInteractive/Arma-Reforger-Samples/SampleMod_NewFaction` per `WORKBENCH_BRIDGE_MOD_PLAN.md`. Recovery from the failed experiment was clean via `restore_state.ps1 -Snapshot pre-IPC-proxy-war-exploration`.

## Why Procedural Combat was abandoned (2026-05-12)

Documented here to prevent any future agent/operator from reinstating it.

1. **Deterministic 180-second submit-RPC bug**: PCM's params menu opens, operator picks factions, server polls for the response with a 180 s wall-clock deadline. The client's submit RPC never reached the server in 6+ verified sessions on this operator's setup — every gap was `3:00.000 ± a few ms`. Random faction fallback always fired. Bug was never reproduced upstream and the upstream menu has no per-server diagnostics.
2. **PCFactionZombies map-scope mismatch**: ZOMBIES faction is registered against Arland only, but the rotation included Eden. Picking ZOMBIES on Eden silently invalidated both side flags → CDF vs FIA fallback. The mod is designed this way; not a bug we could fix.
3. **No per-round faction randomization** in PCM 1.32.0 — operator wanted faction variety between rounds; PCM cannot deliver it.
4. **The scenario stack we settled on (PVE Remixed + IPC + LCP + CRX EAI) delivers more density than PCM did** — verified peak 108+ active IPC groups on the new stack vs PCM's typical 40-60. See `golden_state_2026_05_12_v2.md` memory.

**Therefore: do not propose Procedural Combat / Procedural Combat - Modern / PCFactionZombies / ScenarioReloadMenu / ProceduralCombatRHS as a fix or feature for any future request.** They are abandoned by operator decision. The PCM-related faction packs (DarkGruFactions, 3DRS, Arma2Factions, PMCFaction) STAY in the modlist because they provide unit prefabs that other content depends on and they're independent of the scenario controller.

## Persistence — removed 2026-05-11

**This stack has no persistence layer.** Player state and scenario parameters live in memory and reset on every server restart.

EPF + EDF + RHSEPFpersistence were in the mod list briefly but were removed 2026-05-11. Boot test showed they load cleanly but never fire because the active scenario does not call into `SCR_PersistenceManager`. Operator's call: not worth the boot-time weight and config complexity for zero persistence, plus EPF "breaks everything" in this operator's prior experience. **Do not re-add EPF/EDF/RHSEPFpersistence without first having a scenario-side integration mod that wires player entities into the persistence manager.**

**`operating.playerSaveTime: 120`** in `serverConfig.json` is the *engine's* player-profile sync interval (writes `.save/playersave/PlayerData.<uuid>.json`, ~200 bytes of vanilla profile state). It is unrelated to EPF and harmless — leave as is.

## Active scenario behavior — COE2 Eden (Combat Ops Enhanced 2 by Kex)

- **Player faction**: configurable at scenario start via COE2's faction picker (typically US/BLUFOR).
- **AI enemy faction**: configurable via COE2 string-key faction picker (any installed faction pack works — DarkGruFactions, Arma2Factions's CHDKZ/CDF/NAPA/TKM, etc.). This is COE2's marquee feature vs the previous IPC-locked stack.
- **Ambient**: CIV (per Eden map default).
- **AI ticking**: COE2 spawns enemy presence at objectives + uses CRX EAI as the behavioral overlay (sound reaction, flanking, fireteam splits, perception). CRX EAI tuning lives in `profile_new/profile/CRX_EAI/CRX_EAI*.txt`.
- **Density**: `aiLimit 3500` in serverConfig allows 100+ active AI groups; COE2 scales engagement intensity to player count + objective progress.
- **Manual GM tools available**: DarcChopper (heli CAS), AIMortarFireSupportSystem (mortar IDF) — fired manually via Game Master, not auto-spawned.

### Historical note (PRE-2026-05-13 stack — superseded)
The previous stack used **PVE Conflict Remixed Vanilla 2.0 (`{3197BE0E6932DFAD}`)** + IPC AutonomousCaptureAI + LinearConflictPVE + PVEConflictwithRHSandWCS bridge. That stack was abandoned because IPC has only 4 hardcoded enum slots for factions (BLUFOR/OPFOR/INDFOR/CIVILIAN) and could not be extended without a Workbench mod fork (see [[landmine-ipc-ignores-modded-enum-scr-ecampaignfaction]] memory). COE2's runtime string-key faction lookup eliminates this restriction. Old per-faction quirks ("US4x" filename meant 4× FIA density not 4× US bases; IPC USSR always logged 0 because USSR wasn't registered) are no longer relevant.

## Admin

- `passwordAdmin: admin123` in serverConfig.json. **Weak password, exposed in serverMessage MOTD by operator's explicit choice.** If you change the password, also update `ServerAdminTools_Config.json` `serverMessage` field (rewritten 2026-05-14 to COE2 stack). For deployment to a public host, change this BEFORE going live.
- **Auto-admin via ServerAdminTools**: schema is `{"<uuid>": "<nickname>"}`. Operator UID `ccb8d5ae-5eb1-4393-8d93-ed43f072adb3` (nickname `AcridVaporiZe`) goes in the admins object. Currently empty in MOTD config because operator uses manual login. Always write `ServerAdminTools_Config.json` as UTF-8 no-BOM (`[System.IO.File]::WriteAllText` with `New-Object System.Text.UTF8Encoding $false`) — BOM causes the mod to dump a `KeyReadError` cascade and overwrite the file with defaults, losing all customizations.
- **Manual fallback**: `#login admin123` in chat.
- **Known recursion risk**: older versions of ServerAdminTools threw `Recursive call of Invoke!` when auto-promoting admins on join. If the server crashes shortly after the operator connects with that error in `error.log`, revert the admins object to `{}` and use the manual login.

## Known landmines — keep these disabled

| Mod | Why disabled |
|---|---|
| `DoorBreaching` (627D0C6AE5F771FB) | See-through doors via missing `TransparentMat.emat`. |
| `BreachableDoors` (646B350F36C6D3E4) | Same. |
| `FoliageCollision` (655C4558B6ED57B2) | VM exception spam. |
| `WCS_VehicleLock` (61BA4EB5C886D396) | Breaks vehicle occupancy — only one player can enter. |
| `ProceduralCombatRHS` (68776D13266976ED) | Previously broken with PCM stack. PCM is now removed; this is irrelevant going forward but keep disabled in case Steam re-downloads. |
| `IPC_DynamicCombat_Rework` (68B0F1527A825B69) | `RecalculateRadioRange` ambiguous compile error on 1.6.0.119. |
| `IPCHigherAISkill` (64DCE52D2F882ED2) — **folder-moved 2026-05-13 14:09** | Hardcodes skill 70-100 + perception 1.5-2.0 → "across the map laser AI". Replaced by CRX EAI 2026-05-12. **CAUSED A SERVER CRASH 2026-05-13 13:34** despite being "removed from `serverConfig.json`" since 2026-05-12. Root cause: removing from `mods[]` only stops Steam updates and CRC validation — the engine compiles and executes any `addon.gproj`'s scripts whose folder is in `addons/` regardless of declaration (same folder-presence landmine as BaconLoadoutEditor). This mod's `Modded_SCR_CharacterPerceivableComponent.c:67 ForceSetPerceivedFaction` has a NULL-`targetFaction` deref. CRX EAI's `OnUpdate` calls into perception every tick → at high density (50+ IPC groups) the exception cascaded into a navmesh `Agent requires automatic orientation` storm in `error.log` (536 errors in 3 min) → engine froze → 4.1 MB crash dump. **Fix that actually worked: `Move-Item profile_new/addons/IPCHigherAISkill_64DCE52D2F882ED2 profile_new/addons_disabled/`**. Iteration 1 measurement: Agent-orientation errors went 24/min → 0/min. **The `start_server.ps1` enforced-disabled-list NEEDS this GUID added** so future Steam re-downloads get auto-moved. |
| `Realistic Combat Drones` | Soft-lock in camera view on custom factions like ION. |
| **BaconLoadoutEditor** (606B100247F5C709) — **re-added as first-class 2026-05-13** | Two mods (GRS-Apparel, sTsRHSVanillaArsenal) hard-dep BLE via `addon.gproj`, so removing it from `serverConfig.json` `mods[]` was a half-measure: folder-presence triggers script compile + execution regardless of modlist declaration. Now declared first-class. **Corrupt loadout-blob risk**: `profile_new/profile/BaconLoadoutEditor_Loadouts/1.6.0/US/cc/<UID>` and `1.6.0/admin_loadouts` from PCM-era reference 22 prefabs that no longer exist on disk (e.g. `{083483A1C5B8CA13}` SCAR-H mag, `{24880E53C1ED467A}` SCAR-H, `{6B42F5E6DC8C7E47}` M18 grenade attachment). BLE's loader has no skip-and-continue → null deref → client crash on open. **Fix**: delete the storage files; BLE re-inits empty. MOTD still warns to prefer WCS Loadout Editor. |
| `HFS_Configs` (65351DA1585DF3BF) — **TESTED + ROLLED BACK 2026-05-17** | APL-ND helicopter-config overhaul built for the **Heli Flight School private server**. Tested as a fix for the WCS heli → RHS_AFRF faction binding gap (categorized GM panel spawning Tigr instead of helis). On install, surfaced two visible regressions: (1) **placeholder vehicle icons** across a broad swath of GM entities — HFS's modified prefabs reference icon paths/GUIDs that don't resolve against this stack's other mods; (2) **wrong-helicopter routing** — click Mi-24V in GM, spawn KA-52 (or other wrong heli) — HFS's prefab rewrites reshuffle the GM/EntityCatalog ordering and break the click→spawn mapping. Root cause: HFS's prefab conventions match their private-server stack but not this mixed RHS+WCS+COE2 environment; the rewrites win the "last loaded wins" race per silent-override-collision pattern. **Fix**: removed from `serverConfig.json` + deleted `profile_new/addons/HFS_Configs_65351DA1585DF3BF`. **For the underlying AFRF heli faction binding gap**: F1 entity browser bypass is the immediate workaround; long-term fix is a Workbench bridge mod extending RHS_AFRF EntityCatalog with WCS heli GUIDs (4-8h, follows `bridge_mod_v103` precedent + `BohemiaInteractive/Arma-Reforger-Samples/SampleMod_NewFaction` template). |

`start_server.ps1` enforces the disabled list — it **deletes** these folders from `addons/` on every launch (policy changed 2026-05-13 after IPCHigherAISkill incident proved that moving to `addons_disabled/` did NOT stop script execution). The legacy `profile_new/addons_disabled/` directory was purged.

**⚠️ Steam still re-downloads previously-known mods** even when they're not declared in `mods[]`. Verified 2026-05-13: between iter2 and the 14:39 health check, Steam re-pulled `IPCHigherAISkill`, `MisfitsSquadBackpacks`, `RISLaserAttachments`, `Zagoria89BMP2` — none declared, all came back via Steam's addon cache. Mitigation: the launcher's purge-on-launch step runs BEFORE the engine starts, so even if Steam re-pulls between sessions, the next boot will purge again before the engine compiles those scripts. **The system is self-healing as long as the launcher script is kept up to date with the blacklist.** Run `mod_health_check.ps1` anytime to detect new orphans and add them to the launcher's `$DisabledModFolderPrefixes` array.

## Network

- `bindAddress: 0.0.0.0`, `bindPort: 2001`
- `publicAddress: 76.235.218.202`, `publicPort: 2001` (operator's WAN)
- A2S query on `0.0.0.0:17777`
- Lobby auth via Steam — earlier `InvalidSessionTicket` errors were tied to publicAddress / NAT loopback issues, currently resolved.
- `disableCrashReporter: true` — kills the "failed to initialize https" red herring at the end of crash logs.

## Self-healing log investigation playbook

When the server misbehaves (hang, crash, scenario goes wrong, low AI density, player can't admin, anything weird) — follow this routine instead of guessing. Be **efficient in process** (no wasted tool calls; parallelize; one good regex beats five bad ones) but **thorough in analysis** (don't stop at the first hypothesis that fits; find the smoking-gun line before declaring a cause). Treat every claim as "show me the log line" — no log line, no claim.

### Phase 1 — Snapshot the failure boundary (single parallel turn)

Batch these calls together in one message:

- **Process state**: `Get-Process -Name ArmaReforgerServer` → PID, `StartTime`, `CPU`, `WorkingSet64`. If CPU is climbing, it's working; if frozen at the same value across two snapshots 30 s apart, it's deadlocked. If process is gone, it crashed — read crash dump / last lines of every log.
- **Newest log folder**: `Get-ChildItem profile_new\logs -Directory | Sort LastWriteTime -Descending | Select -First 1`. Anchor your investigation to this folder unless the user names a different one.
- **Line counts** for `script.log`, `error.log`, `console.log` in that folder. Re-check 30 s later to verify whether logs are growing (server alive + emitting) or frozen (deadlock).
- **Tail script.log -20**, **tail error.log -20**, and **tail console.log -10**. These tell you the last thing the server did. A stack trace at the tail of script.log means the engine just raised a VM Exception.

### Phase 2 — Build the event timeline (targeted greps, parallelizable)

Don't read whole log files. Grep for landmarks and assemble a chronology. Each grep is one call; run all in parallel:

| Phase of life | Pattern in `script.log` (case-insensitive) |
|---|---|
| Engine boot / mod load | `gproj:` in `console.log` (not script.log) |
| Script compile | `Module:.*loaded.*classes`, `Compiling .* scripts` |
| Game-mode online | `OnGameStateChanged = GAME` |
| Player joins | `Player joined.*identityId:` |
| Player promotes to admin | `DoSetPlayerAdmin`, `OnPlayerRoleChange` |
| Player spawns | `OnPlayerSpawned\(playerId=` |
| IPC group counts (per-faction tick) | `IPC Groups of Faction <X>,` |
| IPC spawn-point affiliation | `\[AC\] SpawnPoint . Faction affliated <X>` (note typo "affliated") |
| LCP objective add/remove | `LCP.*objective` |
| Failure markers | `SCRIPT \(E\)`, `VM Exception`, `FATAL`, `Recursive call of Invoke`, `Stack trace:` |

Output a chronological table (`timestamp | source | event`). The gaps between consecutive events are the diagnostic gold — a 5-min gap with no log emission means *something is hanging*, and the line right before the gap names what.

### Phase 3 — Generate competing hypotheses

For the anomaly in question, write 3+ plausible root causes. **Each hypothesis must come with**:
1. A specific log line that supports it (quoted, with line number).
2. A specific log line that, if it existed, would *disconfirm* it (and you must grep for that line — don't just assume it's absent).
3. A fix scope: config edit / mod removal / mod replace / known-mod-bug-no-local-fix / wait-for-upstream.

Resist the temptation to stop after the first plausible match. The second-best hypothesis often has evidence that makes it actually best.

### Phase 4 — Discriminate

For each pair of competing hypotheses, identify one log line, config field, file mtime, or process state that distinguishes them. Run only the tool that produces that artifact. Eliminate hypotheses with disconfirming evidence. Keep going until one remains.

If the on-disk + log evidence is insufficient to discriminate, then — and only then — escalate to **web research**:
- Mod's workshop page (`https://reforger.armaplatform.com/workshop/<GUID>`) and its `/changelog` sub-page
- Mod author Discord links (search the Workshop description)
- Bohemia forums (`forums.bohemia.net`)
- `armareforger.xyz` config-tool entries for cross-reference
- Steam Community discussions for the base game

Quote what you find with a hyperlink.

### Phase 5 — Pinpoint and fix

State the cause as: "`<symptom>` happens because `<mechanism>` at `<file>:<line>` / `<log line>`. Fix is `<minimum change>`." If the fix is destructive (delete files, revert config keys, disable mods that the operator explicitly enabled, kill running processes), **back up first** and **tell the operator before doing it** if CLAUDE.md or the original task instructions named that as a confirmation gate.

### Phase 6 — Validate the fix

Restart server, run Phase 1, then *targeted* re-check of the exact log line that previously appeared on failure. Absence is the proof. Don't declare success on "no errors observed" without checking *for the specific failure line*.

### Monitoring stance during long boots / in-game tests

Use the `Monitor` tool with **one alternation pattern** that matches **both** progress markers AND failure markers — silence-on-crash should not masquerade as silence-on-progress. Good template for the current scenario stack:

```
OnGameStateChanged|VM Exception|FATAL|Recursive call|Stack trace|IPC Groups of Faction|SpawnPoint . Faction affliated|DoSetPlayerAdmin
```

Persistent monitor for session-length watches; one-shot `Bash run_in_background` with an `until grep -q` for "tell me when X is ready." Never sleep-poll.

### Hard rules
1. No claim without a quoted log line.
2. No re-reading the same file twice in one turn.
3. No "probably" in a root-cause statement — either evidence pins it or the hypothesis isn't ready.
4. Parallel tools when independent. Sequential only when one output gates the next.
5. Don't auto-fix anything CLAUDE.md or task instructions named as a confirmation gate.
6. Update CLAUDE.md when you discover a new landmine, fix, or behavior that future-Claude will need.

## Landmines discovered 2026-05-18

### COE2 kill→exfil cascade — `KSC_CountdownAreaTriggerTask` Recursive Invoke

A second COE2-side recurring fault, sibling to (but distinct from) the `~COE_AO #return` destructor crash. Caught in `RecentErrorLogs18052026/crash.log` event #2 at 2026-05-18 23:01:34 UTC:

```
SCRIPT (E): Virtual Machine Exception
Reason: ScriptInvoker: Recursive call of Invoke!
Class:      'KSC_CountdownAreaTriggerTask'
Entity id:  4611686018427416738
Function:   'Invoke'
Stack trace:
Scripts/Game/Components/Damage/SCR_CharacterDamageManagerComponent.c:1992 Function OnDamageStateChanged
scripts/GameCode/Components/SCR_DamageManagerComponent.c:1254             Function OnDamageStateChanged
Scripts/Game/KSC/Tasks/KSC_KillTask.c:49                                  Function OnObjectDamage
Scripts/Game/Tasks/SCR_TaskSystem.c:825                                   Function SetTaskState
Scripts/Game/KSC/Tasks/KSC_BaseTask.c:50                                  Function SetTaskState
Scripts/Game/Tasks/SCR_Task.c:785                                         Function SetTaskState
Scripts/Game/Tasks/SCR_Task.c:807                                         Function Rpc_SetTaskState
Scripts/Game/COE/Entities/COE_AO.c:970                                    Function OnTaskStateChanged
Scripts/Game/COE/GameMode/COE_GameMode.c:864                              Function OnAOFinished
Scripts/Game/COE/GameMode/COE_GameMode.c:609                              Function CreateExfilTask
Scripts/Game/KSC/Tasks/KSC_AreaTriggerTask.c:26                           Function SetParams#3506599
Scripts/Game/KSC/Tasks/KSC_BaseTask.c:43                                  Function SetParams
Scripts/Game/KSC/Tasks/KSC_BaseTask.c:50                                  Function SetTaskState
Scripts/Game/Tasks/SCR_Task.c:785                                         Function SetTaskState
Scripts/Game/Tasks/SCR_Task.c:807                                         Function Rpc_SetTaskState   ← RECURSES into the same Invoke
```

**Mechanism**: when an AO's `KSC_KillTask` completes via a kill, `COE_GameMode.OnAOFinished:864` calls `CreateExfilTask:609` **synchronously inside** the still-executing `Rpc_SetTaskState` for the kill task. The exfil's `KSC_AreaTriggerTask.SetParams:26` then calls `SetTaskState` → `Rpc_SetTaskState:807` again, re-entering `ScriptInvoker.Invoke` on the SAME invoker. Engine refuses.

**Distinct from `~COE_AO #return`**: that one is at `COE_AO.c:1055` (destructor); this one is at `COE_AO.c:970` (task callback) + `COE_GameMode.c:609/864`. Same mod (COE2 `60926835F4A7B0CA`), same author (Kex), different code path.

**Non-fatal on its own**: `-nothrow` keeps the server alive after this exception. In the 18.05 incident the server ran another 1 h 17 min before dying from a separate unhandled-native-exception (see next entry).

**No local fix.** Only Kex can patch. Workaround: report to Kex via Workshop / Kex Discord with this stack trace.

### Mass-paratroop insertion → unhandled native crash (no script stack)

Caught as event #4 in `RecentErrorLogs18052026/crash.log` at 2026-05-19 00:18:04 UTC. Script-side dies silently:

```
00:17:24.618  Math.RandomFloat: invalid parameters min=0.000000 max=0.000000        ← degenerate
              Math.RandomFloat: invalid parameters min=0.004375 max=-0.004375       ← inverted
              Math.RandomFloat: invalid parameters min=0.087500 max=-0.087500       ← inverted
              Math.RandomFloat: invalid parameters min=0.000000 max=0.000000
              Math.RandomFloat: invalid parameters min=1.000000 max=-1.000000       ← inverted
00:17:28.214  SCRIPT (W): Trying to allocate same compartment twice!
00:17:47.157  SCRIPT    : Weapon is already equipped!
00:18:04.036  ENGINE (E): Application crashed! Generated memory dump: /tmp/17ddf2ad-08e0-4c07-e59e5e8c-8a2e156e.dmp
```

**Storyboard**: 96× `SCR_AIVehicleUsageComponent not found on entity: KSC_Parachute<…>` errors in `error.log` show a mass paratrooper drop (sequential entity IDs, all at `(~4600–5400, 125–135, 10840–10890)` descending to ground 19–52m). `KSC_Parachute.et` prefab ships without `SCR_AIVehicleUsageComponent`, so for each parachute the AI subsystem hits a code path that reads zero/inverted floats and calls `RandomFloat` with degenerate ranges, then races on `SCR_BaseCompartmentManagerComponent` allocation. Engine native-side state corrupts → unhandled C++ exception. No script stack trace produced.

**Tells in error.log to recognise this pattern in future**:
- High count of `SCR_AIVehicleUsageComponent not found on entity: KSC_Parachute` clustered at altitude (Y > 100)
- 5+ `Math.RandomFloat: invalid parameters` in a single frame
- `Trying to allocate same compartment twice!` within ~30 s
- 50+ `WARNING: One or more override stats failed to set` on sequential `GenericEntity` IDs (paratrooper spawn template)
- Death log line is **only** `ENGINE (E): Application crashed!` + `/tmp/<uuid>.dmp` — no preceding VM Exception

**No local fix.** Same mod family as the Recursive Invoke (KSC/COE2). What to ship Kex: the .dmp file from the container's `/tmp/`, plus the storyboard above. Operational mitigation is unchanged: Pterodactyl auto-restart + snapshot agent.

## Landmines discovered 2026-05-17

### COE_AO destructor NULL `#return` — recurring crash, NOT a one-off

Confirmed recurring after boot 1 (3:50 alive) AND boot 8 (60:00 alive) both died from the same exception:

```
SCRIPT (E): Virtual Machine Exception
Reason: NULL pointer to instance. Variable '#return'
Class:      'COE_AO'
Function: '~COE_AO'
Stack trace:
Scripts/Game/COE/Entities/COE_AO.c:1055 Function ~COE_AO
…immediately followed by…
[~SDRC_Core] Stopping SDRC_Core
…then process exit.
```

**Trigger is NOT time-based** (3 min vs 60 min uptime). Almost certainly tied to **AO rotation count** — each time a `COE_AO` (Area of Operations) entity goes through its destructor, the `#return` deref path can fire. Whether it fires appears stochastic per destructor invocation.

**No local fix.** The bug is in COE2 (`60926835F4A7B0CA`) at `Scripts/Game/COE/Entities/COE_AO.c:1055`. Only Kex (COE2 author) can patch. Operator workarounds to explore:
- In-game COE2 commander UI: reduce AO count / lengthen rotation period to make destructor firings less frequent
- Report to Kex via Workshop comments / Kex Discord with this exact stack trace
- Accept the periodic crash; the snapshot agent + restart cycle makes recovery cheap

**Symptom for operators**: silent process exit (no crash dump), script.log freezes at `[~SDRC_Core] Stopping SDRC_Core`, server falls off the browser via lobby heartbeat timeout shortly after.

### Ashyl FX iter applied 2026-05-17

Removed `RealismOverhaulEffects` (`631D61C22E30D845`), added `[[BHE_EXP]]` (`661D33952728B63D`, 4.3 Beta), `[[Shrapnel]]` (`59BA048FA618471A`), `[[BetterCasings]]` (`59822DF3A86DA197`), `[[JLH_NoAIVehicleHorn]]` (`7A19B6D4C8E23F10`). Tested `[[HFS_Configs]]` (`65351DA1585DF3BF`) for the AFRF heli faction binding gap → rolled back due to placeholder icons + wrong-heli routing (see Known landmines table). Net delta on local serverConfig: +4 mods, -1 mod. Deployed port pending operator action on Pterodactyl host.

Snapshot rollback: `state_snapshots/2026-05-17_14-35-19_pre-ashyl-fx-iter-2026-05-17`.

## Landmines discovered 2026-05-13

### WCS_Earplugs version-pin → 404 → "Unable to initialize Enfusion"

Adding `WCS_Earplugs` (`612F512CD4CB21D5`) to `serverConfig.json` `mods[]` with an explicit `version: "1.0.4"` killed the server during init. Workshop only ships v6.0.2 — the engine's BACKEND issued an HTTP 404 on the pinned download, which cascaded into the misleading `Game addon '58D0FB3206B6F859' not found` (the base game GUID) and then `Unable to initialize the game`. Boot died at 2026-05-13 00:14:02 in `logs_2026-05-13_00-13-55/console.log`.

**Rule: ALWAYS use empty `version: ""` for new mods unless you have a specific frozen-revision reason.** With an empty version field, the engine accepts whatever is on disk OR pulls latest from Workshop. Pinning is only safe when the revision is known immutable.

**The `Game addon '58D0FB3206B6F859' not found` cascade is a misleading downstream symptom** — it's the engine's terminal error when ANY mod's dep chain fails to resolve, not literally about the base game. Look at console.log BACKEND lines for the actual download failure. This wasted ~30 minutes of investigation.

### Folder-presence triggers script execution, not just dep resolution

Removing a mod from `serverConfig.json` `mods[]` while leaving its folder in `profile_new/addons/` does NOT prevent the engine from compiling and running its scripts. Confirmed via console.log gproj line + script.log compile warnings for BaconLoadoutEditor on 2026-05-13. To truly disable a mod, must move folder OR remove from disk. This is the rationale for re-adding BLE as first-class — two other mods (GRS-Apparel, sTsRHSVanillaArsenal) hard-dep it via gproj, so its scripts loaded anyway via the dep chain.

### PVE Conflict Remixed `_US4x` scenario name semantics (HISTORICAL — scenario removed in COE2 pivot)

The "_US4x" in `ConflictPVERemixedVanilla2_US4x.conf` refers to **player spawn faction = US**, not 4× US bases. The map has exactly **1 US-affiliated base** (player HQ). All 70+ other bases are FIA. So US AI is gated to `1 base × N templates = ~3 groups regardless of IPC array length`. The `4x` in the filename = 4× AI density on the **enemy (FIA) side**, not the player side. There is **no `_US8x` variant** — 4x is the ceiling without a Workbench scenario fork.

### WCS arsenal only registers 2 loadout templates (US + USSR vanilla) for 4 factions on the map

DarkGru/3DRS/Arma2/PMC unit prefabs DO load (visible via Game Master entity browser F1) but DO NOT surface in arsenal UI because no `SCR_LoadoutTemplate` exists for them. PCM era worked because PCM bypassed templates and pulled from each faction's prefab catalog directly. PVE Remixed delegates to WCS_Arsenal which is strict. **Workaround**: GM-spawned arsenal entity (unfiltered) or `Arsenal Box - Soft Adding Mods` (`66DED7D8E3BF7E8D`) for partial coverage.

### IPC base affiliation diagnostic (HISTORICAL — IPC removed)

`LOGLOGLOG. Dynamic HQ RADIO` lines name each base's affiliated faction at boot. **This is the smoking gun for "why is faction X under-represented" investigations** — count US-affiliated entries vs FIA-affiliated.

### CRX_EAI Rank_Type — keep at 1 (Vanilla)

CRX_EAI `Rank_Type=0` (CRX-internal rank) silently overrides any external rank-bypass mod. **Set CRX `Rank_Type=1` (Vanilla)** to defer to NoRankRequirements (or any future rank-bypass mod). Currently set correctly (verified `CRX_EAICharacterConfig.txt:13`).

### audit/incidents/*.jsonl is the missing-prefab smoking gun

`profile_new/profile/WCS_LoadoutEditor/audit/incidents/*.jsonl` is the canonical place to read for "missing prefab" diagnostics — engine doesn't surface these in script.log; only this audit subfolder does.

## Landmines discovered 2026-05-11/12

### Pak file lock + addon move/delete

**Never modify active addon folders with the server process running.** The server holds `data.pak` open. Both `Move-Item` and `Remove-Item` will partially fail on locked paks — Move leaves a half-moved folder in both locations, Remove leaves the locked pak orphaned. If you then "clean up" the leftover you've **destroyed the actual data.pak** and only the manifest stub survives. Result: server boots without the mod's content, clients get `RplConnection::ValidationError remote script source code checksum does not match!` and **can't connect**. Fix: delete the broken folder entirely and let the engine trigger a Workshop re-download on the next boot — Steam will pull a fresh complete copy in ~30 s for any mod still declared in `serverConfig.json` `mods[]`. **Pattern to always follow: kill server → wait 3-5s for file handles to release → move/delete folders → restart.**

**Purge-not-disable policy (2026-05-13)**: the old `addons_disabled/` move pattern was abandoned. Folder presence in `addons/` triggers script compilation regardless of declaration (proven by IPCHigherAISkill crashing the server while supposedly "removed from `mods[]`"). Only physical deletion stops execution. Steam will not re-download anything not in `mods[]`, so deletion is safe and durable.

### Quick integrity check

`Get-ChildItem -Filter 'data.pak'` is a quick integrity check for any addon folder. If it returns nothing on a mod that should have a pak file (i.e. anything bigger than a few KB on Workshop), the mod is broken on disk.

### Steam dedicated-server can deliver mods without addon.gproj

Documented in detail in memory `landmine-steam-dedicated-addon-gproj-missing.md`. After a re-download, the engine refuses to register the mod and cascades to "Cannot create game". Reconstruction template + GUID-from-ServerData.json procedure is in that memory file. Reconstructed gprojs cause `RplConnection::ValidationError` for clients running the original Workshop versions — workaround is to drop the affected mods from `serverConfig.json` (as we did for GRS apparel mods until verified byte-identical to Workshop manifests).

## RHS attachment fix applied 2026-05-12

Symptom: "RHS weapons spawn but attachments are useless" (no scopes/grips/suppressors render or equip).

Root cause: the **bridge mod `WCS_RHS_Weapons` (`65F929DF622BAD50`) was downloaded on disk but never declared in `serverConfig.json`**. Its hard dep `WCS_Weapons` (`65CF7AE8574E06D2`) was also on disk but undeclared. Without the bridge, RHS weapon prefabs do not advertise WCS attachment slots, so WCS_Attachments + WCS_Scopes have nothing to bind to on RHS guns. ALWAYS verify the bridge is in `serverConfig.json` mods array, not just downloaded.

Mods added to `serverConfig.json` 2026-05-12 (backup at `serverConfig.pre-rhs-attachment-fix-2026-05-12.json`):
- `WCS_Weapons` `65CF7AE8574E06D2` — base WCS weapon prefabs (dep of bridge).
- `WCS_RHS_Weapons` `65F929DF622BAD50` — the bridge mod itself.
- `RayziUtils` `6632F94B46173164` — common util dep.
- `AimingDeadzone` `684608DD7C7E0DFB` — sway/deadzone primitive.
- `ADSSway-Core` `648D682E7038491E` — current ADSsway core (1.6.0.119 supported).
- `ADSSway-RHS` `656B3A0955474CB7` — RHS weapon sway tuning.
- `BWI-ADSsway-RHS-TAOcompat` `663A654A6BB0AEA4` — Better Weapon Immersion + ADSsway + RHS bridge.

The legacy `Better Weapon Immersion ADSs` mod (`65F76D9612BE5C94`) targets only 1.4.0.48 and is NOT the right pick for 1.6 — keep the existing `BetterWeaponImmersion 2.8` (`5A7B79D8A910A4D1`) and use the BWI-ADSsway-RHS-TAOcompat bridge instead. This resolves the `Unknown class 'ADSS_*'` errors by actually loading the ADSsway prefabs that BWI 2.8 references.

Validate by spawning an RHS M4/AK in arsenal and checking the attachment slots populate; if they do but 3rd-person rendering is broken, that's a WCS_RHS_Weapons-side issue (file in Hushmodee Discord, no local fix).

## IPC custom faction mod path — research summary 2026-05-12 (HISTORICAL — superseded by COE2)

> **STATUS**: COE2 (Combat Ops Enhanced 2 by Kex) was adopted 2026-05-13 as a runtime-flexible alternative to building a custom IPC faction bridge mod. COE2's string-key faction picker eliminates the need for the Workbench mod work described below. **The bridge mod plan is no longer the recommended path** unless you need IPC-specific behavior that COE2 doesn't deliver (e.g., the IPC artillery/seizing-patrol allocation templates). See [[golden_state_2026_05_14_v4]] memory for the current state. The research below is preserved for any operator who later wants to extend COE2 or some other IPC-style scenario.



User asked: "make all loaded faction packs (RHS_USAF, DARKGRU, ZOMBIES, Arma2Factions, 3DRSMODERNRUSSIANFACTION) appear as IPC factions so IPC AutonomousCaptureAI recognizes them."

**Hard requirement**: IPC's faction list lives in a `modded enum SCR_ECampaignFaction` block in a `.c` script file. There is **no JSON runtime hook** in IPC AutonomousCaptureAI 1.x — the engine refuses to load `.c` files at runtime. Adding factions REQUIRES publishing a Workshop mod via Reforger Workbench. There is no no-code path.

**Documented examples (only 2 exist in the wild)**:
- `IPC Modern Faction` (`65766E0A71C84C76`) — adds RHS_USAF + AFRF as IPC factions. Workshop description is just "WIP" but the mod's source is downloadable via Workbench's "Subscribe to source" feature.
- `IPC Warhammer Faction` (`6584626743935E61`) — adds Warhammer 40k factions.

No tutorial exists outside the BI Faction Creation wiki (`community.bistudio.com/wiki/Arma_Reforger:Faction_Creation`) and the BI YouTube faction tutorial playlist (`PLfQwdqWWfpOmogmFw-UpFYvXlXkD9U_t4`). Neither covers IPC-specific group/vehicle list schemas.

**Recommended path for future operator action** — UPDATED 2026-05-13 (not server-side, not Claude-doable):

**BETTER STARTING POINT than `IPC Modern Faction` Workbench Subscribe-to-Source**: Bohemia maintains `BohemiaInteractive/Arma-Reforger-Samples` on GitHub which ships `SampleMod_NewFaction/` — a complete production-grade template containing **all** the configs needed: modded `EEditableEntityLabel` enum extension (`Scripts/Game/Editor/Enums/Modded/EEditableEntityLabel_SampleModNewFaction.c`), `SCR_Faction.conf`, `SCR_CampaignFaction.conf` (this is the IPC integration linchpin — IPC reads `m_DefendersGroupPrefab` + `EntityCatalog/Groups` from registered campaign factions), `EntityCatalog/<Faction>_Characters.conf`, `_Groups.conf`, `_InventoryItems.conf` (arsenal catalog), `_Vehicles.conf`, `_WeaponTripod.conf`. This is what we wrongly dismissed in the 2026-05-12 research — it IS the right template; the IPC integration is implicit through Bohemia's faction system, no IPC-side schema needed.

1. Install Reforger Tools (Workbench) from Steam (~3 GB, free).
2. `git clone https://github.com/BohemiaInteractive/Arma-Reforger-Samples` (more current than IPC Modern Faction's subscribe-to-source).
3. Workbench → "Add Existing Project" → `SampleMod_NewFaction/SampleMod_NewFaction.gproj`.
4. Optional: also Subscribe to source for `IPC Modern Faction` (`65766E0A71C84C76`) as a reference for IPC-specific tweaks. Note: it depends on **IPC dev branch** (`6550E750653AA699`), not stable IPC.
5. For each target faction pack (`DarkGruFactions 66E9222820080A19`, `Arma2Factions 5F396C4F713595DB`, `PMCFaction 6510F26F66E795D4`, optionally `3DRSMODERNRUSSIANSFACTION 666C002F6BB6441C` if re-added):
   - Add an enum entry to `EEditableEntityLabel` with a unix-time-derived int (avoid collisions).
   - Copy + rename `SampleFactionBLUFOR.conf` + `_Campaign.conf` + `_InventoryItems.conf` for the target faction.
   - Swap unit/vehicle/weapon GUIDs from the faction pack's own gproj/configs.
   - Register your `_Campaign.conf` with CampaignFactionManager via `EditablePrefabsComponent_EditableEntity.conf` override.
6. For cross-faction arsenal merge (operator's stated goal "single arsenal with all weapons"): override `InventoryItems_EntityCatalog_US.conf` appending each faction's `_InventoryItems` entries — same pattern `ArsenalBox-SoftAddingMods` uses.
7. Publish to Workshop. Add the new mod ID to `serverConfig.json` `mods[]` with `version: ""`.

**Updated time estimate: 6-10 hours** for one bridge mod covering all 4 faction packs with arsenal merge.

**Validation gates**: grep `script.log` for `IPC Groups of Faction <YOUR_KEY>,` (must be non-zero after FIA base capture). Grep `[AC] SpawnPoint . Faction affliated <YOUR_KEY>` (note "affliated" typo). Spawn US arsenal box, look for added weapons.

**Dead ends to skip**: `IPC-AC-ExtendedCombat` is balance/AI-only, not a faction template; `IPC Dynamic Frontline Core`'s tutorial is for spawnpoint placement only; there is no runtime config file path; `FactionNATOforPvE 665D7797669984A8` is 1.4.x texture-only; `Modern Factions 692A21DC86D4D639` modernizes built-in factions but doesn't extend enum; `ConflictPVERemixedTweak 66BD40A1582AAB40` switches between built-in factions only — no runtime extension. **No scenario on the Workshop exposes JSON-driven faction extension** — this was verified empty across ~14 scenario pages 2026-05-13.

## Cosmetic noise (do not try to fix)

- **3273+ `RpcError: Calling a RPC from an unregistered item! itemType='script::Game::SCR_ArsenalComponent'` per session** — these were CAUSAL when arsenal was undercaching (94 items vs 608+ on disk); now they're cosmetic at the residual rate. Don't try to fix unless arsenal-cache count regresses.
- `LOGLOGLOG. Dynamic HQ RADIO` and `IPC Force Recover Dynamic Radio Range. Base: X, range: 0` repeats — boot-time normal; bug only if range stays 0 across the session.
- `SCR_Faction trying to get entity list of type 'ITEM' but there is no catalog with that type for faction '<X>'` — fires hundreds of times per session for factions that ship without item catalogs (US, FIA, USSR in the PVE Remixed scenario; plus DarkGruAdmin / DarkGru Operators / Ses_CDF / etc. from faction packs). The arsenal entity in PVE Remixed is the bridge — gameplay otherwise unaffected.
- `[FACTION] Has weapon, using REAL faction: <X>` and `[FACTION] No weapon, disguise faction = NULL` — formerly fired every 1 second per armed character from a faction-perception/disguise system in the LinearConflictPVE/PVEConflictwithRHSandWCS scenario mods. Should NOT fire post-COE2-pivot since those mods are removed. If still observed, COE2 has its own faction-perception system worth investigating.
- `SCRIPT (E): Virtual Machine Exception ... NULL pointer to instance. Variable 'targetFaction' ... SCR_CharacterPerceivableComponent.ForceSetPerceivedFaction` — fires when an unarmed character has no disguise faction; the perception system above passes NULL to the engine. Non-fatal, fires once per drop-weapon event. Same source mod as the spam. To fix would require modifying the source mod's `Modded_SCR_CharacterPerceivableComponent.c:67` to null-check before calling `ForceSetPerceivedFaction`.
- `SCRIPT (E): NULL pointer to instance. Variable 'weapMgr' ... SCR_AISwitchMagazine.GetCurrentMagazineComponent` — generic AI runtime warning. Doesn't crash anything.
- `SCR_NotificationsLogDisplay has duplicate notification info key: 'EDITOR_PERCEIVED_FACTION_PUNISHMENT_KILLING_SET' / 'EDITOR_PERCEIVED_FACTION_TYPE_DISABLED'` — fires at every player join because multiple faction mods register the same per-faction notification key.
- `RpcError: Calling a RPC from an unregistered item! itemType='script::Game::SCR_EditorTask', rpc='Rpc_*'` — fires during scenario init for editor-task RPCs. GM tasks still work in-game.
- `'NATO' / 'MPP' / 'RHS_USAF' / 'RHS_AFRF' / 'RHS_ION' / 'CSAT' / 'Ses_*' / 'DarkGru Operators' is not a valid SCR_Faction` errors at scenario init — stale friendly-faction references in faction config files. Cosmetic; doesn't affect playable factions.
- `SCR_BaseResupplySupportStationComponent needs a entity catalog manager!` — twice at scenario init. Vanilla Conflict resupply station looking for a catalog the PVE scenario doesn't provide. Cosmetic.
- `SCR_AmbientVehicleSystem.OnInit NULL pointer m_bIsLinearLoaded` — historical cosmetic from the PVE Conflict Remixed ambient vehicle system (`CPR_SCR_AmbientVehicleSystem.c:9` init-order bug). Should NOT fire post-COE2-pivot since PVE Remixed is removed.
- `SCRIPT (E): Virtual Machine Exception` from `CRX_EAI/SCR_AIHelpers/ArmaReforgerScripted.c:153 OnUpdate` — same as the perception NULL above; CRX EAI's update loop calls into the perception system. Non-fatal.

## Operational conventions

- **Live config is `serverConfig.json`.** Editing the pre-restoration baseline is forbidden.
- **Server name** (browser display) is in `serverConfig.json` `game.name`. The MOTD heading in `ServerAdminTools_Config.json` should match.
- **After any mod-list change**: nothing special needed. (Used to require wiping `.save/playersave/` when EPF was in the stack — no longer applies.)
- **After a server-side crash**: first check `profile_new/logs/<newest>/error.log` and `script.log`, not `console.log` — the actual exception is usually in those two.
- **The "failed to initialize https" error** at end of crash logs is the crash reporter failing to upload, not the cause of death.
- **Always write JSON config files as UTF-8 no-BOM** with `[System.IO.File]::WriteAllText("$path", $json, (New-Object System.Text.UTF8Encoding $false))`. PowerShell's default `Set-Content`/`Out-File` writes UTF-16 LE with BOM, which the engine and mod parsers reject in subtle ways.

### MANDATORY new-mod onboarding flow

Whenever a new mod is added to `serverConfig.json` or `serverconfig-deployed.json`, the following steps MUST be performed in the same session as the install — no exceptions. This protects future agents from inheriting an undocumented mod and silently inheriting its landmines.

1. **5-section evaluation gate** (per `memory/feedback_mod_evaluation_gate.md`) — Workshop ID + Conflict Analysis + Risk Assessment + Execution Strategy + Troubleshooting Checklist + Final Recommendation. Pre-install. **A new mod that didn't pass the gate doesn't get installed.**
2. **Snapshot** before the config edit via `snapshot_state.ps1 -Label "pre-<modname>-add-YYYY-MM-DD"`.
3. **Config edit** at the correct load-order layer (consult `MASTER_OBJECTIVE.md`). Always `version: ""` unless there's a specific frozen-revision reason.
4. **Generate the per-mod doc** in `mod_docs/<ModName>.md`:
   - Run `mod_docs/_scaffold_stubs.ps1` to scaffold the stub (auto-populates frontmatter: GUID, version, hard-deps from gproj, reverse-deps from full-stack scan, declared-in status).
   - Enrich the stub per `mod_docs/_TEMPLATE.md` (10 sections). For a content pack a brief 50-80 line doc is fine; for a framework / AI overlay / scenario controller, 100-250 lines.
   - Source priority: addon.gproj (deps), Workshop page (description, version, license), CLAUDE.md (any landmines the operator already documented), profile config files (if any).
   - Cross-reference any related memories with `[[memory-slug]]` syntax.
5. **Update `mod_docs/INDEX.md`** — add a row at the correct L0-L11 layer table. Flip status from `[—]` to `[doc]`.
6. **Transitive-dep audit** — read the new mod's `addon.gproj` Dependencies block. For each GUID that is NOT in `mods[]`, decide: declare it explicitly (defense against Steam eviction), or document why it's safely transitive (e.g., shared base game). The cost of skipping this step is the IPCHigherAISkill 2026-05-13 cascade.
7. **Boot test + verify**. Watch the standing monitor stack for `VM Exception` / `Cannot create entity` lines naming the new mod. Cache count should be unchanged or increased.
8. **Update CLAUDE.md** if the mod introduces a landmine, a new tuning knob, or a behavior worth flagging for future agents. Update the Density-tuning-knobs table if it's an AI/density mod.

**For multi-mod additions** (e.g. an iter pass), spawn a parallel doc-enrichment subagent per the `mod_docs/_ORCHESTRATOR.md` playbook — one agent per category (frameworks / content packs / AI overlays / etc.). Each agent writes its own docs and reports back.

**Removal flow**: same as add but inverse — keep the doc in `mod_docs/` with `status: removed` and a §7 explaining why it was removed. Do not delete the doc; future agents need the prior-art context.

## Density tuning knobs — current values (2026-05-16 golden state V5 — realism research)

| Knob | Original | V4 (2026-05-14) | V5 (2026-05-16) | Effect / Doctrine source |
|---|---|---|---|---|
| `serverConfig.json` `aiLimit` | 2000 | **3500** | 3500 | Headroom for 100+ active AI groups |
| CRX `Perception_Modifier` | 0.3 | **0.0** | 0.0 | Additive modifier across all perception states |
| CRX `Perception_Safe` | 2.0 (CRX default) | 2.0 | **1.0** | Realism V5: per-state values were inflated above vanilla |
| CRX `Perception_Vigilant` | 3.0 (CRX default) | 3.0 | **2.0** | Realism V5: pre-v1.3.47 vanilla |
| CRX `Perception_Alerted` | 2.5 (CRX default) | 2.5 | **1.5** | Realism V5: vanilla; matches FM 7-8 engagement-range cone |
| CRX `Aim_Accuracy_Error_Modifier` | 0.4 | **0.8** | 0.8 | FM 3-21.8: rifles ineffective beyond 400yd |
| CRX `Magazine_Consumption_Chance` | 100 (arcade) | 100 | **60** | Realism V5: FM 3-21.8 tactical reload doctrine (real infantry reload before empty) |
| CRX `Flee_Chance` | 0% | 20% | **25%** | Marshall "Men Against Fire": 25-40% break under unsupported sustained fire |
| CRX `Danger_Reaction_Chance` | 80 (CRX default) | 80 | 80 | Marshall: 55-95% engagement range; 80 = doctrinal middle |
| CRX `Attack_Reaction_Delay_Modifier` | 200ms | **800ms** | 800ms | Liebenberg 2022 (PMC9441139): military FCRT 529-535ms + 250-300ms target-ID |
| CRX `Formation_Scale` | 1.5 | **2.0** | 2.0 | FM 7-8 dispersed wedge interval. **CAVEAT 2026-05-16**: per CRX v1.3.71 also scales vehicle column gaps — may amplify honk-stuck symptom. Hold pending vehicle investigation. |
| CRX `Combat_Mode` | 1 (YELLOW) | **2 (GREEN)** | 2 (GREEN) | Modern bound-and-cover doctrine, not movie-style |
| CRX `Rank_Type` | 0 (CRX-internal) | **1 (Vanilla)** | 1 (Vanilla) | Honors NoRankRequirements rank bypass |
| CRX `Low_Light_Environment_Modifier` | 2.0 (CRX default) | 2.0 | **2.5** | Realism V5: unaided night vision struggles past ~50m |

Snapshot before V5 tuning: `state_snapshots/2026-05-16_23-49-31_pre-ai-realism-tuning-2026-05-16`. Full research provenance + 18 validated-as-correct knobs in `mod_docs/_asks/2026-05-16_ai-realism-tuning.md`.

**Pending operator decisions** (from realism research):
- `Kill_Unconscious_Chance` (new v1.3.71 knob, NOT in .txt files — lives in `SCR_AISettingsComponent`). Default likely 100. Realism = 30-50 to enable ACE Captives Dev prisoner mechanics. Requires scenario-side or Workbench world-edit override.
- `Formation_Scale=2.0` interaction with vehicle honk-stuck — may need per-group GM override (infantry 2.0, vehicles 1.0) after vehicle investigation A/B test resolves.

> **HISTORICAL — IPC tuning knobs (no longer applicable)**: The previous PVE Remixed + IPC stack had per-IPC knobs (`enemyDetectionRadius`, `spawnSafetyRadius`, `baseDefenseRespawnDelay`, artillery cooldown/charges/shells/interval/minEnemies, US/USSR/FIA `_PRIMARY/SECONDARY` 8x scaling, LCP `autoAddObjectiveDistance`/`objectiveDistanceRadiusMax`). These configs still exist on disk in `profile_new/profile/IPC/` and `profile_new/profile/LinearConflictPVEConfig/` but are **inert** since IPC and LCP were removed in the COE2 pivot. COE2 has its own internal tuning surfaced via the in-game scenario menu.

## State summary as of 2026-05-16 (golden state V5 — local + deployed split)

### Local (`serverConfig.json`) — 103-mod working baseline
- **Mod count**: **103** declared. This is the rollback-safe baseline after the 2026-05-14 121-mod state was reverted (cross-faction arsenal regression from sTsWCSVanillaArsenal/All-In-OneArsenals/ArsenalItemsallranks + ACE Dev/stable conflict). Snapshot: `state_snapshots/2026-05-14_21-35-46_pre-deployment-cleanup-2026-05-14`
- **Active scenario**: `{EE676FAB9DFA4CF7}Missions/COE2_Eden.conf`
- **AI scaling**: aiLimit 3500
- **Realism stack**: RHS Status Quo + WCS + **ACE Core Dev + ACE Captives Dev** (Kex hard-deps both Dev mods — stable ACE removed in revert) + AttachmentFramework + ADSSway chain
- **Faction packs**: DarkGruFactions, Arma2Factions

### Deployed (`serverconfig-deployed.json`) — 117-mod iteration in-flight (2026-05-15/16)
- **Mod count**: **117** declared (103 baseline + 14 iter3 additions)
- **Public endpoint**: `69.164.255.170:27079` (Game Host Bros Linux container, Pterodactyl panel)
- **AI scaling**: aiLimit **1500** (host default — lower than local 3500)
- **Admin password**: `FR8UkfJN` (NOT `admin123` — distinct from local)
- **Iter3 additive fixes**:
  - Vehicle catalog gap fills: **WCS_AH-1S** (`64CB39E57377C861`), **WCS_KA-52** (`64CB35D07BAEE60F`), **MRZR** (`64900A5A31F5DCB5`) — together fixed ~110 of 299 missing prefab errors (~37% reduction)
  - Faction expansion: **BaconZombies** (`622120A5448725E3`) — populates dc_enemyList zombie groups
  - Weather: **AtmosphericWeatherMod** (`64ED6553B8AF6B62`) — dynamic cycling (RealismOverhaul-Weather is static-tuning only)
  - Bug fix: **Fix_RealismSounds_WCS-Earplugs** (`670E8DD9DA6ADF59`) — purpose-built fix for the RO-Sounds+WCS_Earplugs mixer conflict (1-sec earplug fail)
  - Atmospheric immersion: **BattlefieldAmbienceMod** (`655B341B90518659`), **HushedWoodlands** (`693323B2E7B456F4`), **GCSuppression** (`684CE8AA3B1D6573`)
  - COE2 scenario variety: **COE2-Anizay**, **COE2-Khanh Trung**, **COE2-Kunar Province**, **COE2-Fallujah** (tiny 3 KB scenario configs — Steam auto-pulls map deps)
  - Safezone (LOW confidence, v1.4.0.48): **GameMasterSafeZones** (`5CE334EA7649C7CC`)
- **Config edit**: `dc_coreConfig.json` `fallbackEnemyFaction: "FIA"` → `"USSR"` — when modded factions fail catalog, fallback spawns vanilla Soviets instead of vanilla FIA insurgents

### Shared across local + deployed
- **Active scenario file**: COE2_Eden.conf (deployed also has 4 alternate COE2 maps available for runtime switching via `#restart` after editing scenarioId)
- **AI behavior**: CRX Enfusion AI realism-tuned (Perception 0.0, Aim_Error 0.8, Flee 20%, ReactionDelay 800ms, Formation 2.0, Combat_Mode GREEN/defensive). Note: per [[golden_state_2026_05_16_v5]] memory, the REMOTE may have CRX defaults regenerated — verify file sizes match local before assuming tuned values are applied
- **SDRC framework**: SHSScenarioFramework (`687B6840885E539D`) runs SDRC controller on top of COE2. Config at `$profile:/DarcMods/dc_coreConfig.json` + `dc_enemyList.json` + `dc_vehicleList.json`. SDRC populates G_* group lists (78 G_LIGHT + 76 G_HEAVY etc.) from installed factions + C_* character lists (799 C_RANDOMIZED). Vehicle lists: ~2000+ entries
- **Persistence**: none (intentional)
- **Procedural Combat**: removed (do not re-add; see "Why PCM was abandoned")
- **IPC AutonomousCaptureAI**: removed in COE2 pivot (do not re-add — see [[landmine-ipc-ignores-modded-enum-scr-ecampaignfaction]] memory)

### Known unresolved gaps (deferred — no Workshop solution found)
- **Default class per faction in spawn menu**: no documented config field (task #26). Workshop searches returned 9 "Default Loadout" mods but ALL are content replacements, not default-selectors. WCS Slot1 per-player convention exists but user's saved Slot1 .bin files have 22 dead PCM-era prefab refs (audit evidence at `WCS_LoadoutEditor/audit/incidents/dumps/skipped/`) — fix is delete stale .bin and resave fresh
- **Bacon Zombies HP tuning**: no clean Workshop config exists. Best paths: GM per-session adjustments OR Workbench bridge mod build. `TaticalForge - BaconZombies` (`65B531A64D318029`) adds respawn/mutation but NOT HP tuning
- **~189 remaining missing prefab errors** (from 299 original): M1A2 SEPV2 variants (120) + M998 HMMWV (28) + various color/variant gaps. Workshop has no complete-pack mods for these. Cosmetic only — gameplay unaffected

See memory `golden_state_2026_05_16_v5.md` (CURRENT) for full snapshot + iter3 recovery. Prior baselines (SUPERSEDED): `golden_state_2026_05_14_v4.md` (was the 121-mod state, now reverted to 103), `golden_state_2026_05_13_v3.md` (IPC/PVE Remixed pre-COE2), `golden_state_2026_05_12_v2.md`, `golden_state_2026_05_12.md`.
