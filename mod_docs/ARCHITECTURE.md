# Per-Mod Documentation & Orchestrator Architecture

**Last updated**: 2026-05-16
**Author**: operator + Claude (initial design)
**Purpose**: solve the context-window collapse problem for a 103-mod (local) / 117-mod (deployed) Arma Reforger stack.

---

## The problem this solves

The current server runs **103 declared mods locally** and **117 deployed**. Each mod ships:
- A Workshop description (~paragraph)
- An `addon.gproj` with hard-dependency GUIDs
- One or more config files in `profile_new/profile/<ModName>/`
- Per-mod tunables (e.g., CRX EAI alone has 8+ tuned knobs documented in `CLAUDE.md`)
- Past incidents / landmines / cosmetic noise (e.g., `landmine-*` memories)
- Cross-mod interactions (DAG ordering, hard-deps, reverse-deps)

When an agent (or operator) tries to work on one mod, the surrounding context — *what other mods care about this one*, *what tuning was already done*, *what was tried and abandoned* — is critical. Stuffing all of it into a single context window collapses:

1. **Cost**: 103 × ~2KB doc = ~200KB of context per turn, before the actual task.
2. **Precision**: relevant facts get diluted by irrelevant ones; the model loses focus.
3. **Maintainability**: a monolithic doc is impossible to keep current.

**Solution**: per-mod docs with a strict schema + an orchestrator that fans out specialist subagents per mod and synthesizes back.

---

## High-level design

```
┌─────────────────────────────────────────────────────────────────────┐
│                      USER ASK                                        │
│  e.g. "extend DarcChopper to cover the AH-64D and the UH-1Y"        │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                LEAD AGENT (orchestrator)                            │
│                                                                      │
│  Loads ONLY:                                                         │
│   - CLAUDE.md                                                        │
│   - mod_docs/INDEX.md (one-liner per mod)                           │
│   - mod_docs/_ORCHESTRATOR.md (this dispatcher's playbook)          │
│                                                                      │
│  Decomposes ask → routes to specialist subagents                    │
└────────┬────────────┬──────────────┬─────────────────────┬──────────┘
         │            │              │                     │
         ▼            ▼              ▼                     ▼
   ┌──────────┐ ┌──────────┐  ┌─────────────┐      ┌──────────────┐
   │DarcChopper│ │WCS_AH-64D│  │LeesUH-1YVenom│      │DarcCore      │
   │ specialist│ │ specialist│  │ specialist   │      │ specialist   │
   │           │ │           │  │              │      │ (dep check)  │
   │ Loads:    │ │ Loads:    │  │ Loads:       │      │ Loads:       │
   │ DarcChopper│ │WCS_AH-64D│  │UH-1Y doc     │      │DarcCore doc  │
   │ .md       │ │ .md       │  │              │      │              │
   │ + memories│ │ + memories│  │ + memories   │      │ + memories   │
   └─────┬─────┘ └─────┬─────┘  └──────┬───────┘      └──────┬───────┘
         │             │                │                      │
         │             │                │                      │
         ▼             ▼                ▼                      ▼
   ┌──────────────────────────────────────────────────────────────────┐
   │             STRUCTURED DIGEST (return format contract)           │
   │                                                                   │
   │  Each subagent returns a markdown digest with fixed sections:     │
   │   - Relevance (high/med/low + why)                               │
   │   - Direct answer to the lead's specific query                   │
   │   - Config changes required (with file paths)                    │
   │   - Compatibility concerns (cross-refs to other mods)            │
   │   - Open questions                                                │
   │   - Citation: every claim backed by a file path or memory ID     │
   └──────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                LEAD AGENT (synthesis)                                │
│                                                                      │
│  - Cross-references digests, resolves conflicts                      │
│  - Identifies dep-chain order issues using load-order layers (L0-11) │
│  - Produces unified recommendation to user                           │
│  - Writes deliverable to mod_docs/_asks/<date>_<topic>.md           │
└─────────────────────────────────────────────────────────────────────┘
```

This is the orchestrator-worker pattern from Anthropic's [multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system), adapted for the Reforger mod-stack domain. Key adaptations:

