---
workshop_id: "687CD82F6E41D627"
workshop_url: https://reforger.armaplatform.com/workshop/687CD82F6E41D627
version: "1.0.7"
author: "Tonic"
load_order_layer: L0
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "645F08FA9E7CDEDE # AttachmentFramework"
related_memories: []
folder: "AttachmentFramework-Core_687CD82F6E41D627"
---

# AFWCore

> **One-line role**: low-level scripts + configs underpinning the AttachmentFramework system (custom laser/flashlight/bipod attachments, modular helmets, rail systems).

## 1. Overview

AFWCore (Workshop title "AFW-Core", gproj ID `AFWCore`) by Tonic is the foundational library for the AttachmentFramework system. The Workshop description states it provides "scripts and needed configs to start creating custom attachments, modular helmets" along with laser/flashlight/bipod attachment frameworks and rail systems for modular weapons. It is a developer-facing dependency — its only direct depper in this stack is `AttachmentFramework` (`645F08FA9E7CDEDE`).

## 2. Functionality / Features

- Base scripts for custom weapon attachment types (laser, flashlight, bipod)
- Modular helmet system primitives
- Rail systems for modular weapons
- Configuration templates for derived attachment mods

## 3. Configuration

_N/A_ — no `profile_new/profile/AFWCore/` directory exists.

## 4. Operator usage

Not directly consumed. Its value reaches the operator transitively through `AttachmentFramework`'s flashlight/laser attachments on weapons.

## 5. Compatibility & load order

- **Load order layer**: **L0** per CLAUDE.md (L0 list explicitly names `AFWCore`).
- **Must load before**: `AttachmentFramework` (`645F08FA9E7CDEDE`, also L0 — within-layer order enforced by gproj dep).
- **Conflicts with**: none documented.

## 6. Performance impact

Negligible — pure library.

## 7. Known issues / landmines

_None documented_ in CLAUDE.md or memory store.

## 8. Extending / modding

_N/A_ at operator level. Workbench: see Tonic's reference attachment examples in the data.pak; no public API doc on the Workshop page.

## 9. Changelog / verified state

- **Installed version**: 1.0.7
- **Folder**: `AttachmentFramework-Core_687CD82F6E41D627`
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/687CD82F6E41D627)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/687CD82F6E41D627/changelog)
- Author: Tonic
