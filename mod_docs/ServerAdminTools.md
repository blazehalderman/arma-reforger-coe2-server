---
workshop_id: "5AAAC70D754245DD"
workshop_url: https://reforger.armaplatform.com/workshop/5AAAC70D754245DD
version: "1.6.5"
author: "Arkensor / community"
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps:
  - "606D03292879EF5B # ScenarioReloadMenu"
related_memories: []
folder: "ServerAdminTools_5AAAC70D754245DD"
---

# ServerAdminTools

> **One-line role**: server-side admin/moderation backbone — login, kick/ban, MOTD, scheduled chat, stats export, events API, and the data substrate every other admin/QoL mod plugs into.

## 1. Overview

Long-running community staple that adds an in-game admin UI plus the `#login`, `#kick`, `#ban`, `#vote` chat command suite, persistent ban/admin lists, a customizable MOTD/serverMessage panel, scheduled chat broadcasts, a player-stats sidecar file, and an HTTP events webhook. Several other mods in this stack hard-depend on it (notably `ScenarioReloadMenu`). The whole admin surface lives in `profile_new/profile/ServerAdminTools_Config.json`.

## 2. Functionality / Features

- `#login <password>` chat command (matches `serverConfig.json operating.passwordAdmin`).
- Per-UUID auto-admin promotion via `admins` map in `ServerAdminTools_Config.json`.
- Per-UUID auto-Game-Master promotion via `gameMasters` map.
- Persistent `bans` map (UUID -> reason/expiry); reload interval `banReloadIntervalMinutes`.
- MOTD/`serverMessage` HTML panel shown on connect (multi-line, color tags, image header).
- Scheduled + repeated chat broadcasts (`scheduledChatMessages`, `repeatedChatMessages`, `repeatedChatMessagesCycle`).
- Player stats sidecar (`ServerAdminTools_Stats.json`) refreshed every `statsFileUpdateIntervalSeconds`.
- HTTP events API: ships JSON for `player_joined`, `player_killed`, `admin_action`, `game_started`/`ended`, `vote_started`/`ended`, `conflict_base_captured`, `server_fps_low` to `eventsApiAddress` with bearer `eventsApiToken`.

## 3. Configuration

**Config files** (paths under server root):
- `profile_new/profile/ServerAdminTools_Config.json` — **the** config file. Everything tunable lives here.
- `profile_new/profile/ServerAdminTools_Stats.json` — stats sidecar; written, never edited by hand.

**Schema** (single JSON object — observed live shape 2026-05-16):

| Key | Type | Current value (live) | Effect |
|---|---|---|---|
| `admins` | `{uuid: nickname}` | `{}` | Auto-promotes listed UUIDs to admin on join. Operator UUID `ccb8d5ae-5eb1-4393-8d93-ed43f072adb3` (`AcridVaporiZe`) goes here — currently empty, manual `#login admin123` used. |
| `bans` | `{uuid: reason}` | `{}` | Persistent ban list. Reloaded every `banReloadIntervalMinutes`. |
| `gameMasters` | `{uuid: nickname}` | `{"00000000-...-000000000003":"example"}` | Auto-promotes to Game Master role on join. Stub default — replace with real UUIDs. |
| `repeatedChatMessages` | string[] | `[]` | Cycled broadcast lines. |
| `scheduledChatMessages` | array | `[]` | Time-anchored broadcast lines. |
| `serverMessage` | string[] | (MOTD HTML lines — currently still references the PRE-COE2 PVE Remixed stack) | Each entry = one line of MOTD; supports `<h2>`, `<p>`, `<b>`, `<color rgba=...>`. **OUT OF DATE** — needs rewrite for COE2 Eden stack per CLAUDE.md "Admin" section (2026-05-14 rewrite was specified but live file still has the PVE Remixed copy). |
| `chatMessagesUtcTime` | bool | `true` | UTC timestamps on chat. |
| `repeatedChatMessagesCycle` | bool | `true` | Round-robin the repeated set. |
| `statsFileUpdateIntervalSeconds` | int | `30` | Stats refresh cadence. |
| `banReloadIntervalMinutes` | int | `5` | Ban-list hot-reload cadence. |
| `statsFileName` | string | `"$profile:ServerAdminTools_Stats.json"` | Where stats land. |
| `statsSaveConnectedPlayers` | bool | `true` | Include online player list in stats. |
| `eventsApiToken` | string | `""` | Bearer token for events POST. |
| `eventsApiAddress` | string | `""` | Webhook URL. Empty = events disabled. |
| `eventsApiRatelimitSeconds` | int | `10` | Min interval between bursts. |
| `eventsApiEventsEnabled` | string[] | (9 events — see "Functionality" above) | Whitelist of event channels. |
| `serverMessageHeaderImage` | string | `"mission"` | MOTD header banner type. |
| `serverMessageDiscordLink` | string | `"https://discord.gg"` | Clickable Discord button in MOTD. |
| `serverMessageOpen` | bool | `true` | Show MOTD by default on connect. |

