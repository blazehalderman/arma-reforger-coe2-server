---
workshop_id: "645F08FA9E7CDEDE"
workshop_url: https://reforger.armaplatform.com/workshop/645F08FA9E7CDEDE
version: "1.0.37"
author: "McTiddies4Lunch3 (contributor: Tonic)"
load_order_layer: L0
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "687CD82F6E41D627 # AFWCore"
reverse_deps: []
related_memories: []
folder: "AttachmentFramework_645F08FA9E7CDEDE"
---

# AttachmentFramework

> **One-line role**: end-user attachment pack built on AFWCore — adds working flashlight and laser weapon attachments plus example implementations.

## 1. Overview

AttachmentFramework is the user-facing companion to AFWCore. Per the Workshop description, it's a "modder toolkit ... designed for making flashlights and lasers" and ships example flashlight/laser attachments operators can mount on compatible weapons. Although the Workshop description frames it as a toolkit, in this stack it is also the practical content layer that surfaces flashlight/laser items in arsenals and weapon attachment slots. Part of CLAUDE.md's "realism stack: RHS Status Quo + WCS + ACE Dev + AttachmentFramework" canonical list.

## 2. Functionality / Features

- Flashlight attachments (with on/off toggle when mounted)
- Laser attachments (visible / IR variants per implementation)
- Example prefabs serving as integration reference for other modders
- Built on AFWCore's primitive scripts + rail/attach system

## 3. Configuration

_N/A_ — no `profile_new/profile/AttachmentFramework/` directory exists. Per-weapon attach-slot wiring is in the data.pak.

## 4. Operator usage

**In-game**: flashlight/laser attachments appear in arsenal under weapon-attachment categories. Mount via standard inventory drag onto compatible rail slots. Toggle on/off using the standard base-game attachment hotkey (`L` default in Reforger for weapon light, but verify in-game keybind menu).

**Compatible weapons**: any weapon whose prefab declares the appropriate rail slot — most WCS_Weapons and RHS guns via the bridge.

**Keybinds**: no AttachmentFramework-specific keybinds; uses base-game attachment toggles. _[needs verification — no Workshop doc explicitly enumerates keybinds.]_

## 5. Compatibility & load order

- **Load order layer**: **L0** per CLAUDE.md (L0 list explicitly names `AttachmentFramework`).
- **Must load after**: `AFWCore` (hard-dep, also L0).
- **Synergies with**: RHS Status Quo, WCS_Weapons, WCS_RHS_Weapons bridge — all gain functional flashlight/laser slots.
- **Conflicts with**: none documented.

## 6. Performance impact

Negligible — per-attachment cost only when an active flashlight/laser is mounted; standard projectile-system overhead.

## 7. Known issues / landmines

_None documented_ in CLAUDE.md or memory store. Note CLAUDE.md "Mod stack architecture" lists it as part of the L0 + realism stack but flags no known incidents.

## 8. Extending / modding

_N/A_ at operator level. Workbench: derive new attachment prefabs from AttachmentFramework's example flashlight/laser prefabs, declare rail slot binding on target weapon's prefab.

## 9. Changelog / verified state

- **Installed version**: 1.0.37
- **Folder**: `AttachmentFramework_645F08FA9E7CDEDE`
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/645F08FA9E7CDEDE)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/645F08FA9E7CDEDE/changelog)
- Author: McTiddies4Lunch3 (contributor: Tonic)
