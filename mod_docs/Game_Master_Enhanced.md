---
workshop_id: "5964E0B3BB7410CE"
workshop_url: https://reforger.armaplatform.com/workshop/5964E0B3BB7410CE
version: "1.3.5"
author: ""
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps: []
related_memories: []
folder: "GameMasterEnhanced_5964E0B3BB7410CE"
---

# Game Master Enhanced

> **One-line role**: extends the vanilla Game Master interface with extra spawn categories, faster entity placement, group management, scenario-control shortcuts.

## 1. Overview

Power-user overlay on top of the vanilla Game Master (`Y` key default). Adds quick-spawn shortcuts, additional unit / vehicle / object categories, group-builder tools, and faster placement workflow. The de-facto "must-have" GM tool for COE2/Kex-style sandbox sessions.

## 2. Functionality / Features

- Expanded entity browser (sub-categories per faction/role).
- Group-builder UI for spawning whole squads as a unit.
- Faster prefab placement (no per-click confirm).
- Scenario-control shortcuts (start/end objectives, time of day, weather).

## 3. Configuration

_No documented per-mod config file._ Behavior is in-game UI only.

## 4. Operator usage

In-game: hold `Y` to open Game Master (vanilla binding); the Enhanced UI replaces the default panels. Admin-promoted players (via `[[ServerAdminTools]]`) or `gameMasters` UUIDs auto-get GM access.

## 5. Compatibility & load order

- **Load order layer**: **L10** (GM/admin overlay).
- **Synergies with**: `[[ServerAdminTools]]` (role-gates GM), `[[GMTrenches]]`, `[[GameMasterSafeZones]]` (deployed-only) — all extend the GM toolset.
- **No known conflicts**.

## 6. Performance impact

UI-only mod — zero server-side cost.

## 7. Known issues / landmines

None known. GM operations still cost server CPU per spawned entity; respect the `serverConfig.json aiLimit 3500` (local) / `1500` (deployed) ceilings.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: 1.3.5
- **Last clean boot**: 2026-05-16 (golden state V5)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/5964E0B3BB7410CE)
- Related: `[[ServerAdminTools]]`, `[[GMTrenches]]`, `[[GameMasterSafeZones]]`
