---
workshop_id: "661B062B26BDB12F"
workshop_url: https://reforger.armaplatform.com/workshop/661B062B26BDB12F
version: "1.0.5"
author: ""
load_order_layer: L10
status: removed
last_verified: 2026-05-17
removed_date: 2026-05-17
removal_snapshot: "state_snapshots/2026-05-17_00-09-07_pre-catcharide-removal-2026-05-17"
declared_in: []
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps: []
related_memories: []
folder: "(deleted 2026-05-17)"
---

# CatchaRide — REMOVED 2026-05-17

> **One-line role** (historical): added exterior passenger seats atop armored vehicles (Bradley, M1 Abrams, T-72, BRDM-2, BTR-70, LAV-25) so players could ride along on top.

> **REMOVAL REASON**: identified as the highest-confidence root cause of the AI vehicle honk-stuck symptom. Author's own Workshop roadmap admits the AI seat-priority bug ("Prevent AI from prioritizing exterior seats over interior seats"). Removed from both serverConfig.json + serverconfig-deployed.json and folder deleted from `profile_new/addons/` per the folder-presence landmine. See `mod_docs/_asks/2026-05-16_ai-vehicle-honk-stuck-investigation.md` for the multi-agent investigation that identified it. Re-add only after the author ships the "AI prioritizes interior seats" fix (currently roadmap, no ETA).


## 1. Overview

Player-facing QoL mod that injects exterior passenger seat slots into specific armored-vehicle prefabs, letting players mount the hull as visible riders. Cosmetic / mounted-infantry roleplay.

**WARNING**: this is NOT a "hail a ride" mod. Earlier doc version (pre-2026-05-16) described it incorrectly. The actual scope is seat-slot injection on a specific allow-list of armored vehicles — verified via Workshop description 2026-05-16.

## 2. Functionality / Features

- Injects exterior passenger seats on the following base prefabs (per Workshop description):
  - M1 Abrams
  - **M2 Bradley** (and any reskin that inherits from it — e.g. HorsemansBlackBradley)
  - T-72
  - BRDM-2
  - BTR-70
  - LAV-25
- Seats are accessible via standard vehicle-mount action
- Texture-light / script-light mod

## 3. Configuration

_No config file._

## 4. Operator usage

Player-facing. Player walks up to a supported vehicle, uses standard mount action, selects the exterior seat. No operator action required to enable/disable per-player.

## 5. Compatibility & load order

- **Load order layer**: **L10** (QoL overlay).
- **Inherits to reskin chain**: any vehicle reskin inheriting from a CatchaRide-patched base prefab (e.g. HorsemansBlackBradley → M2 Bradley) also gets the exterior seats. May not be desired for all reskins.

## 6. Performance impact

Idle. Negligible per-mount cost.

## 7. Known issues / landmines

- 🛑 **AI seat-priority bug** — author's own roadmap on the [Workshop page](https://reforger.armaplatform.com/workshop/661B062B26BDB12F) acknowledges: *"Prevent AI from prioritizing exterior seats over interior seats when ordered to mount a vehicle."*
- **Symptom**: when an AI squad is ordered to mount a CatchaRide-patched vehicle, the AI driver pathfinding can land in the new exterior seat instead of the actual driver compartment. The vehicle ends up without a driver. The squad leader then honks the horn endlessly waiting for the missing crew, and the vehicle gets stuck in place.
- **Affected vehicles**: all the prefabs listed in §2, PLUS any reskin that inherits from them (HorsemansBlackBradley).
- **Operator-reported 2026-05-16**: "AI when in vehicles honk the horn endlessly, and repeatedly get stuck" — see [`_asks/2026-05-16_ai-vehicle-honk-stuck-investigation.md`](_asks/2026-05-16_ai-vehicle-honk-stuck-investigation.md) for full investigation.
- **Mitigation A** (full disable; A/B test): remove from `serverConfig.json` `mods[]` AND DELETE the `profile_new/addons/CatchaRide_661B062B26BDB12F/` folder (folder-presence landmine — removing from `mods[]` alone doesn't stop script compile per CLAUDE.md "Folder-presence triggers script execution" landmine).
- **Mitigation B** (wait for upstream): monitor [Workshop changelog](https://reforger.armaplatform.com/workshop/661B062B26BDB12F/changelog) for a release past v1.0.5 that ships the "AI prioritizes interior seats" fix. Author has committed to it on the roadmap; no ETA.
- **Mitigation C** (operator-side workaround): explicitly assign AI driver to interior seat via GM panel before issuing move orders. Tedious; not viable for SDRC/COE2 auto-spawned patrols.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: 1.0.5
- **Last clean boot**: 2026-05-16

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/661B062B26BDB12F)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/661B062B26BDB12F/changelog)
- Related ask: [`_asks/2026-05-16_ai-vehicle-honk-stuck-investigation.md`](_asks/2026-05-16_ai-vehicle-honk-stuck-investigation.md)
- Related landmine: CLAUDE.md § "Landmines discovered 2026-05-13" — folder-presence triggers script compilation