| Anthropic pattern element | Our adaptation |
|---|---|
| Lead agent decomposes by topic | Lead decomposes by **mod** (1 specialist per mod touched by the ask) |
| Subagents get "objective + output format + tool guidance + boundaries" | Each subagent's prompt is templated in `_ORCHESTRATOR.md` |
| Subagents return findings to lead | Subagents return a fixed-schema digest (see "Return Format Contract" below) |
| External artifacts to dodge context bloat | Subagents write working notes to `mod_docs/_scratch/` if needed; final answers go to `mod_docs/_asks/` |
| ~15× token cost vs single-agent | Acceptable trade-off for any ask spanning ≥3 mods; for 1-mod asks, lead just loads that one doc and answers directly |

---

## Why per-mod files (not one big doc)

- **Selective loading**: lead loads only relevant docs, not all 103.
- **Stable identity**: each mod has a stable GUID-keyed filename; cross-references via `[[ModName]]` (or filename) survive renames.
- **Independent updates**: editing CRX EAI's doc doesn't churn DarcChopper's diff.
- **Easy provenance**: each doc has its own `last_verified` date so staleness is obvious per-mod, not buried in a 200KB monolith.

---

## File layout

```
mod_docs/
├── ARCHITECTURE.md           # this file — read by lead agent
├── INDEX.md                  # one-liner per mod, sorted by layer L0-L11
├── _TEMPLATE.md              # schema for per-mod docs
├── _ORCHESTRATOR.md          # lead-agent playbook + subagent prompt templates
├── <ModName>.md              # one file per mod (filename = serverConfig mods[].name)
├── _asks/                    # final deliverables for user-facing tasks
│   └── YYYY-MM-DD_<topic>.md
└── _scratch/                 # subagent working notes (ephemeral; gitignore-equivalent)
```

**Naming rule**: file names match the `name` field in `serverConfig.json` `mods[]`. Where a name has spaces (e.g. `"COE2 - Combat Ops Enhanced 2"`), replace spaces with underscores. The Workshop GUID is stored inside the frontmatter — never as the filename — so renames don't break the index.

---

## Per-mod doc schema

See `_TEMPLATE.md` for the actual template. The schema (frontmatter + sections) is:

**Frontmatter** (machine-readable):
```yaml
---
workshop_id: <16-hex GUID>
workshop_url: https://reforger.armaplatform.com/workshop/<GUID>
version: "<x.y.z or empty>"
author: "<author handle>"
load_order_layer: L0..L11   # from MASTER_OBJECTIVE.md
status: active | disabled | blacklisted | deployed-only
last_verified: YYYY-MM-DD
declared_in:
  - local         # in serverConfig.json
  - deployed      # in serverconfig-deployed.json
hard_deps:        # from addon.gproj
  - "<dep-GUID> # <dep-name>"
reverse_deps:    # who depends on THIS mod (derived from gproj scan)
  - "<depper-GUID> # <depper-name>"
related_memories:
  - <memory_slug>.md
---
```

**Sections** (human + agent readable):
1. **Overview** — 2-3 sentences. What does this mod do at a glance?
2. **Functionality / Features** — bullet list of what the mod adds.
3. **Configuration** — every config file path + a table of tunable keys with current value, default, and effect.
4. **Operator usage** — how to use it in-game (keybinds, menus, GM tools, chat commands).
5. **Compatibility & load order** — known conflicts, hard-deps that must come before, DAG fixes.
6. **Performance impact** — observed cost (AI tick budget, RPC churn, log spam).
7. **Known issues / landmines** — historical incidents, cosmetic noise, version-pin gotchas.
8. **Extending / modding** — if the mod is a framework (DarcChopper, ACE, CRX), how to integrate other mods.
9. **Changelog / verified state** — version installed + when last booted clean.
10. **References** — Workshop URL, GitHub, Discord, Workshop changelog, related Anthropic-memory IDs.

Sections 2-9 are **all optional individually but the file must declare each section header** (use `_N/A_` if a section is irrelevant). This makes parsing predictable for the orchestrator.

---

## Return Format Contract (subagent → lead)

Every specialist subagent MUST return its findings in this exact structure. The lead parses these mechanically.

```markdown
## Findings: <ModName>

**Relevance**: <high|medium|low>. <one-sentence justification>

**Direct answer**:
<2-5 bullets answering the lead's specific query about this mod>

**Config changes required** (if any):
- <file path>: <key> = <new value>  (was <old value>)

**Compatibility concerns** (if any):
- <other mod> — <how it interacts>

**Citations**:
- <claim>: <mod_docs/<File>.md §<section>> OR <memory:<slug>> OR <file_path:line>

**Open questions** (if any):
- <question>
```

