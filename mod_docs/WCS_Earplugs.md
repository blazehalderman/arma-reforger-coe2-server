---
workshop_id: "612F512CD4CB21D5"
workshop_url: https://reforger.armaplatform.com/workshop/612F512CD4CB21D5
version: "6.0.2"
author: "Worst Case Scenario (Ronno, Cyborgmatt, AkiraSeki, Tonimontana, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps: []
related_memories: []
folder: "WCS_Earplugs_612F512CD4CB21D5"
serverconfig_version: ""
---

# WCS_Earplugs

> **One-line role**: player-keybind toggle to attenuate combat audio (full ↔ reduced volume) — tiny standalone QoL mod (73 KB) that is unrelated to the rest of the WCS stack despite the name prefix.

## 1. Overview

`WCS_Earplugs` is a **client-side audio toggle**: bind a key, press it to drop the gunshot/explosion volume to a preset reduced level (for stealth sections or to spare your ears in heavy firefights), press again to restore full volume. 73 KB on disk — by far the smallest WCS mod. Zero non-base deps.

**Operator-side history makes this mod load-bearing**: see [[CLAUDE.md]] §"Landmines discovered 2026-05-13" → "WCS_Earplugs version-pin → 404 → Unable to initialize Enfusion" — pinning `version: "1.0.4"` killed boot 2026-05-13 because Workshop only ships 6.0.2. The error cascaded into the misleading `Game addon '58D0FB3206B6F859' not found` (looks like the base game is missing — it isn't; it's any failed dep download). **Always use `version: ""` for this mod.** Verified current `serverConfig.json` declares it as `version: ""` correctly.

## 2. Functionality / Features

- Single keybind: toggle audio between full-intensity and a predefined reduced level
- Smooth audio transition (not abrupt)
- Useful for: stealth sections, fortified-position shooting, sniper roleplay, accessibility
- Zero scripts in `addon.gproj` Dependencies beyond base — pure standalone

## 3. Configuration

**Config files**: none in `$profile:/`. Per-client keybind is set via in-game settings (Options → Controls → search "earplugs").

_N/A_ — no server-side tunable keys.

## 4. Operator usage

**In-game**:
1. Open Options → Controls
2. Search "earplugs" or scroll to the WCS_Earplugs binding section
3. Bind a key (no default — operator chooses)
4. In-mission: press the bound key to toggle

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content cluster) per `MASTER_OBJECTIVE.md`. Technically it's a standalone QoL with no WCS deps, but lives in the WCS layer for grouping.
- **Must load before**: nothing.
- **Must load after**: base game.
- **Conflicts with**: **`RealismOverhaul-Sounds`** (deployed-only). RO-Sounds re-routes the audio mixer such that this mod's attenuation envelope only lasts ~1 second instead of indefinitely. Fix: install [[Fix_RealismSounds_WCS-Earplugs]] (`670E8DD9DA6ADF59`) — a purpose-built bridge mod added in deployed iter3 per [[CLAUDE.md]] §"State summary as of 2026-05-16" (*"Fix_RealismSounds_WCS-Earplugs ... purpose-built fix for the RO-Sounds+WCS_Earplugs mixer conflict (1-sec earplug fail)"*).
- **Synergies with**: [[WCS_Sounds]] (the mixer it operates on).

## 6. Performance impact

Zero. Single keybind action; no per-tick cost.

## 7. Known issues / landmines

- **Version pinning is a boot-killing landmine** — per [[CLAUDE.md]] §"WCS_Earplugs version-pin → 404 → 'Unable to initialize Enfusion'": pinning `version: "1.0.4"` in `serverConfig.json` produces an HTTP 404 from the Workshop backend (Workshop only ships 6.0.2), which cascades into `Game addon '58D0FB3206B6F859' not found` (a misleading downstream error about the base game GUID). Wasted ~30 minutes of investigation in the original incident. **Rule: ALWAYS use empty `version: ""` for new mods unless you have a specific frozen-revision reason.** Verified live `serverConfig.json` declares it with `version: ""` correctly.
- **RO-Sounds 1-sec attenuation bug** (deployed-only) — see §5 above; fixed by `Fix_RealismSounds_WCS-Earplugs`.

## 8. Extending / modding

_N/A_ — single-purpose client mod.

## 9. Changelog / verified state

- **Installed version**: 6.0.2 (on-disk; Workshop current)
- **Folder**: `WCS_Earplugs_612F512CD4CB21D5`
- **`serverConfig.json` declaration**: `version: ""` (verified 2026-05-16)
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/612F512CD4CB21D5) — 91% rating, 1.5M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/612F512CD4CB21D5/changelog)
- [[CLAUDE.md]] §"Landmines discovered 2026-05-13" → "WCS_Earplugs version-pin → 404"
- [[CLAUDE.md]] §"State summary as of 2026-05-16" iter3 — RO-Sounds fix bridge context
- Companion: [[Fix_RealismSounds_WCS-Earplugs]] (deployed-only), [[WCS_Sounds]]
