# Game Host Bros — Deployment Runbook

> **STATUS 2026-05-16: ACTIVE.** Server deployed to Game Host Bros at 69.164.255.170:27079 (Linux container). Local mod count 103, deployed 117 (iter3 additions in-flight). See `serverconfig-deployed.json` for canonical deployed mod list.

**Workload**: Arma Reforger v1.6.0.119 dedicated server, 121-mod stack (~19 GB on disk), 30 player slots, `aiLimit 3500`, scenario `{EE676FAB9DFA4CF7}Missions/COE2_Eden.conf` (Combat Ops Enhanced 2 — Eden). Realism stack: RHS Status Quo + WCS + ACE (Core + 4 features) + AttachmentFramework + ADSSway chain + CRX Enfusion AI. Faction packs: DarkGruFactions, Arma2Factions. 43 vehicle/weapon mods. BattlEye OFF, PC-only, crossplay OFF, A2S query on `0.0.0.0:17777`.

**Document purpose**: a runbook for porting the local server to Game Host Bros (GHB). Hand sections 2 and 4 to GHB support if you need them to do work for you.

---

## 1. Plan recommendation

For this workload (121 mods, `aiLimit 3500`, 30 slots, peak 100+ active AI groups), the **GHB 16 GB RAM plan with the Performance Boost add-on** is the minimum viable configuration. Performance Boost is non-negotiable: it lifts CPU share from 400% to 600% and storage from 100 GB to 200 GB. The mod stack alone consumes ~19 GB on disk and runtime memory peaks at 6–10 GB at full population — without the boost the server will either thrash on CPU during artillery + 100-group AI scenes or run out of disk after the first profile-log accumulation cycle.

| Item | Cost / month |
|---|---|
| 16 GB RAM plan | $31.99 |
| Performance Boost add-on (CPU 400→600%, storage 100→200 GB) | $4.98 |
| **Total** | **~$36.97** |

Hardware claim from GHB: Ryzen 9 9950X + EPYC mix, NVMe storage, 10 Gbps uplink, 12 datacenters worldwide, free DDoS protection, 97% Trustpilot satisfaction, fast Discord support. Reference: <https://www.gamehostbros.com/arma-reforger-server-hosting>.

**Important caveat**: GHB plans are **shared CPU**, not dedicated cores. Performance Boost mitigates noisy-neighbor risk but does not eliminate it. Reforger's main game tick is single-threaded — if the noisy neighbor lands on the same physical core, tick-rate degrades visibly even at the boosted CPU share.

---

## 2. Pre-purchase questions for GHB sales

Send these to GHB sales/Discord **before** paying. The answers determine whether the plan is actually viable for this workload.

1. Can I be guaranteed a **Ryzen 9 9950X** node (not EPYC)? The 9950X has higher single-thread clock and Reforger's game tick is single-threaded, so single-thread perf dominates everything else.
2. Can my CPU share be **pinned to specific physical cores** to avoid noisy-neighbor contention on the main game-tick thread?
3. Are there **any aiLimit caps** enforced platform-wide? My scenario runs `aiLimit 3500` and I need that respected.
4. Do you provide **SFTP or a file manager** for direct upload of `serverConfig.json` and the `profile_new/profile/` JSON/TXT config tree? (I have ~10 config files to drop in beyond the main config.)
5. Do you expose **start/stop/restart hooks I can script against** (REST/CLI), or is it dashboard-only?
6. Custom **port forwarding** for game port `2001` (TCP+UDP) and A2S query `17777` (UDP)?
7. What's your **scheduled-restart cadence** and can I disable auto-updates during sessions? (A surprise server restart mid-session is a worse outcome than a delayed engine patch.)
8. What's your **backup policy**? Automated snapshots? Frequency? Retention? Self-serve restore?
9. Is **Workshop mod download bandwidth metered** or capped? My stack pulls ~19 GB on first boot.

---

## 3. Deployment bundle — what to upload to GHB

