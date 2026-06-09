# Orchestrator Playbook

**For**: the lead agent in a multi-mod operation on this Reforger server.

You are the lead agent. Your job is **decomposition and synthesis** — not deep mod work. Deep mod work goes to specialist subagents loaded with only that mod's doc + relevant memories.

---

## Decision tree: when you receive a user ask

```
                   user ask received
                          │
                          ▼
              read CLAUDE.md if not already
              read mod_docs/INDEX.md
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
  Single mod?     Multi-mod /        Vague? ("make the
  Single file?    cross-cutting?     server better")
        │                 │                 │
        │                 │                 ▼
        │                 │           Ask ONE clarifying
        │                 │           question, then route
        │                 │
        ▼                 ▼
  Load that mod's    Identify the 2-4 mods most
  doc, answer        load-bearing for the ask.
  directly. No       (Use INDEX.md keyword scan +
  fanout.            CLAUDE.md "Mod stack
                     architecture" layer table.)
                          │
                          ▼
                   For each identified mod,
                   spawn a specialist subagent
                   in parallel via the Agent tool
                   (subagent_type: claude or Explore).
                          │
                          ▼
                   Each subagent uses the
                   "Specialist subagent prompt"
                   template below.
                          │
                          ▼
                   Collect digests.
                   Resolve conflicts.
                   Check load-order layers (L0-L11).
                   Synthesize unified answer.
                          │
                          ▼
                   Write deliverable to
                   mod_docs/_asks/<date>_<topic>.md
                   AND respond to user.
```

---

## Specialist subagent prompt template

Use this template when spawning a specialist via the `Agent` tool. Fill in `{{ }}` placeholders.

```text
You are the specialist subagent for the **{{mod_name}}** mod on a 103-mod
modded Arma Reforger server (operator's notes in CLAUDE.md at the project
root). The lead agent has delegated a narrow question to you.

CONTEXT YOU MUST READ (in this order, before doing anything else):
1. mod_docs/{{mod_filename}}.md — your mod's full doc
2. Any [[link]]ed memories in that doc's `related_memories` frontmatter
3. The mod's addon.gproj for hard-dep verification:
   profile_new/addons/{{mod_folder}}/addon.gproj
4. The mod's current config (if any), from the paths in §3 Configuration

DO NOT READ:
- Other mods' docs unless your mod doc cross-references them
- Server-wide log files (lead is responsible for that)
- The full CLAUDE.md (lead has already digested it)

YOUR SPECIFIC QUERY FROM THE LEAD:
{{specific_query}}

TOOL BUDGET: {{N}} tool calls maximum. Default 10 unless ask is complex.

RETURN FORMAT (this is a contract — match it exactly):

## Findings: {{mod_name}}

**Relevance**: <high|medium|low>. <one-sentence justification>

**Direct answer**:
<2-5 bullets answering the lead's specific query>

**Config changes required** (if any):
- <file path>: <key> = <new value>  (was <old value>)

**Compatibility concerns** (if any):
- <other mod> — <how it interacts>

**Citations** (mandatory — every claim above MUST be cited here):
- <claim>: <mod_docs/<File>.md §<section>> | <memory:<slug>> | <file_path:line>

**Open questions** (if any):
- <question — and why it blocks confidence>

RULES:
- No claim without a citation.
- If your doc is missing info, say so — don't guess. Lead will spawn a
  research agent or ask the user.
- Stay in your lane: questions about a different mod get "out of scope"
  in Open questions; do NOT investigate.
- Stop at the tool budget. Better to return partial findings than overrun.
```

---

## How the lead synthesizes

After all specialists return:

