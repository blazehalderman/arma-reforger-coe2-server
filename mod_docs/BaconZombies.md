---
workshop_id: "622120A5448725E3"
workshop_url: https://reforger.armaplatform.com/workshop/622120A5448725E3
version: ""
author: "Bacon (Bacon-mods family)"
load_order_layer: L6
status: deployed-only
last_verified: 2026-05-16
declared_in:
  - deployed
hard_deps: []
reverse_deps: []
related_memories:
  - golden_state_2026_05_16_v5.md
folder: ""
---

# BaconZombies

> **One-line role**: faction-pack that ships infected/zombie character prefabs + groups, added to the deployed iter3 stack specifically to populate SDRC's `dc_enemyList` zombie group buckets (`G_ZOMBIE_SMALL/MEDIUM/LARGE`).

## 1. Overview

Adds a zombie/infected hostile faction to the modded Arma Reforger ecosystem. In this server's context, the mod was selected **not for any standalone zombie-mode gameplay** but to **populate the SDRC controller's empty zombie group lists** so `dc_enemyList.json` can pick zombie-themed spawns when the operator picks the right enemy-faction string in COE2. Per [[golden_state_2026_05_16_v5]] §"Iter3 SDRC catalog growth", pre-BaconZombies the SDRC G_ZOMBIE_* lists were `0/0/0`; the verification gate is whether the next deployed boot populates them non-zero.

## 2. Functionality / Features

- Zombie/infected character prefabs (multiple variants: shamblers, runners, possibly armored)
- Pre-built groups (small/medium/large packs) that SDRC's `dc_enemyList` enumerates by name prefix into G_ZOMBIE_SMALL, G_ZOMBIE_MEDIUM, G_ZOMBIE_LARGE buckets
- Zombie faction registration (visible in Game Master Entity Browser under a faction header like "Zombies" or "Infected")
- No persistence layer of its own; respawns/persistence behavior is whatever the active scenario provides

## 3. Configuration

**Config files**: none confirmed under `$profile:/` for this mod itself. Zombie spawn behavior is governed by the **SDRC controller** via:

- `$profile:/DarcMods/dc_coreConfig.json` — top-level scenario knobs; if `fallbackEnemyFaction` is set to a zombie string, BaconZombies units will spawn as the COE2 enemy.
- `$profile:/DarcMods/dc_enemyList.json` — group-list buckets. BaconZombies populates the `G_ZOMBIE_*` buckets here at runtime via the SDRC discovery scan.

**Tunable keys**: none mod-side — this is a content/faction pack.

**HP/damage tuning**: per the operator's deferred gap in [[golden_state_2026_05_16_v5]] and CLAUDE.md §"Known unresolved gaps", there is **no clean Workshop config for BaconZombies HP**. The two viable paths are (a) GM per-session adjustments or (b) a Workbench bridge mod that overrides `SCR_DamageManagerComponent` values on the zombie prefabs. `TaticalForge - BaconZombies` (`65B531A64D318029`) adds respawn/mutation features but does NOT add HP tuning.

## 4. Operator usage

**In-game**:
- **Game Master**: Entity Browser → search "Zombie" or filter by the BaconZombies faction header → spawn individual zombies or pre-built groups directly
- **COE2 enemy selection**: at scenario start, pick the BaconZombies faction string in COE2's faction picker (or rely on the SDRC `fallbackEnemyFaction` if the primary enemy faction's catalog is empty)
- **Group spawns**: SDRC's `G_ZOMBIE_SMALL/MEDIUM/LARGE` buckets are consumed by the SDRC dynamic difficulty pipeline once the operator selects a zombie-themed scenario configuration

**Keybinds**: none mod-specific.

**Chat / admin**: none.

## 5. Compatibility & load order

- **Load order layer**: **L6** (faction packs) per [[golden_state_2026_05_16_v5]] iter3 table.
- **Must load AFTER**: nothing in current stack (no declared hard deps beyond base game).
- **Must load BEFORE**: SDRC framework consumers (`SHSScenarioFramework` at L11) that scan for zombie groups at scenario init. Since SDRC is at L11 and BaconZombies is at L6, the L6→L11 ordering is satisfied by the layer scheme.
- **Conflicts with**: no known conflicts. Coexists with Arma2Factions, DarkGruFactions — separate faction registration namespaces.
- **Synergies with**: `SHSScenarioFramework` (consumes BaconZombies groups via `dc_enemyList`), `TaticalForge - BaconZombies` (`65B531A64D318029` — respawn/mutation overlay, NOT currently installed).

## 6. Performance impact

Unknown — verification pending next deployed boot. Faction packs at L6 are typically cheap at idle (no AI overlay, no per-tick scripts) but zombie behavior tends to involve high-density swarms, which can elevate AI tick cost on the L9 overlay layer (CRX EAI). Watch for AI density spikes on monitor #2 (PEAK density alert).

## 7. Known issues / landmines

- **HP-tuning gap (deferred)** — no in-mod config for zombie HP/damage. See §3.
- **G_ZOMBIE_* may stay at 0 if mod folder name doesn't match SDRC's expected naming convention.** Per [[golden_state_2026_05_16_v5]] verification gate #4, this is one of the success signals for the iter3 boot. If the lists stay at 0 post-boot, SDRC isn't discovering the BaconZombies groups — likely because group prefab names don't match SDRC's regex. Workaround: explicitly enumerate group prefabs in `dc_enemyList.json` overrides.
- **Faction-perception spam** likely. CLAUDE.md § "Cosmetic noise" notes faction-perception NULL derefs fire whenever an unarmed character has no disguise faction; zombies are typically unarmed character prefabs so expect elevated `SCR_NotificationsLogDisplay has duplicate notification info key` and `[FACTION] No weapon, disguise faction = NULL` rates. Non-fatal.

## 8. Extending / modding

_N/A_ — faction packs are typically consumed, not extended.

If HP-tuning becomes necessary, the path is a Workbench bridge mod that inherits each BaconZombies character prefab and overrides `SCR_DamageManagerComponent.MaxHealth` and/or `SCR_HitZone` parameters. ~30 min per character variant.

## 9. Changelog / verified state

- **Installed version**: `version: ""` (unpinned per WCS_Earplugs 1.0.4 landmine convention).
- **Declared in `serverconfig-deployed.json`**: yes (added 2026-05-15/16 in iter3 — see [[golden_state_2026_05_16_v5]]).
- **Declared in `serverConfig.json` (local)**: no.
- **Last clean boot**: pre-verification — verification gate #4 in [[golden_state_2026_05_16_v5]] is "SDRC G_ZOMBIE_SMALL/MEDIUM/LARGE lists populate non-zero".

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/622120A5448725E3)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/622120A5448725E3/changelog)
- **Companion / consumer docs**:
  - `mod_docs/SHSScenarioFramework.md` — SDRC controller that consumes BaconZombies groups
  - `mod_docs/COE2_-_Combat_Ops_Enhanced_2.md` — scenario that surfaces zombie factions via the COE2 faction picker
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 rationale + verification gates