Upload these from the local install at `C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server\`.

| File / directory | Role |
|---|---|
| `serverConfig.json` | The single source of truth. Declares all 121 mods, scenario, ports, server name, admin password, aiLimit. **Edit before upload — see section 4.** |
| `profile_new/profile/ServerAdminTools_Config.json` | Admin UID list, MOTD/serverMessage, ban list, scheduled chat. **Must be UTF-8 no-BOM.** |
| `profile_new/profile/CRX_EAI/CRX_EAICharacterConfig.txt` | CRX Enfusion AI per-character tuning (perception, aim error, reaction delay). |
| `profile_new/profile/CRX_EAI/CRX_EAIGroupConfig.txt` | CRX EAI group-behavior tuning (flanking, fireteam splits, sound reaction). |
| `profile_new/profile/CRX_EAI/CRX_EAIExperimentalConfig.txt` | CRX EAI experimental knobs. |
| `profile_new/profile/GRS_ATAK/server_config.json` | GRS ATAK situational-awareness mod config. Don't modify — well-tuned. |
| `profile_new/profile/BaconLoadoutEditor_Loadouts/` | Player loadout storage (entire tree). Only upload if you want to preserve existing player loadouts; otherwise BLE re-inits empty on first boot. |

**Operational scripts (local-only, do NOT upload to a managed host unless GHB explicitly supports custom shell scripts)**:

- `start_server.ps1` — local launcher with kill/cleanup/snapshot orchestration. **Useless on GHB.** Use the GHB dashboard start button.
- `snapshot_state.ps1` / `restore_state.ps1` — local snapshot/rollback utilities.
- `mod_health_check.ps1` — local mod-folder integrity scanner.
- `analyze_logs.ps1` — local log summarizer.
- `snapshot_agent.ps1` / `snapshot_agent_loop.cmd` — local 15-min stability check + auto-Golden snapshot agent.

If GHB confirms in question 5 above that they expose a hook + scheduled task system, upload `snapshot_agent.ps1` and adapt it. Otherwise, rely on GHB's own backup schedule.

---

## 4. Config adjustments for the remote host

Edit `serverConfig.json` and `ServerAdminTools_Config.json` **locally** before uploading. Keep a copy of the original for rollback.

### `serverConfig.json` field changes

| Field | Old (local) | New (GHB) |
|---|---|---|
| `publicAddress` | `76.235.218.202` | **whatever IP GHB assigns** (visible in their dashboard immediately after provisioning) |
| `bindAddress` | `0.0.0.0` | `0.0.0.0` (unchanged — binds all interfaces) |
| `bindPort` | `2001` | `2001` (unchanged unless GHB requires a different port; ask in question 6) |
| `publicPort` | `2001` | `2001` (must match `bindPort`) |
| `passwordAdmin` | `admin123` | **strong random 16+ chars** — use a password manager. Do not reuse the local password. |
| `disableCrashReporter` | `true` | `true` (unchanged — kills the misleading "failed to initialize https" tail in crash logs) |
| `maxPlayers` | `30` | `30` (unchanged) |
| `playerCountLimit` / `m_iPlayerCount` | `30` | `30` (unchanged) |
| `aiLimit` | `3500` | `3500` (unchanged — assuming GHB confirms no platform cap in question 3) |
| `mods[]` | 121 entries | **unchanged — do not touch** |
| `scenarioId` | `{EE676FAB9DFA4CF7}Missions/COE2_Eden.conf` | unchanged |
| `game.name` | current local name | optional rename to e.g. `"PC - COE2 Eden | RHS + WCS + ACE | High AI (3500)"` |

### `ServerAdminTools_Config.json` MOTD line

The local MOTD reveals the admin password (`admin123`). **Strip that line** before going public — or replace it with a generic notice. The MOTD heading should also match the new `game.name` if you change it.

Write the file as **UTF-8 no-BOM** (PowerShell default writes UTF-16 LE with BOM, which the mod silently rejects and overwrites with defaults). Use:

```powershell
[System.IO.File]::WriteAllText($path, $json, (New-Object System.Text.UTF8Encoding $false))
```

### Admin UID

Operator UID `ccb8d5ae-5eb1-4393-8d93-ed43f072adb3` (nickname `AcridVaporiZe`) goes in the `admins` object as:

```json
"admins": { "ccb8d5ae-5eb1-4393-8d93-ed43f072adb3": "AcridVaporiZe" }
```

If past `Recursive call of Invoke!` errors recur on the GHB host shortly after you connect, revert `admins` to `{}` and use `#login <newpassword>` in chat as the manual fallback.

---

## 5. First-boot runbook

