---
workshop_id: "606B100247F5C709"
workshop_url: https://reforger.armaplatform.com/workshop/606B100247F5C709
version: "1.6.3"
author: "ceo_of_bacon"
load_order_layer: L7
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "65157D09F042428A # GRS-Apparel"
  - "65EC8C419D243264 # RedactedCore (transitive — verified via gproj scan)"
  - "69075EC0BD287A6E # sTsRHSVanillaArsenal"
related_memories: []
folder: "BaconLoadoutEditor_606B100247F5C709"
storage_paths:
  - "profile_new/profile/BaconLoadoutEditor_Loadouts/1.6.0/US/cc/<UID>"
  - "profile_new/profile/BaconLoadoutEditor_Loadouts/1.6.0/admin_loadouts"
---

# BaconLoadoutEditor

> **One-line role**: in-game loadout editor used by GRS-Apparel and sTsRHSVanillaArsenal — re-declared first-class on 2026-05-13 because those two mods hard-dep it via `addon.gproj`. Carries a corrupt-loadout-blob risk that can crash clients on open.

## 1. Overview

BLE started as an editor for the Bacon M4 Block II / URG-I weapon platforms (per the Workshop description). On this stack it acts as a **general loadout-management framework** consumed by GRS-Apparel and sTsRHSVanillaArsenal — both of those mods declare BLE as a hard dep in their gproj. **Removing BLE from `serverConfig.json mods[]` does not stop its scripts from executing**, because folder presence triggers the engine to compile and run them (CLAUDE.md folder-presence landmine). This is why BLE was re-added as a first-class declaration on 2026-05-13 rather than left as an implicit transitive dep.

The MOTD still warns players to **prefer the WCS Loadout Editor** over BLE for general loadout-editing because BLE has a known corrupt-blob risk that crashes the client on open.

## 2. Functionality / Features

- In-game loadout editor UI (open via the BLE menu — keybind documented in-mod)
- Save/load loadouts to per-player storage blobs
- Admin-side loadouts in a separate storage path
- Originally weapon-focused (Bacon M4 Block II / URG-I); used here as the generic loadout-storage framework GRS-Apparel and sTsRHSVanillaArsenal rely on

## 3. Configuration

**Server-side config files**: none directly. The mod uses two persistent-storage paths instead:

| Path | Purpose |
|---|---|
| `profile_new/profile/BaconLoadoutEditor_Loadouts/1.6.0/US/cc/<UID>` | Per-player loadout blobs (one file per player UID) |
| `profile_new/profile/BaconLoadoutEditor_Loadouts/1.6.0/admin_loadouts` | Admin-side loadouts |

Both paths verified present on disk (the `1.6.0/US/` subdir exists currently).

## 4. Operator usage

- **In-game**: open the BLE menu (default keybind per Workshop docs — not exhaustively documented in the Workshop page summary; check in-mod docs or workshop description tab).
- **Admin path**: `admin_loadouts` is where admin-created shared loadouts live.
- **Recovery procedure** (when client crashes on BLE open): delete the storage path's contents. BLE will re-init empty.

## 5. Compatibility & load order

- **Load order layer**: **L7** (apparel/loadouts) per `MASTER_OBJECTIVE.md`.
- **Must load after**: base game only (per `addon.gproj` — minimal deps).
- **Must load before**: `GRS-Apparel`, `sTsRHSVanillaArsenal` — both hard-dep BLE.
- **CLAUDE.md verbatim dep chain** (from "Mod purge safety protocol"): "`BaconLoadoutEditor` ← hard-depped by `GRS-Apparel` + `sTsRHSVanillaArsenal`. Removing it kills loadout UI for those mods."
- **Conflicts with**: no hard conflicts, but **MOTD warns to prefer WCS Loadout Editor** over BLE due to the corrupt-blob crash risk below.

## 6. Performance impact

Negligible at runtime. The risk surface is at storage-blob deserialization time when a client opens the BLE UI.

