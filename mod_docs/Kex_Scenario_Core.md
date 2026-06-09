---
workshop_id: "5ED61DC0AFE17E8E"
workshop_url: https://reforger.armaplatform.com/workshop/5ED61DC0AFE17E8E
version: "0.4.27"
author: "Kexanone"
load_order_layer: L11
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "65AD7D0D9941A380 # ACE Core Dev"
  - "65AD7C249E4ECDFB # ACE Captives Dev"
reverse_deps:
  - "60926835F4A7B0CA # COE2 - Combat Ops Enhanced 2"
related_memories:
  - golden_state_2026_05_16_v5.md
  - golden_state_2026_05_14_v4.md
folder: "KexScenarioCore_5ED61DC0AFE17E8E"
---

# Kex Scenario Core

> **One-line role**: shared classes + prefabs framework for Kex-authored scenarios — the mandatory dependency under COE2 and the reason **ACE Core Dev + ACE Captives Dev** must be in the stack (not stable ACE).

## 1. Overview

Kex Scenario Core is a **framework / library mod** — it has no operator-facing gameplay surface on its own. It exists to provide reusable scenario-authoring components (classes, prefabs, base behaviors) that Kex's scenario mods consume. On this stack, the only consumer is **COE2 - Combat Ops Enhanced 2**.

The architecturally critical fact: **Kex Scenario Core hard-deps ACE Core Dev (`65AD7D0D9941A380`) + ACE Captives Dev (`65AD7C249E4ECDFB`)** at the `addon.gproj` level. This means:
- Stable ACE cannot replace Dev ACE — boot will fail at gproj resolution if you swap them
- The 2026-05-13 COE2 pivot specifically dropped stable ACE in favour of the Dev pair to satisfy this dep
- The 2026-05-14 121-mod golden state was REVERTED partly because someone introduced stable ACE — Kex's hard-dep broke (CLAUDE.md "Revision 2026-05-16 (golden state V5)")

## 2. Functionality / Features

- Reusable scenario classes (gameplay logic primitives)
- Reusable scenario prefabs (entities, GameMode components)
- Localisation tables (12+ languages: cs, de, en, es, fr, it, ja, ko, pl, pt, ru, uk per addon.gproj WidgetManagerSettings)
- No standalone gameplay — consumed by Kex's scenario mods (COE2)

## 3. Configuration

**Config files**: none in `$profile:/`. Kex Scenario Core ships its classes/prefabs in `data.pak`; consumers (COE2) configure them via scenario `.conf` files.

| Key | Path | Default | Current | Effect |
|---|---|---|---|---|
| _N/A — no operator-facing config_ | — | — | — | tunables live in consumer scenarios |

## 4. Operator usage

_N/A_ — framework mod. Operator interaction happens through COE2 (the consumer scenario).

**Keybinds / Admin commands**: none from this mod directly.

## 5. Compatibility & load order

- **Load order layer**: **L11** (Scenario controllers — must precede COE2 within L11 per DAG fix)
- **Hard deps** (per `addon.gproj`):
  - `58D0FB3206B6F859` — base game
  - `65AD7D0D9941A380` — **ACE Core Dev** (NOT stable ACE)
  - `65AD7C249E4ECDFB` — **ACE Captives Dev** (NOT stable ACE)
- **Reverse deps**: COE2 (`60926835F4A7B0CA`)
- **Must load after**: ALL L0-L10 mods (engine frameworks, realism cores, ACE Dev pair, WCS, RHS↔WCS bridge, sway chain, factions, apparel, vehicle/weapon packs, AI overlays)
- **Must load before**: COE2 (DAG fix 2026-05-14 per CLAUDE.md "DAG fixes" #8: "Kex Scenario Core MUST precede COE2 — Workshop deps verified 2026-05-14")
- **Synergies with**: COE2 (its only consumer on this stack)
- **Conflicts with**: **stable ACE** (`5F86C7D8D7B1F4F5` etc.) — cannot coexist with the Dev pair Kex requires. Was the 2026-05-14 revert root cause.

## 6. Performance impact

Negligible — pure library. Code/prefabs are only invoked by COE2's scenario lifecycle. Memory footprint: 11.97 MB pak.

## 7. Known issues / landmines

- **ACE Dev pair hard-dep** — the single biggest landmine. The 2026-05-14 121-mod golden state was reverted because someone reinstated stable ACE without realising Kex's gproj would refuse the swap. **Never replace ACE Core Dev / ACE Captives Dev with stable ACE while Kex is in the mod list.** (CLAUDE.md "What this is" + "State summary as of 2026-05-16")
- **Active development** — Workshop description notes the author solicits community feedback via issue tracker. Version 0.4.27 is pre-1.0; expect API drift across versions. Pin a known-good version in `serverConfig.json` only if a regression appears.
- **Requires game version 1.6.0.87** per Workshop metadata. Current engine is 1.6.0.119 — compatible.

## 8. Extending / modding

To author a new scenario on top of Kex Scenario Core:
1. Workbench Subscribe-to-Source for Kex Scenario Core
2. Create new addon project depending on `5ED61DC0AFE17E8E`
3. Inherit Kex's base scenario classes
4. Build + publish

Operator has not undertaken this work; COE2 is the only Kex scenario on this stack.

## 9. Changelog / verified state

- **Installed version**: 0.4.27 (Workshop last modified 08.12.2025)
- **License**: Arma Public License (APL)
- **Downloads**: 56,102
- **Size**: 11.97 MB pak
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/5ED61DC0AFE17E8E)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/5ED61DC0AFE17E8E/changelog)
- CLAUDE.md "What this is" — Kex listed as COE2's framework
- CLAUDE.md "DAG fixes" #8 — Kex Scenario Core MUST precede COE2
- CLAUDE.md "Revision 2026-05-16 (golden state V5)" — the 2026-05-14 revert reason
- `MASTER_OBJECTIVE.md` L11
- Sister docs: `COE2_-_Combat_Ops_Enhanced_2.md` (the only consumer), `ACE_Core_Dev.md`, `ACE_Captives_Dev.md` (hard deps)
- Related memories: `[[golden_state_2026_05_16_v5]]`, `[[golden_state_2026_05_14_v4]]`