**Citations are mandatory.** No claim survives without a pointer back to a file or memory. This is the same evidence discipline `CLAUDE.md`'s "Self-healing log investigation playbook" requires.

---

## When to fan out vs. answer directly

The lead agent uses this decision rule (also see `_ORCHESTRATOR.md`):

| Ask shape | Action |
|---|---|
| Single mod, single-file change | Lead loads that mod's doc + answers directly. No fanout. |
| Single mod, framework integration (e.g. "extend DarcChopper") | Lead loads the framework's doc + spawns 1 subagent per integration target |
| Cross-cutting (e.g. "why is AI density low?") | Fan out to AI-overlay specialists (CRX, FS Tactical, ConflictNoBaseAILimit) + scenario specialist (COE2 / Kex) |
| Boot failure / crash investigation | Lead reads logs first (per CLAUDE.md playbook), then targeted fanout to suspect mods |
| Vague request | Lead asks one clarifying question; never fans out on undefined scope |

Per the Anthropic guidance: "scaling effort to complexity — simple fact-finding requires just 1 agent with 3-10 tool calls; direct comparisons might need 2-4 subagents with 10-15 calls each." We should target 2-4 specialists per multi-mod ask, not "spawn one for every mod the user mentioned."

---

## Integration with existing operator practice

This architecture **does not replace**:
- `CLAUDE.md` — still the canonical operator's notes
- `MASTER_OBJECTIVE.md` — still the 12-layer load order spec
- `MEMORY.md` + `memory/*.md` — still the auto-memory store; per-mod docs *cross-reference* memories, they don't duplicate them
- `snapshot_state.ps1` / `restore_state.ps1` — pre-change snapshots are STILL mandatory
- Standing-monitor stack — still spawned at session start when doing server work

The per-mod docs are an **additional, mod-scoped index** that lets agents work narrowly. CLAUDE.md remains the index of the project; this is the index of the *mod stack*.

---

## Anti-patterns to avoid

1. **Don't put dependency declarations in the doc.** The source of truth is `addon.gproj`. Docs cite it; they don't restate it. (Exception: the `hard_deps` frontmatter is a redundancy for fast lookup — it must be regenerated, never edited.)
2. **Don't paste Workshop descriptions verbatim.** Cite the URL; summarize the operator-relevant 20% in the Overview section.
3. **Don't write speculative content.** If something is uncertain, mark it `[needs verification]` with a reason. Verification ≠ assertion.
4. **Don't let a doc grow past ~250 lines.** If it does, the mod is probably a framework — split its integration guide into a `<ModName>_INTEGRATION.md` companion.
5. **Don't spawn a subagent for every mod referenced.** Most asks touch 2-4 mods deeply. The rest get one-liner mentions from the lead.

---

## Adding new mods (mandatory flow)

Mirrored in `CLAUDE.md` § "MANDATORY new-mod onboarding flow" — that's the authoritative copy. Summary here for orchestrator-context completeness.

When you add a mod to `serverConfig.json` or `serverconfig-deployed.json`:

1. 5-section evaluation gate (Workshop ID + Conflict Analysis + Risk + Execution + Troubleshooting)
2. Snapshot via `snapshot_state.ps1`
3. Config edit at correct L0-L11 layer; `version: ""`
4. **Generate the per-mod doc** — run `mod_docs/_scaffold_stubs.ps1`, then enrich per `_TEMPLATE.md`
5. Update `INDEX.md` row + status `[doc]`
6. Transitive-dep audit on the new mod's `addon.gproj`
7. Boot test + monitor verification
8. Update CLAUDE.md for any landmines/knobs surfaced

For multi-mod adds: spawn a parallel doc-enrichment subagent per category (see §"How the lead synthesizes" above).

This step is NOT optional. A mod that ships without a doc is a future-Claude landmine. The whole architecture exists to prevent context collapse from undocumented mods.

## References

- [Anthropic: How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) — orchestrator-worker pattern, return-format discipline, token-budget guidance
- `CLAUDE.md` — operator's notes (this server) — authoritative copy of the new-mod onboarding flow lives here
- `MASTER_OBJECTIVE.md` — 12-layer load order
- `memory/MEMORY.md` — auto-memory index
