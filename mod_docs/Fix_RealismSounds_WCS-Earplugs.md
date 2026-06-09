---
workshop_id: "670E8DD9DA6ADF59"
workshop_url: https://reforger.armaplatform.com/workshop/670E8DD9DA6ADF59
version: ""
author: ""
load_order_layer: L10
status: active
last_verified: 2026-05-17
declared_in:
  - local
  - deployed
local_install_date: 2026-05-17
local_install_snapshot: "state_snapshots/2026-05-17_00-09-51_pre-competent-ai-driving-install-2026-05-17"
local_install_rationale: "Mod overlap audit 2026-05-17 confirmed the WCS_Earplugs + RealismOverhaulSounds 1-sec attenuation bug was live on local because the fix was deployed-only. Pure forward additive change — added to local serverConfig at L10 position 99 (after RealismOverhaulSounds at 98)."
hard_deps: []
reverse_deps: []
related_memories:
  - golden_state_2026_05_16_v5.md
folder: ""
---

# Fix_RealismSounds_WCS-Earplugs

> **One-line role**: **purpose-built compatibility fix** for the audio-mixer conflict between `RealismOverhaul-Sounds` and `WCS_Earplugs` that caused the "earplug fails after 1 second" symptom.

## 1. Overview

Per CLAUDE.md § "State summary 2026-05-16 V5" iter3 table verbatim: "Fix_RealismSounds_WCS-Earplugs: purpose-built fix for the RO-Sounds+WCS_Earplugs mixer conflict (1-sec earplug fail)". Without this fix, pressing the earplug keybind temporarily activated the noise dampening, but the RealismOverhaul-Sounds audio mixer **overrode the dampening within ~1 second**, returning the player to unattenuated audio levels and defeating the entire purpose of `WCS_Earplugs`. This shim restores the dampening persistence by re-applying or anchoring the earplug mixer state above the RO-Sounds override priority.

## 2. Functionality / Features

- **Re-applies WCS_Earplugs audio dampening** after RealismOverhaul-Sounds attempts to override the mixer
- Active **only when both** `RealismOverhaul-Sounds` AND `WCS_Earplugs` are present in the stack (no-op without one)
- No new content (sounds, prefabs, UI) — pure compat-shim behavior

## 3. Configuration

**Config files**: none under `$profile:/` expected — purpose-built fixes typically have no tunables.

**Tunable keys**: none.

## 4. Operator usage

**In-game**: transparent. The operator continues to use the **WCS_Earplugs** keybind as normal (see `mod_docs/WCS_Earplugs.md`). The fix mod's only job is to make that keybind's effect persist across the RO-Sounds mixer cycle.

**Verification**: per [[golden_state_2026_05_16_v5]] gate #6 — "WCS_Earplugs persistence: pressed earplug stays active beyond 1 second".

**Keybinds / admin**: none mod-specific. Earplug toggle is WCS_Earplugs' keybind.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio/visual overlays) per [[golden_state_2026_05_16_v5]] iter3 table.
- **Must load AFTER**:
  - `WCS_Earplugs` — the upstream functionality this is fixing
  - `RealismOverhaulSounds` — the conflicting mixer this shim works around
  - Both at L10 (or earlier) → the shim must be **last among the three** in the mods[] array to apply its override on top.
- **Must load BEFORE**: nothing.
- **Conflicts with**: nothing known.
- **Synergies with**: requires BOTH `WCS_Earplugs` and `RealismOverhaulSounds` to be useful. Without one, this mod is a silent no-op.

## 6. Performance impact

Negligible — single-purpose audio-mixer override.

## 7. Known issues / landmines

- **Order matters**: if `Fix_RealismSounds_WCS-Earplugs` loads BEFORE `RealismOverhaulSounds` in the mods[] array, RO-Sounds wins the tiebreaker and the 1-sec earplug bug returns. Verify mods[] array position post-deploy.
- **WCS_Earplugs version-pin landmine**: per CLAUDE.md § "Landmines discovered 2026-05-13", `WCS_Earplugs` was previously pinned to `1.0.4` which 404'd on Workshop and cascaded to `Unable to initialize the game`. Keep `version: ""` for BOTH WCS_Earplugs and this fix mod.

## 8. Extending / modding

_N/A_ — single-purpose shim.

## 9. Changelog / verified state

- **Installed version**: `version: ""`.
- **Declared in `serverconfig-deployed.json`**: yes (iter3 2026-05-15/16).
- **Declared in `serverConfig.json` (local)**: no.
- **Last clean boot**: pre-verification — gate #6 in [[golden_state_2026_05_16_v5]] is "WCS_Earplugs persistence: pressed earplug stays active beyond 1 second".

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/670E8DD9DA6ADF59)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/670E8DD9DA6ADF59/changelog)
- **Companion docs**:
  - `mod_docs/WCS_Earplugs.md` — upstream functionality being fixed
  - `mod_docs/RealismOverhaulSounds.md` — conflicting mixer this shim works around
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 rationale + verification gate #6
