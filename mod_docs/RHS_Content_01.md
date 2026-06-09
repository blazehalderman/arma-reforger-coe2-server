---
workshop_id: "1337C0DE5DABBEEF"
workshop_url: https://reforger.armaplatform.com/workshop/1337C0DE5DABBEEF
version: "0.14.4886"
author: "Red Hammer Studios"
load_order_layer: L1
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps:
  - "595F2BF2F44836FB # RHS_Status_Quo"
  - "615CC2D870A39838 # WCS_Arsenal"
  - "656B3A0955474CB7 # ADSSway-RHS"
  - "69075EC0BD287A6E # sTsRHSVanillaArsenal"
related_memories: []
folder: "RHS-ContentPack01_1337C0DE5DABBEEF"
---

# RHS_Content_01

> **One-line role**: bulk asset library (5.87 GB) for RHS: Status Quo — meshes, textures, sounds. No scripts, no gameplay; just the heavy data the Status Quo controller mod references.

## 1. Overview

`RHS - Status Quo - Content Pack 01` is the **larger of two split asset packs** that the live `RHS_Status_Quo` controller mod depends on. The Workshop description is one line ("Content pack 01"); per the `addon.gproj`, it carries no Dependencies beyond the base game (`58D0FB3206B6F859`) and ships no scripts of its own — its only job is to host the binary asset graph that Status Quo's prefabs reference. **It MUST load before `RHS_Status_Quo` (`595F2BF2F44836FB`)** because Status Quo's `addon.gproj Dependencies` declares both content packs as hard deps.

## 2. Functionality / Features

- Provides the **majority** of RHS art assets (5.87 GB per Workshop page).
- Pure data — no `Scripts/` tree exercised at runtime (verified by `addon.gproj` having no `WidgetManagerSettings` block beyond stringtables-less PC config).
- Re-distributed under CC BY-NC-ND 4.0 with explicit prohibition on depicting the Russia-Ukraine or Israel-Palestine conflicts.

## 3. Configuration

**Config files**: none. No `profile_new/profile/RHS_Content_01/` directory exists. Pure asset pak.

**Tunable keys**: none.

## 4. Operator usage

_N/A_ — invisible to operators. Assets are surfaced through `RHS_Status_Quo` prefabs in Game Master Entity Browser and via WCS arsenal entries (where bridged through `sTsRHSVanillaArsenal` / `WCS_RHS_Weapons`).

## 5. Compatibility & load order

- **Load order layer**: **L1** (Realism cores) per `MASTER_OBJECTIVE.md` revision 2026-05-16. RHS Content packs MUST precede `RHS_Status_Quo` (gproj-verified).
- **Must load before**: `RHS_Status_Quo` (hard dep per `RHS-StatusQuo/addon.gproj` line 6: `"1337C0DE5DABBEEF"` in Dependencies block).
- **Must load after**: nothing — only depends on base game.
- **Conflicts with**: no known conflicts.
- **Synergies with**: `WCS_RHS_Weapons` (the bridge that grafts WCS attachment slots onto RHS guns — see [[WCS_RHS_Weapons]]).

## 6. Performance impact

Boot-time-only cost. 5.87 GB load is the largest single-mod IO hit during engine init; SSD strongly recommended (CLAUDE.md operator hardware: 32 GB RAM Windows). Once paks are mapped, no runtime tick cost.

## 7. Known issues / landmines

- **Re-download eviction risk**: per `landmine_steam_dedicated_addon_gproj_missing.md`, Steam dedicated-server downloads can ship without `addon.gproj`. For a 5.87 GB pack, a corrupt re-download is a long resync. Pre-purge mitigation: verify `data.pak` is present in `RHS-ContentPack01_1337C0DE5DABBEEF/` before any folder operation. Check `ServerData.json` shows `"corrupted":false`.
- **`Remove-Item` on running server destroys the pak** — see CLAUDE.md "Pak file lock + addon move/delete" landmine. Kill server, wait 3–5 s for handle release before any folder ops.

## 8. Extending / modding

_N/A_ — closed asset library. No mod extends RHS Content Pack 01 directly; you extend `RHS_Status_Quo` (and even that is hostile per the CC BY-NC-ND license).

## 9. Changelog / verified state

- **Installed version**: 0.14.4886 (per `ServerData.json revision.version`; Workshop page also lists 0.14.4886 — last modified 20.04.2026)
- **Folder**: `RHS-ContentPack01_1337C0DE5DABBEEF`
- **Last clean boot**: continuously loaded since 2026-05-12 RHS attachment fix; pre-COE2 pivot and post-COE2 pivot both rely on it.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/1337C0DE5DABBEEF) — 1,512,570 downloads at time of writing
- [Workshop changelog](https://reforger.armaplatform.com/workshop/1337C0DE5DABBEEF/changelog)
- RHS upstream documentation: <https://www.rhsmods.org/>
- **Trivia — the meme GUID**: `1337C0DE5DABBEEF` ("LEET CODE 5 DA BBE EF" / "leet code is da beef"). Bohemia honors arbitrary 16-hex GUIDs on Workshop submission; RHS's sibling pack uses `BADC0DEDABBEDA5E` ("BAD CODE DABBED A5E"). Bohemia's API didn't reject either as long as the hex was valid and unique — confirmed live in `serverConfig.json mods[]`.
- Related memories: `[[landmine_steam_dedicated_addon_gproj_missing]]`