## 4. Operator usage

**In-chat**:
- `#login admin123` — promotes the typing player to admin (matches `serverConfig.json passwordAdmin`).
- `#kick <name>` / `#ban <name> <reason>` / `#unban <uuid>` — moderation.
- `#vote kick <name>` / `#vote map ...` — player-initiated votes.

**Admin UI**: opens via the keybind ServerAdminTools binds in client settings (varies). Player list, kick/ban/teleport/spectate, MOTD edit live, vote management.

**Stats consumer**: external dashboards poll `ServerAdminTools_Stats.json` (or hook `eventsApiAddress`) — useful for Discord bot integrations.

## 5. Compatibility & load order

- **Load order layer**: **L10** (per `MASTER_OBJECTIVE.md` — GM/admin/QoL overlays).
- **Must load before**: `ScenarioReloadMenu` (hard-depped via gproj).
- **Synergies with**: any in-game webhook/Discord bot consuming `ServerAdminTools_Stats.json` or the events API.
- **No known conflicts** at the engine level; this is the most-deployed admin mod in the ecosystem.

## 6. Performance impact

Negligible per-tick cost. Stats writer is a once-per-30s small JSON dump. Events API is rate-limited (`eventsApiRatelimitSeconds`). MOTD rendering is client-side only.

## 7. Known issues / landmines

**CRITICAL — UTF-8 no-BOM write requirement** (CLAUDE.md "Admin" section): `ServerAdminTools_Config.json` MUST be saved as UTF-8 *without* BOM. PowerShell's default `Set-Content` / `Out-File` writes UTF-16 LE with BOM, which makes the mod's loader spit a `KeyReadError` cascade on boot and **silently overwrite the file with defaults**, losing all customizations (admin list, ban list, MOTD). The correct write pattern is:

```powershell
[System.IO.File]::WriteAllText("$path", $json, (New-Object System.Text.UTF8Encoding $false))
```

**Recursive call landmine** (CLAUDE.md "Admin" section): older ServerAdminTools versions throw `Recursive call of Invoke!` when auto-promoting admins on player join. If the server crashes shortly after the operator connects with that line in `error.log`, revert the `admins` object to `{}` and fall back to manual `#login admin123`. This is why `admins` is currently empty in the live config.

**MOTD is stale** (2026-05-16): `serverMessage` still describes the PRE-COE2 PVE Remixed stack ("PVE Conflict Remixed Everon 4x — RHS / WCS / ACE / IPC"). CLAUDE.md notes a 2026-05-14 rewrite was planned for the COE2 stack but the on-disk file has not been updated. Refresh whenever scenario changes; remember to match `serverConfig.json game.name`.

**Admin password in MOTD by operator's explicit choice** (`admin123`, weak). For public deployment, change `serverConfig.json operating.passwordAdmin` AND the corresponding line of `serverMessage` together.

## 8. Extending / modding

This is the substrate, not a framework — extension happens by **other mods reading its config**:
- `ScenarioReloadMenu` hard-deps SAT and surfaces `#restart`-style commands using SAT's admin role gating.
- External Discord bots subscribe to `eventsApiAddress` to relay player-joined/killed events.

To add a new admin: append `"<uuid>": "<nickname>"` to the `admins` map, write file as UTF-8 no-BOM, restart server (or wait for next `banReloadIntervalMinutes` tick — admin map reload is more conservative; restart is the safe path).

## 9. Changelog / verified state

- **Installed version**: 1.6.5
- **Folder**: `profile_new/addons/ServerAdminTools_5AAAC70D754245DD`
- **Config**: `profile_new/profile/ServerAdminTools_Config.json` (live)
- **Last clean boot**: 2026-05-16 (golden state V5)
- **Pending edits**: MOTD/`serverMessage` rewrite to COE2 stack per CLAUDE.md "Admin" section.

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/5AAAC70D754245DD)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/5AAAC70D754245DD/changelog)
- `CLAUDE.md` § "Admin" — UTF-8 no-BOM write mandate, recursion landmine, operator UUID
- `CLAUDE.md` § "Operational conventions" — JSON config write pattern
- `serverConfig.json` `operating.passwordAdmin` — paired credential
