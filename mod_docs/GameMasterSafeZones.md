---
workshop_id: "5CE334EA7649C7CC"
workshop_url: https://reforger.armaplatform.com/workshop/5CE334EA7649C7CC
version: "1.4.0.48"
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

# GameMasterSafeZones

> **One-line role**: lets the Game Master place no-fire / friendly-fire-disabled zones around HQs and rally points. **LOW confidence** — mod was last published for Reforger v1.4.0.48; current server is v1.6.0.119.

## 1. Overview

Per CLAUDE.md § "State summary 2026-05-16 V5" iter3 table: "GameMasterSafeZones: LOW confidence (v1.4.0.48 mod)" and [[golden_state_2026_05_16_v5]] iter3 table: "GM-placeable FF-disabled zones over HQ (v1.4.0.48 — LOW confidence, snapshot before testing)". Added experimentally to give the operator a way to stop griefer-style intra-HQ killing. The version gap (v1.4 mod on a v1.6 server) is the primary risk vector — the engine's mod-loading is lenient about version drift but the underlying APIs the mod calls into may have changed.

## 2. Functionality / Features

- **GM-placeable zones** drawn on the map that disable friendly-fire damage for entities inside the boundary
- Likely also disables explosive damage / grenade tossing inside the zone
- Visual indicator probably rendered on the map (so players know where the safe zones are)
- No persistence — zones reset when scenario restarts

## 3. Configuration

**Config files**: likely under `$profile:/GameMasterSafeZones/` once mod boots; unverified pending first boot (and pending the mod actually loading on 1.6).

**Tunable keys**: unknown.

## 4. Operator usage

**In-game (Game Master)**:
1. Open GM panel
2. Look for "Safe Zone" or similar in the GM tool palette (likely under map-overlay tools)
3. Drag a radius/polygon on the map to define the zone
4. Players inside are protected from FF damage

**Keybinds**: GM-mode default tool keybind (likely no mod-specific key).

**Admin commands**: none known.

## 5. Compatibility & load order

- **Load order layer**: **L10** (GM/admin/QoL overlays) per [[golden_state_2026_05_16_v5]] iter3 table.
- **Must load AFTER**: nothing required.
- **Must load BEFORE**: nothing required.
- **Conflicts with**: `Game_Master_Enhanced` — both extend GM functionality; verify they coexist (likely fine since safe-zones are an additive tool, not a GM core override).
- **Synergies with**: `Game_Master_Enhanced`, `ServerAdminTools` — combined admin/GM workflow.

## 6. Performance impact

Trivial — a polygon-inclusion check on damage events. Negligible at any reasonable density.

## 7. Known issues / landmines

- **VERSION DRIFT IS THE PRIMARY RISK.** Mod was last published for **v1.4.0.48**; server is **v1.6.0.119**. Possible failure modes (per `CLAUDE.md` § "Self-healing log investigation playbook" §Phase 3 hypothesis generation):
  1. **Silent script compile error** → mod loads but tool doesn't appear in GM palette. Detection: GM Entity Browser search for "Safe Zone" yields nothing.
  2. **Damage-callback API drift** → tool places zone visually but FF damage still applies. Detection: GM-place zone, have two players test-shoot each other, verify no damage.
  3. **VM Exception on boot** if the script references a now-removed engine type. Detection: `script.log` shows compile error in this mod's namespace at scenario init.
- **Snapshot before testing** per the operator's explicit gate in [[golden_state_2026_05_16_v5]]. If the mod fails the gate, restore_state and remove from deployed config.
- **No upstream patches expected** — mod author may have moved on; if it breaks, fork or remove rather than waiting for a fix.

## 8. Extending / modding

_N/A_ — operator-facing GM tool, not a framework.

## 9. Changelog / verified state

- **Installed version**: 1.4.0.48 (Workshop description target — last published version).
- **Engine version**: 1.6.0.119 (current server).
- **Version delta**: 2 major Reforger releases.
- **Declared in `serverconfig-deployed.json`**: yes (iter3 2026-05-15/16, LOW confidence).
- **Declared in `serverConfig.json` (local)**: no.
- **Last clean boot**: pre-verification.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/5CE334EA7649C7CC)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/5CE334EA7649C7CC/changelog) — check for any 1.6 compatibility update before assuming it's broken
- **Companion docs**:
  - `mod_docs/Game_Master_Enhanced.md` — GM-tooling sibling
  - `mod_docs/ServerAdminTools.md` — admin sibling
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 LOW-confidence flagging + snapshot-before-test mandate
  - `[[feedback_snapshot_before_changes]]` — snapshot mandate