Estimated total time from "click start" to "server browser visible, ready for players": **15–25 minutes**.

1. **Provision the plan**: 16 GB RAM + Performance Boost add-on. Wait for the dashboard to show the assigned public IP and game/query ports.
2. **Edit `serverConfig.json` locally** per section 4. Update `publicAddress`, `passwordAdmin`, optionally `game.name`.
3. **Upload via SFTP / file manager** (depending on what GHB exposes):
   - `serverConfig.json` to the server root
   - All files listed in section 3 to their matching paths under `profile_new/profile/`
4. **Click Start** in the GHB dashboard. Do **not** run `start_server.ps1` — it's a local-only launcher.
5. **Watch first-boot Steam Workshop download**: ~19 GB across 121 mods, expect 10–15 minutes on GHB's NVMe + 10 Gbps uplink. If GHB exposes a live log viewer, watch for `console.log` `gproj:` lines populating as each mod is loaded.
6. **Validation gates** (run these against the live `script.log` once boot progresses):
   - `OnGameStateChanged = GAME` — server reached playable state. Local equivalent reaches this in ~80 s after mods finish loading.
   - `Cached 6774 items` (or close — arsenal cache count from local healthy state). A drastically lower number (94, 608, etc.) indicates an arsenal-undercache regression.
   - `IPC Groups of Faction <X>,` ticking with non-zero values for the active enemy faction once a player joins.
   - **No crash dump** appearing in `profile_new/crashes/`.
7. **Expected residual noise** (do **not** treat as failures): ~1793 errors per session — ADSSway weapon-prefab packaging defects, dedicated-server warm-up warnings, animation-curve clamps, fallback localization keys. Documented as cosmetic in the local CLAUDE.md.
8. **Server browser check**: search by name. Confirms NAT, public address, and A2S query port are all healthy.
9. **First admin login**: connect, then `#login <newpassword>` in chat. Confirm admin role granted.
10. **Smoke test**: spawn arsenal, verify WCS + RHS attachments populate (proves the WCS_RHS_Weapons bridge is loading correctly). Drive a vehicle to confirm the RHS Status Quo content layer registered.

---

## 6. Ongoing operations on GHB

**Backups**: Whatever cadence GHB's automated snapshots run at, supplement before any config or mod-list change by downloading `serverConfig.json` + the entire `profile_new/profile/` tree to local. The `snapshot_state.ps1` discipline you use locally cannot run on a managed host without custom shell access — accept that "backup" on GHB means manual file download.

**Monitoring**: GHB dashboard typically exposes CPU%, RAM, and player count. For deeper monitoring (the 5-monitor Claude stack you run locally — density alerts, peak-AI alerts, error-log critical, arsenal/loadout warnings, crash-dump watcher), you need either:
- An open SFTP tunnel + local `Monitor` tool tailing the remote `script.log`, or
- GHB's web log viewer (less powerful, no regex alerting)

**Restart cadence**: ask GHB sales (question 7) what their default is. For a 121-mod / `aiLimit 3500` workload, a daily restart at off-peak (e.g. 06:00 local) is healthy — keeps memory growth and any IPC-state drift in check. Avoid mid-session forced restarts.

**DDoS**: included free, no config needed.

**Mod updates**: when a Workshop mod publishes a new version, Steam pulls it on the next server restart (because each mod in `mods[]` has `version: ""`, meaning "latest"). After any mod update, run validation gates from section 5. If a freshly-pulled mod breaks boot, the recovery path is to pin that mod to its prior version in `serverConfig.json` (`"version": "X.Y.Z"`) — but only when the prior revision is known immutable. **The empty-version default is safer for everything else** (see CLAUDE.md "WCS_Earplugs version-pin → 404" landmine).

**Server-side mod blacklist enforcement**: the `start_server.ps1` script's "delete blacklisted mod folders before launch" logic does not run on GHB. **However**, the local landmine where Steam re-pulls undeclared mods from the **local Steam cache** does not exist on GHB — their Steam cache starts fresh and only downloads what's in your `mods[]`. So `IPCHigherAISkill`, `MisfitsSquadBackpacks`, `RISLaserAttachments`, `Zagoria89BMP2` (the four undeclared mods that re-appear locally) **will not appear on GHB** unless declared. This is a net positive vs. local hosting.

---