## 7. Known issues / landmines

**This is the headliner landmine of L7.** CLAUDE.md "Known landmines — keep these disabled" table verbatim:

> **BaconLoadoutEditor (606B100247F5C709) — re-added as first-class 2026-05-13**: Two mods (GRS-Apparel, sTsRHSVanillaArsenal) hard-dep BLE via `addon.gproj`, so removing it from `serverConfig.json mods[]` was a half-measure: folder-presence triggers script compile + execution regardless of modlist declaration. Now declared first-class.
>
> **Corrupt loadout-blob risk**: `profile_new/profile/BaconLoadoutEditor_Loadouts/1.6.0/US/cc/<UID>` and `1.6.0/admin_loadouts` from PCM-era reference 22 prefabs that no longer exist on disk (e.g. `{083483A1C5B8CA13}` SCAR-H mag, `{24880E53C1ED467A}` SCAR-H, `{6B42F5E6DC8C7E47}` M18 grenade attachment). BLE's loader has no skip-and-continue → null deref → client crash on open.
>
> **Fix**: delete the storage files; BLE re-inits empty. MOTD still warns to prefer WCS Loadout Editor.

Additional CLAUDE.md context (from "Landmines discovered 2026-05-13"):

> Removing a mod from `serverConfig.json mods[]` while leaving its folder in `profile_new/addons/` does NOT prevent the engine from compiling and running its scripts. Confirmed via console.log gproj line + script.log compile warnings for BaconLoadoutEditor on 2026-05-13. To truly disable a mod, must move folder OR remove from disk. This is the rationale for re-adding BLE as first-class.

And the standing-monitor stack (CLAUDE.md monitor #3, **client-side**) explicitly suppresses bare-`Stack trace` lines because:

> "**DO NOT include bare `Stack trace` token** — it floods at thousands per second when client hits a recurring VM exception (BLE corrupt-loadout interactions etc) and the monitor self-stops with 'output rate too high'."

So BLE corrupt-blob interactions are the *named example* of a flood that broke the monitoring stack.

**Operational guidance**:
1. If a client crashes after opening BLE, the first fix to try is delete `BaconLoadoutEditor_Loadouts/1.6.0/US/cc/<that-UID>` (and optionally `admin_loadouts` if admin loadout was the trigger).
2. Players should be guided to **WCS Loadout Editor** (see `[[WCS_LoadoutEditor]]` doc) as the primary loadout tool.
3. Operators must never delete the BLE folder from `addons/` while leaving GRS-Apparel or sTsRHSVanillaArsenal declared — they will fail to register on next boot.

## 8. Extending / modding

_N/A_ — non-commercial license prohibits adaptation without author permission.

## 9. Changelog / verified state

- **Installed version**: 1.6.3
- **Folder**: `BaconLoadoutEditor_606B100247F5C709`
- **Workshop last updated**: 2026-04-13
- **Storage paths**: present (see §3)
- **First-class declaration in `serverConfig.json mods[]`**: re-added 2026-05-13 after the folder-presence landmine investigation
- **Last clean boot**: continuously loaded since 2026-05-13 re-declaration

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/606B100247F5C709)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/606B100247F5C709/changelog)
- License: Non-commercial / no-share / no-adapt (per Workshop license box)
- Downstream consumers: `[[GRS-Apparel]]`, `[[sTsRHSVanillaArsenal]]`
- CLAUDE.md "Known landmines — keep these disabled" → **BaconLoadoutEditor** row (full quote in §7)
- CLAUDE.md "Landmines discovered 2026-05-13" → folder-presence triggers script execution
- CLAUDE.md "Standing monitor agents" → client error.log monitor #3 explicitly suppresses BLE-induced `Stack trace` flood
- CLAUDE.md "Mod purge safety protocol" → BLE-as-dep example chain
- Alternative loadout tool MOTD-recommended: `[[WCS_LoadoutEditor]]`
