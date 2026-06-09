---
workshop_id: "6884BEDB4F582595"
workshop_url: https://reforger.armaplatform.com/workshop/6884BEDB4F582595
version: "1.0.1"
author: "Tr1gEr123"
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
folder: "AIMortarFireSupportSystem_6884BEDB4F582595"
---

# AIMortarFireSupportSystem

> **One-line role**: GM-placeable "Auto Mortar" entity that engages enemies autonomously via networked targeting once placed with a gunner and an ammo source.

## 1. Overview

A drop-in autonomous indirect-fire asset. The operator (or scenario author) spawns an **"Auto Mortar"** entity (under **USSR Faction → Vehicles** in the GM entity browser), assigns an AI gunner, and places an ammunition source nearby. Once positioned, the mortar engages enemies autonomously — no manual fire orders.

Targeting works via **networked observation**: any friendly unit within radio range that spots an enemy triggers automatic engagement. The system applies "realistic dispersion" for natural inaccuracy, and prioritises targets by distance and visual confirmation. This is the **operator/scenario** indirect-fire option (vs `AiMortarPve` which is the **autonomous-against-players** PvE variant — see that doc).

## 2. Functionality / Features

- **Auto Mortar entity** spawnable from GM under USSR → Vehicles
- **AI gunner required** — placed in mortar via GM crew assignment
- **Ammo source required nearby** — vanilla ammo crate or Universal Arsenal
- **Networked targeting** — engages enemies spotted by any friendly within radio range
- **Realistic dispersion** — built-in inaccuracy simulating real mortar spread
- **Distance + visual prioritisation** — closer / better-confirmed targets first
- **No manual fire orders needed** once setup is complete (autonomous fire control)

## 3. Configuration

**Config files**: none documented in `$profile:/`. The mod ships as a script package with the Auto Mortar prefab embedded. Tunables (dispersion, range, prioritisation thresholds) are baked into the prefab/scripts — not operator-tunable at runtime.

| Key | Path | Default | Current | Effect |
|---|---|---|---|---|
| _N/A — no runtime config surface_ | — | — | — | tunables baked into prefab |

## 4. Operator usage

**In-game (Game Master)**:
1. Open GM panel (`M`)
2. Entity Browser → Faction filter: **USSR** → Vehicles → **"Auto Mortar"**
3. Place the mortar
4. Right-click mortar → assign AI gunner
5. Place ammo source nearby (vanilla ammo crate, Universal Arsenal, or mortar shell pile)
6. System engages autonomously once a friendly within radio range spots an enemy

**Keybinds**: none beyond standard GM UX.

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L9** (AI overlays — sister AI mod, GM-placeable)
- **Must load after**: nothing required by gproj (base-game only); needs faction packs at L6 if operator wants non-USSR mortars (but spawned entity is hardcoded under USSR)
- **Must load before**: scenario controllers at L11 — entity must be registered before scenarios reference it
- **Synergies with**:
  - **CRX EnfusionAI** — CRX tunes the AI gunner's perception/aim modifiers (Aim_Accuracy_Error_Modifier=0.8 currently affects mortar gunner)
  - **AiMortarPve** — sister mod with inverse polarity (this one engages enemies via friendly spotters; AiMortarPve engages PLAYERS via probability). Both can coexist; serve different scenario design needs.
  - **DarcChopper** — sister GM-placeable indirect-fire asset (this = mortar IDF; DarcChopper = rotary CAS)
- **Conflicts with**: none documented on this stack.

## 6. Performance impact

Per-mortar cost: 1 AI gunner's perception tick + projectile spawn cost per fire event. Networked-targeting check has to enumerate friendlies within radio range — O(N) where N = nearby friendlies. At normal scenario densities this is unmeasurable. Stress test: untested above ~6 simultaneously active Auto Mortars on this stack.

## 7. Known issues / landmines

- **Auto Mortar entity hardcoded under USSR faction**: in the GM entity browser the entity appears under USSR → Vehicles regardless of operator/player faction. Visual / RP mismatch when running US factions, but functionally identical — the mortar's targeting fires on any enemy, not by faction. Workaround: place the mortar then re-faction it via GM if visual matters.
- **Ammo source MUST be nearby** — if no ammo source within proximity radius (not documented, empirically a few meters), the mortar won't fire. Operator should verify by watching for first salvo within 30 s of enemy spotter event.
- **No documented incidents in any log to date.**

## 8. Extending / modding

_N/A_ — single-purpose autonomous-mortar entity. No extensibility surface.

## 9. Changelog / verified state

- **Installed version**: 1.0.1 (game version 1.6.0.119)
- **Workshop last modified**: 03.02.2026
- **File size**: 4.95 KB
- **Last clean boot**: continuously loaded in 2026-05-16 V5 golden state

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/6884BEDB4F582595)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/6884BEDB4F582595/changelog)
- `INDEX.md` — `ai:mortar-fire-support`
- Sister doc: `AiMortarPve.md` (the autonomous-against-players variant)
