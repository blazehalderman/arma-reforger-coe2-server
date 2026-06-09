---
workshop_id: "606D03292879EF5B"
workshop_url: https://reforger.armaplatform.com/workshop/606D03292879EF5B
version: "1.0.17"
author: ""
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
  - "5AAAC70D754245DD # ServerAdminTools"
reverse_deps: []
related_memories: []
folder: "ScenarioReloadMenu_606D03292879EF5B"
---

# ScenarioReloadMenu

> **One-line role**: admin-gated in-game menu to restart / switch scenario without dropping the session.

## 1. Overview

Adds a `#restart` / scenario-picker UI exposed to ServerAdminTools admins. Lets the operator restart the current scenario or hot-swap to another bundled scenario without going through the server CLI. Particularly useful with the deployed iter3 stack which bundles 4 alternate COE2 maps (Anizay, Khanh Trung, Kunar Province, Fallujah) per CLAUDE.md V5.

## 2. Functionality / Features

- In-chat `#restart` command (admin-only).
- Scenario picker UI (when multiple .conf files are bundled).
- Optional vote-based reload (gated via SAT vote system).

## 3. Configuration

- `profile_new/profile/ScenarioReloadMenu_Config.json` — observed to exist on disk; tunables are flags for vote thresholds + auto-reload timers (file is small; hand-tune cautiously).

## 4. Operator usage

In-chat: `#restart` (admin), `#restart <scenarioId>` to switch maps. The bundled COE2 alt-maps need their scenarioId entered manually (not all surface in the picker by default — verify by listing them in the UI on first use).

## 5. Compatibility & load order

- **Load order layer**: **L10** (GM/admin overlay).
- **Hard-deps**: `[[ServerAdminTools]]` (for admin role gating).
- **Synergies with**: deployed alt-COE2 scenarios (`[[COE2_-_Anizay]]`, `[[COE2_-_Khanh_Trung]]`, `[[COE2_-_Kunar_Province]]`, `[[COE2_-_Fallujah]]`) — these only make sense if you have a way to switch to them mid-session.
- **No known conflicts**.

## 6. Performance impact

Idle. Reload triggers full scenario re-init (multi-second pause for all clients).

## 7. Known issues / landmines

A scenario reload resets all in-memory state (no persistence in this stack). Players will respawn at default positions and lose loadout selections unless saved via WCS Loadout Editor's persistent Slot1+.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: 1.0.17
- **Last clean boot**: 2026-05-16 (golden state V5)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/606D03292879EF5B)
- Hard-depped: `[[ServerAdminTools]]`
- `CLAUDE.md` § "State summary as of 2026-05-16" — deployed alt-COE2 scenarios
