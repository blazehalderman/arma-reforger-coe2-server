---
workshop_id: "68FCF11534562F2E"
workshop_url: https://reforger.armaplatform.com/workshop/68FCF11534562F2E
version: "1.0.0"
author: "Doggo5852"
load_order_layer: L9
status: active
last_verified: 2026-05-17
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps: []
related_memories: []
folder: "(Steam will pull on next boot — added 2026-05-17)"
install_snapshot: "state_snapshots/2026-05-17_00-09-51_pre-competent-ai-driving-install-2026-05-17"
---

# CompetentAIDriving

> **One-line role**: forces AI vehicle drivers to take wider turns to break the vanilla forward-reverse pathfinding loop. Targets larger vehicles only.

## 1. Overview

Small (~2.28 KB) script-only mod published 2026-03-30. Patches vanilla Reforger AI vehicle pathing so larger vehicles take wider turns when navigating dense terrain, preventing the well-known "forward-reverse oscillation loop" that traps AI drivers when they hit a turning constraint. **Does NOT fix the AI horn-honking** — that is by-design vanilla friendly-avoidance per BI dev quote on T177755.

## 2. Functionality / Features

- Forces wider turns on AI-driven larger vehicles to prevent the forward-reverse stuck loop
- Affects "larger vehicles" only (author scope note — exact threshold not documented)
- Pure script patch — no content, no prefab overrides
- Engine v1.6.0.119 compatible
- APL license (standard)

## 3. Configuration

_No config file._ The fix is hardcoded; no operator tunables.

## 4. Operator usage

Server-side; no player action. AI drivers will simply navigate more competently around obstacles.

## 5. Compatibility & load order

- **Load order layer**: **L9** (AI overlays). Placed after CRX_EnfusionAI.
- **Hard deps**: base game only.
- **Reverse deps**: none.
- **Conflicts with**: no documented conflicts.
- **Interacts with**:
  - **CRX_EnfusionAI** — CRX handles AI behavior/perception/formation. This mod handles vehicle pathfinding. Different surfaces; no conflict.
  - **CatchaRide** — REMOVED 2026-05-17. CatchaRide was the higher-impact root cause; this mod addresses the orthogonal forward-reverse loop.
  - **SDRC vehicle bucket population** — irrelevant; this is engine-level driver behavior, not vehicle selection.

## 6. Performance impact

Negligible — 2.28 KB script patch, executes only on AI vehicle path replan.

## 7. Known issues / landmines

- Only documented limitation: **"affects larger vehicles only (for now)"** — author has stubbed potential expansion. If you see smaller AI vehicles still stuck-looping, that's the unfixed scope.
- v1.0.0 has no changelog entries; no history of regressions.
- 128 downloads at install time, 100% rating — small community footprint, low risk-of-abandonment unknown.

## 8. Extending / modding

_N/A_ — pure script patch.

## 9. Changelog / verified state

- **Installed version**: 1.0.0 (Workshop version as of 2026-05-17)
- **Install date**: 2026-05-17
- **Install snapshot**: `state_snapshots/2026-05-17_00-09-51_pre-competent-ai-driving-install-2026-05-17`
- **Boot test**: pending — operator to verify on next server start. Expected: AI vehicle convoys navigate dense terrain without forward-reverse oscillation.
- **Workshop changelog**: https://reforger.armaplatform.com/workshop/68FCF11534562F2E/changelog (none as of install)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/68FCF11534562F2E)
- Related ask: [`_asks/2026-05-16_ai-vehicle-honk-stuck-investigation.md`](_asks/2026-05-16_ai-vehicle-honk-stuck-investigation.md) — install rationale (vanilla forward-reverse loop)
- Related ask: [`_asks/2026-05-17_mod-overlap-audit.md`](_asks/2026-05-17_mod-overlap-audit.md) — confirmed install path
- BI dev quote on honk being by-design (T177755): https://feedback.bistudio.com/T177755 — this mod does NOT address honking; only the forward-reverse stuck loop
- Reforger 1.3.0.130 patch notes (the vanilla "deactivated AIs honk" fix): https://reforger.armaplatform.com/news/changelog-march-27-2025 (still in place; orthogonal to this mod)
