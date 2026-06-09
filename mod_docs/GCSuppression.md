---
workshop_id: "684CE8AA3B1D6573"
workshop_url: https://reforger.armaplatform.com/workshop/684CE8AA3B1D6573
version: ""
author: ""
load_order_layer: L10
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

# GCSuppression

> **One-line role**: **cinematic suppression** — caliber/speed/cover-aware flinch effects plus visual feedback (vignette + chromatic aberration) when near-misses crack past players.

## 1. Overview

Per [[golden_state_2026_05_16_v5]] iter3 table verbatim: "Cinematic suppression — caliber/speed/cover-aware flinch + vignette + chromatic aberration". A modern suppression overlay added in iter3 alongside `HushedWoodlands` and `BattlefieldAmbienceMod` to round out the atmospheric immersion stack. Sup­pression effects are gated by the projectile's caliber, speed, and whether the player is behind cover, so a near-miss from a .50 cal feels meaningfully different from a 5.56 zip.

## 2. Functionality / Features

- **Flinch animation** on near-miss (camera shake / weapon dip)
- **Vignette darkening** when under sustained fire
- **Chromatic aberration** as a secondary suppression visual indicator
- **Caliber-aware**: heavier rounds produce stronger effects
- **Speed-aware**: supersonic vs subsonic near-misses produce distinct cues
- **Cover-aware**: effects attenuate when the player is behind ballistic cover
- Client-side visual/animation overlay — does NOT modify AI behavior or projectile physics

## 3. Configuration

**Config files**: likely under `$profile:/GCSuppression/` once mod boots; unverified pending first deployed boot.

**Tunable keys** (expected — verify after first boot):

| Key | Path | Default | Effect (expected) |
|---|---|---|---|
| `flinchIntensity` | `$profile:/GCSuppression/<config>.json` | unknown | how much the camera/weapon dips on near-miss |
| `vignetteStrength` | same | unknown | edge-darkening strength |
| `chromaticAberration` | same | unknown | colored-edge artifact strength |
| `nearMissDistance` | same | unknown | meters within which an enemy round triggers suppression |
| `coverAttenuation` | same | unknown | how much cover reduces the effect |

## 4. Operator usage

**In-game**: automatic — fires whenever a hostile projectile passes near a player. No keybinds.

**Disable per-player**: if a player complains about motion sickness from the camera shake, point them at the config file. No mod-side disable command known.

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio/visual overlays) per [[golden_state_2026_05_16_v5]] iter3 table.
- **Must load AFTER**: nothing required.
- **Must load BEFORE**: nothing required.
- **Conflicts with**: any other suppression-flinch mod (only run one). CRX Enfusion AI's suppression model affects AI behavior — orthogonal to this mod's client-side visual layer, so no conflict expected.
- **Synergies with**: `HushedWoodlands`, `BattlefieldAmbienceMod`, `AtmosphericWeatherMod` — full iter3 atmospheric immersion stack.

## 6. Performance impact

Client-side post-processing (vignette + chromatic aberration) carries some GPU cost on weak hardware but is negligible on modern GPUs. Server-side impact: zero (effects are purely client-rendered).

## 7. Known issues / landmines

- **Motion sickness** for some players from the camera-shake flinch. Configurable if the operator gets complaints.
- **Sustained-fire vignette can occlude HUD** during prolonged engagements. Verify post-deploy.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: `version: ""`.
- **Declared in `serverconfig-deployed.json`**: yes (iter3 2026-05-15/16).
- **Declared in `serverConfig.json` (local)**: no.
- **Last clean boot**: pre-verification — gate #5 in [[golden_state_2026_05_16_v5]] is "New atmospheric mod activity: BattlefieldAmbience location triggers + GCSuppression flinch events".

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/684CE8AA3B1D6573)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/684CE8AA3B1D6573/changelog)
- **Companion docs**:
  - `mod_docs/BattlefieldAmbienceMod.md`, `mod_docs/HushedWoodlands.md`, `mod_docs/AtmosphericWeatherMod.md` — iter3 atmospheric immersion siblings
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 rationale + verification gate #5
