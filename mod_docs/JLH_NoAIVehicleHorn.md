---
workshop_id: "7A19B6D4C8E23F10"
workshop_url: https://reforger.armaplatform.com/workshop/7A19B6D4C8E23F10
version: "1.0.2"
author: "Ignatius_Fenix"
load_order_layer: L9
status: active
last_verified: 2026-05-17
declared_in:
  - local
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps: []
related_memories: []
folder: "JLHNoAIVehicleHorn_7A19B6D4C8E23F10"
---

# JLH No AI Vehicle Horn

> **One-line role**: suppresses AI vehicle horn reactions while preserving normal player horn functionality. Silences the symptom of the AI honk-stuck loop without touching the root pathfinding bug.

## 1. Overview

Low-profile (393 downloads, 50% rating, 8 days old at install) standalone script mod that intercepts the AI's friendly-vehicle-passing horn reaction. Installed 2026-05-17 as a complementary fix to `[[CompetentAIDriving]]` (which addresses the root cause — the forward-reverse pathfinding stuck loop — but doesn't silence the intentional BI horn reaction itself).

**Trade-off acknowledged**: silencing the AI horn loses BI's intentional friendly-fire-avoidance design (per dev quote on [BI Feedback Tracker T177755](https://feedback.bistudio.com/T177755): *"we didn't want friendly soldiers to give up fighting when a friendly vehicle is driving by, which is why we added the car horn reaction"*). Player horn behavior preserved per the mod's own description.

## 2. Functionality / Features

- AI vehicle horn calls intercepted (suppressed / early-return).
- Player horn calls unaffected (still audible when player presses horn key).

## 3. Configuration

_No config file._ Global behavior.

## 4. Operator usage

Passive — no keybinds. Effects visible in-game: GM-spawned AI patrols with vehicles drive past silently.

## 5. Compatibility & load order

- **Load order layer**: **L9** (AI behavior overlay).
- **Insertion point**: after `[[CompetentAIDriving]]` — both target AI vehicle behavior; load order is functional grouping.
- **Complementary with**: `[[CompetentAIDriving]]` (root-cause fix for pathfinding stuck loop). JLH silences the audio symptom; CompetentAI fixes the cause.
- **No known direct conflicts** — script-only intercept, base-game-only deps.

## 6. Performance impact

Negligible — script intercept on a vanilla AI behavior tree node. No prefab override, no per-tick load.

## 7. Known issues / landmines

- **Low rating signal** (50% / 393 downloads / 8 days old at install). Low download count = low community-vetting depth. Watch for unexpected horn-related issues during play.
- **Functional loss of BI's intentional design** — AI no longer reacts to passing friendly vehicles. If this becomes noticeable as a tactical AI-coordination gap, the rollback path is to remove the mod and rely on `[[CompetentAIDriving]]` alone (the root-cause fix should make the honking less frequent even if not silent).

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 1.0.2
- **Folder**: `profile_new/addons/JLHNoAIVehicleHorn_7A19B6D4C8E23F10`
- **Last clean boot**: 2026-05-17 boot 8 (GAME at 15:13:02, arsenal 6689)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/7A19B6D4C8E23F10)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/7A19B6D4C8E23F10/changelog)
- [BI Feedback Tracker T177755](https://feedback.bistudio.com/T177755) — dev quote establishing horn-reaction intent
- Related: `[[CompetentAIDriving]]` (cause-fix complement)
- Prior investigation: `mod_docs/_asks/2026-05-16_ai-vehicle-honk-stuck-investigation.md`