## 7. Known caveats and risks

- **Shared CPU, not dedicated cores**: even with Performance Boost, noisy neighbors on the same physical core will degrade tick-rate during heavy AI scenes. Migrate or escalate plan if perceived.
- **No custom shell scripts**: the local snapshot agent, log analyzers, and start-script orchestration do not transfer. You lose self-healing snapshot/restore unless GHB confirms scheduled-task support.
- **No filesystem-level diagnostics by default**: without SFTP you can't inspect `audit/incidents/*.jsonl` (the canonical missing-prefab smoking gun used in past investigations) or pull `error.log` for offline analysis. Confirm SFTP access exists (question 4).
- **First-boot Workshop download time**: 10–15 min. Players hitting "join" during this window will see "server not responding."
- **Auto-restart surprises**: GHB may force restarts for engine patches outside your control. Confirm cadence and opt-out options.
- **Trust boundary**: GHB has root on your server. The admin password, mod GUIDs, and scenario configs are visible to their staff. Use a unique admin password not reused anywhere.

---

## 8. Rollback / disaster recovery

If first boot fails or behaves badly:

1. **Capture diagnostics first** — pull `console.log`, `script.log`, `error.log` from the newest `profile_new/logs/logs_<timestamp>/` folder via SFTP. Without these the cause is unrecoverable.
2. **Check `crashes/*.dmp`** — any new file > 0 bytes here means engine crash; correlate with `script.log` tail to identify the failing mod / scenario.
3. **Most likely first-boot failure modes**:
   - **`Game addon '58D0FB3206B6F859' not found`** at boot: misleading downstream symptom of a mod download failing. Check `console.log` BACKEND lines for the actual HTTP error. Usually caused by version-pinning a mod to a revision Workshop no longer ships. Fix: set `version: ""` for the offending mod.
   - **`Unable to initialize Enfusion`**: same root cause as above — a mod failed to download or its dep chain broke.
   - **`Cannot create game`**: usually a missing `addon.gproj` in a Workshop-delivered mod. Documented landmine; fix is to declare/undeclare in `mods[]` to force a fresh re-download.
   - **`RplConnection::ValidationError remote script source code checksum does not match!` from clients**: a mod's `data.pak` got truncated or replaced by a manifest stub. Force re-download by removing the mod from `mods[]`, restart, re-add, restart.
4. **Clean rollback**: re-upload the original `serverConfig.json` (the copy you saved in section 4) and the original config tree. Restart.
5. **Nuclear option**: GHB dashboard usually offers a "reset to clean install" button. Use only if config rollback fails — you'll lose all uploaded files and need to redo section 3.
6. **Local-side fallback**: if GHB has any sustained outage during a session, the local server at `76.235.218.202:2001` with the original `serverConfig.json` is still your bare-metal backup. Keep both configs in version control.

---

## 9. Cost reality check

| Option | Monthly | Annual |
|---|---|---|
| **GHB 16 GB + Performance Boost** | $36.97 | $443.64 |
| GHB 16 GB without Performance Boost | $31.99 | $383.88 (**not recommended** — CPU and storage too tight) |
| Self-host on existing home hardware (current state) | $0 marginal | $0 marginal |
| Dedicated bare-metal VPS (Hetzner AX41 or similar) | ~$50–70 | $600–840 |
| Major US managed Arma host (e.g. GTXGaming, Nitrado equivalents) | $40–80 | $480–960 |

**The honest tradeoff**: GHB at ~$444/year is the cheapest credible managed option for this workload. Dedicated bare-metal is 30–90% more expensive but eliminates noisy-neighbor risk and gives you root for the snapshot agent. Self-hosting is free but consumes home WAN upstream (~45 Mbps sustained at peak combat × 30 players) and requires the home machine to stay up 24/7.

**Recommended decision rule**: try GHB for one billing cycle. If tick-rate during heavy AI scenes is acceptable to players (subjective — measure with player feedback during a 100+ AI group engagement), keep it. If not, escalate to a dedicated VPS where you control the cores. Do not stay on a 16 GB shared plan if you find yourself wanting to push `aiLimit` above 3500 — at that point the workload has outgrown shared CPU regardless of the boost.

---

**End of runbook.** Keep the local install + `CLAUDE.md` as the canonical engineering reference; this document is the deployment-only subset.
