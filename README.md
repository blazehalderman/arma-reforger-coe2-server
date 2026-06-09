# Arma Reforger Dedicated Server — Config Archive

Private archive of the **custom configuration, operator scripts, and notes** for a
modded Arma Reforger v1.6.0.119 dedicated server. Active scenario: **Combat Ops
Enhanced 2 (COE2) on Eden**, realism stack RHS Status Quo + WCS + ACE Dev + CRX
Enfusion AI.

This repo intentionally contains **only the files that are not re-downloadable and
not part of a standard Steam install**. The ~40 GB of game data, Workshop mods,
logs, crash dumps, engine binaries, and the engine player-save are deliberately
excluded (see `.gitignore`) — Steam and the engine regenerate all of that.

## What's in here

| Path | Role |
|---|---|
| `serverConfig.json` | Live config the engine reads (local 103-mod baseline). |
| `serverConfigDeployed.json` | Deployed-host config (Game Host Bros Linux container). |
| `serverConfig.pre-restoration-2026-05-10.json` | Known-good recovery baseline. |
| `start_server.ps1` | Launcher (kills old proc, validates, starts, probes AI, health-check). |
| `analyze_logs.ps1`, `mod_health_check.ps1` | Log summarizer + post-boot validator. |
| `snapshot_state.ps1`, `restore_state.ps1` | Atomic config snapshot + rollback. |
| `snapshot_agent.ps1`, `snapshot_agent_loop.cmd` | Background auto-snapshot/cleanup loop. |
| `_reorder_to_layers.ps1` | Reorders `mods[]` into the 12-layer load order. |
| `CLAUDE.md` | **Operator's notes** — landmines, mod purge protocol, tuning knobs, playbooks. Read this first. |
| `MASTER_OBJECTIVE.md` | Canonical 12-layer load order + golden-state spec. |
| `mod_docs/` | Per-mod documentation (one doc per mod) + index. |
| `state_snapshots/` | Snapshot history (config-only rollback baselines). |
| `profile_new/profile/` | Per-mod server-side configs: `CRX_EAI/` (AI tuning), `DarcMods/` (SDRC), `GRS_ATAK/`, `ATAK/`, `WCS_LoadoutEditor/`, `ServerAdminTools_Config.json`, `ScenarioReloadMenu_Config.json`. |
| `*.md` (CONTEXT_PROMPT, GAME_HOST_BROS_DEPLOYMENT, HANDOFF_CONTEXT, LIVE_TEST_CASES, MOD_INGAME_GUIDE, SESSION_LOG, context, experiment) | Working notes / deployment + test docs. |

## What's deliberately excluded

- `addons/` and `profile_new/addons/` — base game data + Workshop mods (~40 GB, Steam re-downloads them from the `mods[]` list in `serverConfig.json`).
- `*.exe`, `*.dll`, `steam_appid.txt`, `License.txt`, `Readme.txt`, `docs/`, `battleye/`, `licenses/` — standard Steam install files.
- `profile_new/logs/`, `profile_new/crashes/`, `*.dmp`, `last_session_errors*.txt`, `*.log`, `RecentErrorLogs*/` — logs and crash dumps.
- `profile_new/profile/.save/` — engine player-profile sync (regenerable, ~123 MB).
- `profile_new/profile/ownerToken.bin` — Bohemia server-owner identity credential (regenerates on run).
- `profile_backup/` — superseded old profile.

> **Note:** passwords in the config files (admin / server-join) are committed verbatim
> by choice, since this is a private repo and they're needed for an immediate restore.
> Rotate them before any public deployment.

## Restoring later (fresh machine)

1. Install **Arma Reforger Server** via Steam (this pulls the ~40 GB base game + binaries).
2. In the install directory:
   ```powershell
   git init
   git remote add origin git@github.com:blazehalderman/arma-reforger-coe2-server.git
   git fetch origin
   git checkout -f main      # overlays the archived config onto the install; ignored game data untouched
   ```
3. Launch with `start_server.ps1`. On first boot the engine reads `serverConfig.json` `mods[]`
   and Steam **re-downloads every Workshop mod automatically** (~30 GB, a few minutes).
4. Verify boot reached `OnGameStateChanged = GAME` and arsenal cache count via `mod_health_check.ps1`.

See `CLAUDE.md` for the full operator playbook (mod purge safety, monitor stack, density tuning).
