---
workshop_id: "68690CA04E7FFB75"
workshop_url: https://reforger.armaplatform.com/workshop/68690CA04E7FFB75
version: "1.0.20"
author: "SaNNTaa"
load_order_layer: L9
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps: []
related_memories: []
folder: "AiMortarPve_68690CA04E7FFB75"
---

# AiMortarPve

> **One-line role**: autonomous AI mortar system that periodically picks a player at random and probabilistically calls a marked mortar strike on them — PvE "indirect-fire pressure" generator.

## 1. Overview

AiMortarPve is the **PvE-pressure** indirect-fire system: it does not place a physical mortar entity. Instead it runs a server-side loop that:
1. Selects a random player
2. Checks if that player has enemies nearby
3. Rolls a probability for whether to call a strike
4. If yes, deploys **red smoke** to mark the target area
5. Launches mortar shells at the marked spot

This makes it the **inverse-polarity sister** of `AIMortarFireSupportSystem`: the FireSupport system is set up by GM and engages enemies on behalf of friendlies; AiMortarPve adds **ambient pressure on players** without operator interaction. Both can run simultaneously.

Behaviour is configurable through component settings (per Workshop description) but the mod does not document a `$profile:/` config file — tunables appear to be on a GameMode component that is set per-scenario by the scenario author, not by operator JSON.

## 2. Functionality / Features

- **Autonomous target selection** — random player picked from active session
- **Enemy-proximity gate** — only fires if the selected player has nearby enemies (avoids strikes on safe-zone players)
- **Probability roll** — not every cycle fires; tunable probability
- **Marked area** — red smoke deployed before shells land (player warning + immersion)
- **Mortar shell launch** — physical projectiles spawned at marked area
- **No physical mortar entity** — abstract "off-map" battery model

## 3. Configuration

**Config files**: none documented in `$profile:/`. Tunables are exposed as **GameMode component parameters** — meaning they're set on the scenario's GameMode entity by the scenario author at Workbench time, not by operator edit at runtime.

On this stack, the active scenario is COE2 (which does NOT bake AiMortarPve into its GameMode). The mod appears to be a candidate for a future SHSScenarioFramework integration or operator-side scenario fork. **Current behaviour on this stack**: mod is declared in mods[] but no GameMode references it — effectively dormant. Verify by grepping `script.log` for `AiMortarPve` lines during a session; if zero hits, mod is not active even though declared.

| Key | Path | Default | Current | Effect |
|---|---|---|---|---|
| _Documented as "GameMode component settings"; no JSON config_ | scenario `.conf` | — | inert on COE2 | scenario must explicitly include the AiMortarPve component |

## 4. Operator usage

**In-game**: passive — no operator interaction once active. Activation requires scenario-side integration, not just mod declaration in `serverConfig.json`.

**Keybinds / Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L9** (AI overlays — sister AI mod)
- **Must load after**: nothing required by gproj (base-game only)
- **Must load before**: scenario controllers at L11 — component class must be registered before scenarios spawn
- **Synergies with**:
  - **CRX EnfusionAI** — CRX tunes the mortar gunner's aim (Aim_Accuracy_Error_Modifier=0.8) IF the mod spawns physical gunners; for the abstract off-map battery the synergy is nil
  - **AIMortarFireSupportSystem** — sister mod (this = anti-player ambient pressure; FireSupport = pro-friendly placed asset). Both can coexist.
- **Conflicts with**: none documented on this stack.

## 6. Performance impact

Server-side loop with a probability roll per tick — cheap. Shell-spawn cost is vanilla projectile. Dormant on COE2 (see § 3) so zero impact at present.

## 7. Known issues / landmines

- **Dormant on COE2 stack**: mod is declared in `serverConfig.json` but COE2's scenario `.conf` does not reference the AiMortarPve GameMode component. Mod ships its scripts/prefabs but has no execution surface — effectively inert. Operator should verify with `grep -i AiMortarPve script.log` in a recent session log; expect zero hits.
- **To actually use it**, either:
  - Scenario-fork COE2 to add the AiMortarPve component to its GameMode, OR
  - Switch to a scenario that natively integrates it (none in current Workshop subscriptions)
- **No documented incidents in any log to date.**

## 8. Extending / modding

To activate AiMortarPve on this stack would require either Workbench-forking COE2 or switching scenarios. Not currently planned.

## 9. Changelog / verified state

- **Installed version**: 1.0.20 (game version 1.6.0.119)
- **Workshop last modified**: 25.04.2026
- **Last clean boot**: continuously loaded in 2026-05-16 V5 golden state (declared but dormant — see § 7)

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/68690CA04E7FFB75)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/68690CA04E7FFB75/changelog)
- `INDEX.md` — `ai:mortar-pve`
- Sister doc: `AIMortarFireSupportSystem.md` (the GM-placed inverse-polarity variant)
