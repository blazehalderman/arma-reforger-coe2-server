---
workshop_id: "61957C5C6FB7A773"
workshop_url: https://reforger.armaplatform.com/workshop/61957C5C6FB7A773
version: "0.7.12"
author: "Colton1070"
load_order_layer: L8
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "629B2BA37EFFD577 # WCS_Armaments"
  - "64EE818E08AFCF94 # MFDFramework"
  - "66DF6C37335B0554 # AHC Fuel Systems"
reverse_deps: []
related_memories: []
folder: "H-47Chinook_61957C5C6FB7A773"
license: "APL-SA (Arma Public License Share Alike)"
---

# H-47Chinook

> **One-line role**: heavy tandem-rotor transport — CH-47F / MH-47G / RAF HC.5 Chinook variants, primary heavy-lift insertion platform. Pre-release / "subject to bugs" per author.

## 1. Overview

The Chinook is the **heavy-lift transport** of the stack — tandem rotors, very large troop/cargo bay, slow but high payload. Three real-world variants are shipped. Notably author-flagged as **"subject to bugs"** / pre-release at v0.7.12 — least mature heli mod in the stack. APL-SA license (most permissive of any heli mod here).

## 2. Functionality / Features

**Variants shipped** (per Workshop):
- **CH-47F Chinook** — U.S. Army baseline transport
- **MH-47G** — 160th SOAR special-ops variant (typically: terrain-following radar, FLIR, in-flight refueling probe, extended range)
- **RAF HC.5** — British variant
- **Ramp gun variant** — adds rear-ramp-mounted defensive weapon (M134 or similar; weapon mount + crew position)

**Weapon loadout**: defensive only — ramp gun on the dedicated variant; standard door gun stations on other variants are not documented in detail on Workshop.

**Crew compartments**: 2-seat cockpit (pilot + copilot) + 1-2 door/ramp gunner stations + large troop bay (Chinook real-world capacity is 33-55 troops — exact in-mod capacity not specified, but expect 24-30+ passenger seats).

**Special features**: tandem-rotor flight model; very high lift; pre-release status means flight model + cargo behavior may need patches.

## 3. Configuration

**Config files**: none in `profile_new/profile/H-47Chinook/` — content-only mod.

**Tunable keys**: _N/A_

## 4. Operator usage

**In-game (Game Master)**:
1. GM Entity Browser → search "CH-47" / "Chinook" / "MH-47" / "HC.5"
2. Pick variant matching mission (CH-47F = standard, MH-47G = SOAR night ops, HC.5 = UK-themed scenarios)
3. Crew: 2 pilots minimum, +1 ramp gunner on armed variant
4. Spawn passengers separately or load already-spawned troops

**Keybinds**: standard vanilla heli flight (tandem rotor behavior handled by engine + mod).

## 5. Compatibility & load order

- **Load order layer**: **L8** (vehicle/weapon content packs).
- **Must load after**: `WCS_Armaments`, `MFDFramework`, `AHC Fuel Systems` (`66DF6C37335B0554` — hard dep, not in current `mods[]` arrays per frontmatter "not in any config"; likely transitively present or worth verifying).
- **Must load before**: any future Chinook DarcChopper compat shim.
- **Conflicts with**: none documented.
- **Synergies with**: `MFDFramework` (cockpit MFDs), `CatchaRide` (passenger seating UX).
- **Dep verification note**: AHC Fuel Systems (`66DF6C37335B0554`) is the surprising dep here — frontmatter scan shows it's "not in any config", meaning either it's a soft dep, on-disk-but-undeclared, or its functionality is gated. Worth verifying in `addon.gproj` if Chinook spawn ever fails.

## 6. Performance impact

Largest physical heli in the stack (tandem rotors = 2 rotor physics bodies). Largest passenger capacity = potentially many AI agents loaded at once. Otherwise vanilla cost profile.

## 7. Known issues / landmines

- **Author-declared pre-release** — "subject to bugs" stated on Workshop page. Treat as not-fully-stable. If unusual behavior is observed (spawn glitches, rotor anomaly, ramp-gun crashes), check Workshop changelog and Discord first before assuming local config issue.
- No documented incidents on this stack beyond the general pre-release caveat.

## 8. Extending / modding — DarcChopper integration

**Status**: ❌ **NO published DarcChopper compat shim exists for Chinook.** Custom Workbench shim required (procedure in `mod_docs/DarcChopper.md` §8 Option B + `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 2).

**Per-airframe parameter recommendations** (verbatim from extension plan):

| Param | Value |
|---|---|
| RotorForce0 / 1 | very high lift (tandem rotors — heaviest airframe in stack) |
| Speed Min/Max | 25 / 65 m/s |
| Fly Height Low/High | 100 / 250 m |
| Rocket Prefab | _none_ — no offensive role |
| Rocket Count | 0 |
| Enemy Search Type | `NONE` (no offensive role) |
| Faction | `US` default; override per scenario (UK for HC.5) |

**Build priority**: ranked **#6 (last)** by ROI in the extension plan — *"pure transport. Lowest ROI for SDRC_ChopperComp (no rockets to configure); only useful if you want AI-piloted Chinook waypoint runs."* Build only for AI-piloted insertion mission scenarios.

**Estimated build time**: 1-2h.

## 9. Changelog / verified state

- **Installed version**: 0.7.12 (pre-release)
- **Folder**: `profile_new/addons/H-47Chinook_61957C5C6FB7A773`
- **Last clean boot**: continuously loaded in golden state 2026-05-16 v5

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/61957C5C6FB7A773)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/61957C5C6FB7A773/changelog)
- Related extension plan: `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md`
- Framework consumer: `mod_docs/DarcChopper.md` §8
