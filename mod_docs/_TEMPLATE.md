---
workshop_id: "0000000000000000"
workshop_url: https://reforger.armaplatform.com/workshop/0000000000000000
version: ""
author: ""
load_order_layer: L?
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps: []
reverse_deps: []
related_memories: []
---

# <ModName>

> **One-line role**: <what this mod does in the stack, in plain language>

## 1. Overview

<2-3 sentences. Goal: an agent reading just this section knows whether the mod is relevant to the current ask.>

## 2. Functionality / Features

- <feature>
- <feature>

## 3. Configuration

**Config files** (paths under server root):
- `profile_new/profile/<ModName>/<file>.json` — <purpose>

**Tunable keys** (current state — last verified <date>):

| Key | Path | Default | Current | Effect |
|---|---|---|---|---|
| <key> | <file>:<jsonpath> | <default> | <current> | <one-line effect> |

## 4. Operator usage

**In-game**:
- <how to use it: GM tools, chat command, menu path>

**Keybinds** (default):
- <key> — <action>

**Admin commands**:
- <#command> — <effect>

## 5. Compatibility & load order

- **Load order layer**: <L?> (per `MASTER_OBJECTIVE.md`)
- **Must load before**: <mod> — <why>
- **Must load after**: <mod> — <why>
- **Conflicts with**: <mod> — <symptom>
- **Synergies with**: <mod> — <how>

## 6. Performance impact

<observed: AI tick cost, RPC churn, log spam volume, memory footprint. Cite a session log if available.>

## 7. Known issues / landmines

- <issue> — <citation: log file or memory ID>

## 8. Extending / modding

_N/A_ — or, if framework, the integration procedure.

## 9. Changelog / verified state

- **Installed version**: <vx.y.z>
- **Last clean boot**: <date>
- **Last config change**: <date> — <what>

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/<GUID>)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/<GUID>/changelog)
- GitHub: <url if any>
- Discord: <url if any>
- Related memories: `[[<memory-slug>]]`
