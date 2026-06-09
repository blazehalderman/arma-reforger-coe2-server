---
workshop_id: "631B695913C7781F"
workshop_url: https://reforger.armaplatform.com/workshop/631B695913C7781F
version: "1.6.8"
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
folder: "RealismOverhaul-Sounds_631B695913C7781F"
---

# RealismOverhaulSounds

> **One-line role**: replaces vanilla weapon / vehicle / explosion audio with high-fidelity samples + adjusts the mixer chain for realism.

## 1. Overview

Audio half of the four-part RealismOverhaul suite (Effects / Lighting / Sounds / Weather — all by the same author, all on the same `1.6.x` version cadence). Swaps in new sound samples for weapons, vehicles, explosions, footsteps, suppressor tails, and edits the audio mixer routing/attenuation.

## 2. Functionality / Features

- Replacement audio samples across all common weapon families (vanilla + RHS overlaps the WCS sound layer).
- Adjusted reverb/distance falloff curves.
- Mixer-chain edits that affect submixes used by other audio mods (the source of the WCS_Earplugs conflict, see § 7).

## 3. Configuration

_No config file._ Mixer + sample asset overrides only.

## 4. Operator usage

Passive — sounds change automatically.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio-visual overlay).
- **Synergies with**: `RealismOverhaulEffects`, `RealismOverhaulLighting`, `RealismOverhaulWeather` (suite siblings — co-deploy).
- **Conflict with `WCS_Earplugs`** — CRITICAL: this mod's mixer edits and WCS_Earplugs' attenuation system fight over the same submix. Symptom = earplugs disable / fail after ~1 second of equip. CLAUDE.md V5 § "Iter3 additive fixes" documents the resolution: install the purpose-built **`Fix_RealismSounds_WCS-Earplugs`** (`670E8DD9DA6ADF59`, deployed-only) to repair the mixer routing. See `[[Fix_RealismSounds_WCS-Earplugs]]`.

## 6. Performance impact

Audio asset memory cost (couple hundred MB of sample data). Per-tick negligible.

## 7. Known issues / landmines

**WCS_Earplugs mixer conflict** (CLAUDE.md V5 § "Iter3 additive fixes"): without the fix mod, equipping WCS earplugs sets attenuation correctly for ~1 second, then RealismOverhaul-Sounds' mixer override reasserts and earplugs lose effect. The user-facing symptom is "earplugs don't work" → players reporting blown ears next to a 50-cal. **Fix**: install `Fix_RealismSounds_WCS-Earplugs` (currently **deployed-only** — the local 103-mod baseline does not have it, so this conflict is *live on local*; if the operator uses WCS earplugs locally, install the fix in local config too).

**Stacks with `[[BattlefieldAmbienceMod]]`, `[[HushedWoodlands]]`, `[[GCSuppression]]`** (deployed-only audio additions per V5) — no documented conflict, but be alert for audible mixer fighting if ambient and overlay layers get re-tuned.

## 8. Extending / modding

_N/A_ — audio asset override pack.

## 9. Changelog / verified state

- **Installed version**: 1.6.8
- **Folder**: `profile_new/addons/RealismOverhaul-Sounds_631B695913C7781F`
- **Last clean boot**: 2026-05-16 (golden state V5)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/631B695913C7781F)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/631B695913C7781F/changelog)
- `CLAUDE.md` § "State summary as of 2026-05-16 (golden state V5)" → "Iter3 additive fixes" → WCS_Earplugs fix
- Companion fix: `[[Fix_RealismSounds_WCS-Earplugs]]`
- Suite siblings: `[[RealismOverhaulEffects]]`, `[[RealismOverhaulLighting]]`, `[[RealismOverhaulWeather]]`