1. **Concatenate digests** in load-order layer order (L0 → L11). This naturally surfaces dep-chain issues.
2. **Cross-validate citations**. If two specialists cite the same memory but interpret it differently, flag it; do not silently pick one.
3. **Detect missing layers**. If the ask touches a heli but no specialist covered DarcCore, that's a gap — spawn a follow-up.
4. **Check the operator's mandatory gates** before recommending action:
   - Has a `snapshot_state.ps1` snapshot been taken? (per `feedback_snapshot_before_changes` memory)
   - Has the 5-section mod-evaluation gate been satisfied for new mods? (per `feedback_mod_evaluation_gate` memory)
   - Is the proposed change a config edit or a script/folder operation? (Latter requires server-down per the "pak file lock" landmine.)
5. **Produce the deliverable**:
   - User-facing response: terse summary + recommended next action
   - Persistent record: `mod_docs/_asks/<YYYY-MM-DD>_<topic>.md` (full digests + synthesis, for future agents)

---

## Token-budget guardrails

From Anthropic's [multi-agent research post](https://www.anthropic.com/engineering/multi-agent-research-system): "Multi-agent systems use about 15× more tokens than chats — requires high-value tasks for economic viability."

Heuristics:
- **1-mod ask**: never fan out. Lead handles it.
- **2-mod ask**: fan out only if both mods have nontrivial docs (>100 lines each); otherwise lead reads both and answers.
- **3-4 mod ask**: fan out is justified.
- **5+ mod ask**: split into phases. Phase 1 = 3 most load-bearing mods, return to user with partial findings, phase 2 covers the rest only if needed.

If you fan out, **fan out in parallel**, not sequentially. Per Anthropic: "deploy 3+ tools in parallel to cut research time by up to 90%." Use a single message with multiple `Agent` tool invocations.

---

## Examples

### Example 1: simple single-mod ask
> "Why is CRX EAI making AI shoot through fog?"

Lead: reads `mod_docs/CRX_EnfusionAI.md` + `CRX_EAI*.txt` config files. Answers directly. No fanout.

### Example 2: framework integration (this conversation's first task)
> "Make DarcChopper work with the AH-64D and the UH-1Y."

Lead identifies 3 mods: **DarcChopper** (framework), **WCS_AH-64D** (target), **LeesUH-1YVenom** (target). Fans out:
- Subagent A (DarcChopper specialist): "what does SDRC_ChopperComp need? what's the extension procedure?"
- Subagent B (WCS_AH-64D specialist): "what's the prefab GUID? what compartments + crew slots does it have? does any existing component conflict with SDRC_ChopperComp?"
- Subagent C (LeesUH-1YVenom specialist): same questions as B.

Lead synthesizes into a unified integration plan, checks load-order (DarcCore L0 → DarcChopper L9 → target heli must be loaded earlier per gproj).

### Example 3: cross-cutting symptom investigation
> "Server crashed at boot — fix it."

Lead does NOT fan out first. Per `CLAUDE.md` "Self-healing log investigation playbook", it reads the newest log folder + tails first. THEN, once a suspect mod is identified, lead may fan out 1-2 specialists for that mod (e.g., compatibility check) + the scenario controller.

---

## Anti-patterns

1. **Don't spawn a subagent without a specific, bounded query**. Per Anthropic: "without detailed task descriptions, agents duplicate work, leave gaps, or fail to find necessary information."
2. **Don't let subagents talk to each other**. They report to the lead only. The lead resolves conflicts.
3. **Don't let a subagent rewrite files**. Subagents return *recommendations* in their digest. The lead (or operator) applies edits — that way one synthesis point reviews all changes before they happen, and the mandatory snapshot gate runs once, not N times.
4. **Don't skip the snapshot before applying changes**. `snapshot_state.ps1 -Label "pre-<topic>"` before ANY file write that touches a config or addons folder.

---

## Where this differs from CLAUDE.md's existing investigation playbook

`CLAUDE.md` § "Self-healing log investigation playbook" is **incident-driven**: server misbehaving, root-cause it. That's still the right tool for crash/hang/regression work — don't replace it.

This orchestrator is **design-driven**: user wants to USE the stack (configure, extend, tune), and the search space spans multiple mods. The two complement each other; they don't overlap.
