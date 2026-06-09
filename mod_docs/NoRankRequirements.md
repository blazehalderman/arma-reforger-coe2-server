---
workshop_id: "66D55C5BEC1BD82F"
workshop_url: https://reforger.armaplatform.com/workshop/66D55C5BEC1BD82F
version: "1.0.10"
author: "Jessicalj"
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
folder: "NoRankRequirements_66D55C5BEC1BD82F"
---

# NoRankRequirements

> **One-line role**: server-side rank-gate bypass — the server always reports every player as rank GENERAL so all rank-gated actions (building, spawning, supply requests) are unlocked.

## 1. Overview

A minimal rank-override patch (size: 0.96 KB) that hooks the server's rank-verification path so any player rank query returns **GENERAL**. This unlocks all rank-gated content (build menu items, supply requests, command actions) for every player regardless of their actual rank. Mod is **passive** — no client-side action required, no GM tools, no admin commands.

**CRITICAL interaction with CRX EnfusionAI** (CLAUDE.md "Landmines discovered 2026-05-13"): if `CRX_EAICharacterConfig.txt Rank_Type=0`, CRX uses its own internal rank system which silently overrides this mod's bypass. NoRankRequirements only works when **`CRX_EAICharacterConfig.txt Rank_Type=1` (Vanilla)** is set (current value verified 2026-05-16). The CRX dependency is the single most important fact for this mod.

## 2. Functionality / Features

- **Universal rank=GENERAL override** — server reports GENERAL for all players
- **Passive** — no operator/player interaction once enabled
- **Modded-faction support claimed** by author (Workshop description: "potential support for modded factions")
- **No client config required** — works for any connecting client

## 3. Configuration

**Config files**: none. No tunables. Mod is on/off via mods[] declaration.

| Key | Path | Default | Current | Effect |
|---|---|---|---|---|
| _N/A — no configuration surface_ | — | — | — | — |

**Critical dependency**: the upstream `CRX_EAICharacterConfig.txt Rank_Type` value:

| Setting | Effect on NoRankRequirements |
|---|---|
| `Rank_Type=0` (CRX internal) | **NoRankRequirements is silently ignored** — CRX overrides every rank query before this mod gets a chance to respond |
| `Rank_Type=1` (Vanilla) | **NoRankRequirements works** — CRX defers to vanilla rank system, vanilla then returns GENERAL via this mod's hook |

Current state: `Rank_Type=1` set at `CRX_EAICharacterConfig.txt:13` — NoRankRequirements is active.

## 4. Operator usage

**In-game**: no operator action required. Players see all rank-gated items unlocked on session join.

**Keybinds / Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L9** (AI overlays / gameplay-rank-bypass)
- **Must load after**: nothing required by gproj (base-game only)
- **Must load before**: scenario controllers at L11 — rank hook must be in place before player join
- **Synergies with**:
  - **CRX EnfusionAI** — mandatory partnership; requires `CRX Rank_Type=1` (see § 3)
- **Conflicts with**:
  - **CRX EnfusionAI with `Rank_Type=0`** — silent override; this mod becomes a no-op (see CLAUDE.md "Landmines discovered 2026-05-13" → "CRX_EAI Rank_Type — keep at 1")
  - **AllArsenalItemsToPrivate** (`66C751946DC58A1A`, mentioned in MASTER_OBJECTIVE.md but not in current stack) — both target rank gates with opposite polarity. If AllArsenalItemsToPrivate is ever added, audit interaction.

## 6. Performance impact

Negligible — single rank-query hook with constant-time return. 0.96 KB code footprint.

## 7. Known issues / landmines

- **CRX `Rank_Type` silent override** — see § 3 and CLAUDE.md. This is the entire NoRankRequirements landmine surface. **Always verify `CRX_EAICharacterConfig.txt Rank_Type=1` before declaring NoRankRequirements "broken."**
- **"GENERAL for everyone" is intentional** — admins and regulars see the same unlocked content. There is no per-player or per-role gating. If operator wants role-based access, this is the wrong mod.
- **Built against game version 1.6.0.54** — current engine is 1.6.0.119 (4 minor versions ahead). The hook is small enough that it has not broken across updates as of 2026-05-16; verify by joining as a fresh-account player and checking if rank-gated items are accessible.
- **No documented incidents in any log to date.**

## 8. Extending / modding

_N/A_ — single-purpose 0.96 KB patch. No extensibility surface.

## 9. Changelog / verified state

- **Installed version**: 1.0.10 (game version 1.6.0.54 target)
- **Workshop released**: November 11, 2025
- **Downloads / rating**: 11,859 / 93%
- **Last clean boot**: continuously loaded in 2026-05-16 V5 golden state
- **CRX dependency verified**: `CRX_EAICharacterConfig.txt Rank_Type=1` set 2026-05-13 (CLAUDE.md)

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/66D55C5BEC1BD82F)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/66D55C5BEC1BD82F/changelog)
- CLAUDE.md "Landmines discovered 2026-05-13" → "CRX_EAI Rank_Type — keep at 1"
- CLAUDE.md "Density tuning knobs" — Rank_Type row
- `INDEX.md` — `gameplay:rank-bypass`
- Sister doc: `CRX_EnfusionAI.md` (mandatory partner — § 3, § 7)
