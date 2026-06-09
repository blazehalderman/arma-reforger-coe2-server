---
workshop_id: "65AD7C249E4ECDFB"
workshop_url: https://reforger.armaplatform.com/workshop/65AD7C249E4ECDFB
version: "1.5.18"
author: "acemod"
load_order_layer: L2
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
  - "65AD7D0D9941A380 # ACE Core Dev"
reverse_deps:
  - "5ED61DC0AFE17E8E # Kex Scenario Core"
related_memories: []
folder: "ACECaptivesDev_65AD7C249E4ECDFB"
---

# ACE Captives Dev

> **One-line role**: ACE Dev-branch surrender / zip-cuff / captive-escort system — adds surrender via the gestures menu (F1), zip cuffs as an arsenal item, and "escort captive" + "load into vehicle" user actions.

## 1. Overview

`ACE Captives Dev` is the Dev-branch surrender-and-restraint feature mod for ACE on Reforger 1.6.0.119. Workshop description (verbatim): **"Adds the ability to surrender and adds zip cuffs to arsenal, which can be used to take a surrendered unit as captive."** Per the `addon.gproj`, it hard-deps `ACE Core Dev` (`65AD7D0D9941A380`) and the base game, and ships 13-language localization (`ACE_Captives_localization.st`). In our stack, the only declared reverse-dep is `Kex Scenario Core` — which means **Captives Dev is along for the ride because Kex pulls in the entire Dev pair**, not because operators specifically chose surrender mechanics.

Full Anvil documentation: <https://anvil.acemod.org/dev/components/captives/>

## 2. Functionality / Features

Per Anvil docs:

- **Surrender mechanic**: access via gestures radial menu (default `F1`) → select surrender action. The player's character drops to a surrendered pose.
- **Zip cuff item**: appears in arsenal under restraint items. Equipped to restrain a surrendered (or per-config, unarmed/back-approached) target.
- **Captive context-actions**:
  - **Restrain**: aim at a surrendered unit + zip cuff equipped → user action prompt.
  - **Release**: user action on a captive — no item required (so admins can free without a zip-cuff inventory penalty).
  - **Escort**: user action on the captive → player tows them on foot.
  - **Load into vehicle**: door user action on a vehicle with an escorted captive → loads into a passenger seat.
- **GM context menu**: Game Master can directly toggle restrain/release on any AI or player via right-click menu (skipping the line-of-sight + item requirements).
- Localization: 13 languages (same set as ACE Core Dev).

## 3. Configuration

**Config files**: no `$profile:/` directory observed for ACE Captives Dev. **Configuration is set via the scenario's mission header**, not a separate JSON file (Anvil docs pattern).

**Mission header keys** (integer 0/1/2, applied separately to player vs AI captives per Anvil docs):

| Key | Type | Effect |
|---|---|---|
| `PlayerCaptiveRequirement` (or analogous) | int 0/1/2 | What's needed to restrain a player target: 0 = anything, 1 = unarmed OR approached from behind, 2 = must be surrendered (default) |
| `AICaptiveRequirement` (analogous) | int 0/1/2 | Same scheme for AI targets |

Per Anvil: "settings control whether taking captives requires: Surrender (default), Target being unarmed, Approaching from behind for armed units."

Note: COE2 / Kex Scenario Core's mission header is the integration point — verify those mod's mission header before assuming defaults. Operator has not edited captive thresholds (verified no scenario override files in `$profile:/`).

## 4. Operator usage

**In-game (any player)**:
- **`F1`** (gestures) → scroll to "Surrender" → action plays. Other players see the surrender pose, can restrain.
- **To capture**: equip zip cuffs from arsenal → aim at surrendered (or per-config valid) target → user action prompt → confirm.
- **To escort**: walk up to a captive → user action "Escort" → walk anywhere with them following.
- **To load into vehicle**: get the captive near a vehicle door → use the door's user-action menu.

**Game Master**:
- Right-click any AI/player → context menu has Restrain / Release options (bypasses item + line-of-sight requirements).

**Keybinds** (default):
- `F1` — gestures menu (Surrender is one option here)
- No dedicated Captives keybind — all actions go through user-action prompts or GM context menu.

**Admin commands**: none specific to Captives.

## 5. Compatibility & load order

- **Load order layer**: **L2** (ACE sub-modules) per `MASTER_OBJECTIVE.md`.
- **Must load before**: `Kex Scenario Core` → `COE2` (transitive consumers).
- **Must load after**: `ACE Core Dev` (gproj-verified hard dep at `dev.gproj` line 6: `"65AD7D0D9941A380"`).
- **Conflicts with**: stable ACE Captives (if it existed as a Reforger sister mod under a different GUID); generally avoid stacking captive systems.
- **Synergies with**: ACE Core Dev (required); naturally pairs with any medical/respawn mod operator might add (though none currently active).

## 6. Performance impact

- Boot cost: 1.49 MB pak (tiny).
- Runtime: per-character surrender state + a per-captive escort tether. Negligible on this stack — captives are rare gameplay events; not on the AI-density hot path.

## 7. Known issues / landmines

- **Same Dev-branch caveats as ACE Core Dev**: breaking changes can ship without warning. Pin `version: ""` and verify after Steam pulls.
- **Coexistence with stable ACE Core** (if reinstated): same conflict surface as ACE Core Dev — script-symbol overlap. Don't stack.
- **Mission-header config dependency**: if a future scenario doesn't expose the captive-requirement keys, behavior reverts to defaults (Surrender required). Not a bug, just an integration gap to remember when switching scenarios.

## 8. Extending / modding

- ACE Anvil is open-source GPLv2 — extension by sibling component is the canonical pattern.
- Upstream: <https://github.com/acemod> (Anvil project).

## 9. Changelog / verified state

- **Installed version**: 1.5.18 (per `dev.gproj` + `ServerData.json revision.version`; folder `ACECaptivesDev_65AD7C249E4ECDFB`)
- **Folder**: `ACECaptivesDev_65AD7C249E4ECDFB` (Workbench Dev artifact — `dev.gproj` not `addon.gproj`; `data.pak` 1.49 MB)
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot; re-restored 2026-05-14 evening with the rest of the Dev pair when 121-mod state was reverted.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/65AD7C249E4ECDFB) — 680,862 downloads, 90% rating
- [Workshop changelog](https://reforger.armaplatform.com/workshop/65AD7C249E4ECDFB/changelog)
- [Anvil docs — ACE Captives (Dev)](https://anvil.acemod.org/dev/components/captives/) — keybinds + mission-header config schema
- [acemod GitHub org](https://github.com/acemod)
- License: GNU GPLv2+ (same as ACE Core Dev)
- CLAUDE.md "What this is" → declared part of the minimal ACE Dev pair
- Related memories: `[[golden_state_2026_05_16_v5]]`, `[[ACE_Core_Dev]]`
