---
workshop_id: "660896EB172D4B7F"
workshop_url: https://reforger.armaplatform.com/workshop/660896EB172D4B7F
version: "1.0.3"
author: ""
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "62FCEB51DF8527B6 # <unknown framework dep>"
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps: []
related_memories: []
folder: "ImprovedBloodEffectDeluxe_660896EB172D4B7F"
---

# ImprovedBloodEffectDeluxe

> **One-line role**: replaces vanilla blood VFX with denser, more directional spray + lingering wound decals.

## 1. Overview

Blood-VFX overhaul — exit-wound sprays, lingering decals on surfaces, more visible bleed-out trails. Separate from `[[RealismOverhaulEffects]]` (which handles muzzle smoke and explosions, not blood).

## 2. Functionality / Features

- Directional blood spray on hit.
- Lingering blood pool / trail decals.
- Wound severity scales spray volume.

## 3. Configuration

_No config file._

## 4. Operator usage

Passive.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio-visual overlay).
- **One unresolved dep GUID** (`62FCEB51DF8527B6`) — listed in gproj but not currently in any active config; engine evidently resolves this OR it's a soft-dep that doesn't fail-hard. Worth a future audit but not blocking.
- **No known conflicts**.

## 6. Performance impact

Particle + decal GPU cost. No measurable framerate impact in V5.

## 7. Known issues / landmines

Unresolved dep `62FCEB51DF8527B6` — verify on next boot health-check whether this fails or gets silently satisfied by something in the addons folder. If it's a hidden hard-dep, removing the resolver would surface as a "Cannot create game" cascade.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: 1.0.3
- **Last clean boot**: 2026-05-16

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/660896EB172D4B7F)
- Related VFX: `[[RealismOverhaulEffects]]`
