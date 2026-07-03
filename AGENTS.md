# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Anti-ratchet constraint on the briefing templates

The briefing templates (canonical in skills/workflow-rules/SKILL.md, referenced from launch.md Step 8c/8d) are FIXED. Do not add sections to member briefs. Do not prescribe investigation steps. Do not introduce "first action" items or acknowledgment rituals. If a team run reveals a member needs more context, the fix is to improve the noun-phrase identity in suggest-members, NOT to add sections to the briefing template. This constraint exists because the briefing templates are an observed regression vector — commit f7db555 sprayed "quality-oriented" framing into every brief and created FM-3.1 (premature termination) + FM-1.3 (step repetition) failure modes users observed.

**Carve-out: harness protocol mechanics are permitted.** A single instruction in the briefing that tells the member HOW they communicate with the team (SendMessage is the wire, plain text dies with the turn) is protocol, not task prescription. It does not describe what to investigate, when to act, or what "done" looks like — it only describes the transport layer. Protocol mechanics are allowed. **Task framing, lifecycle framing, phase framing, acknowledgment rituals, and "first action" directives remain forbidden.**

## What This Is

Swarm is a Claude Code plugin for launching agent teams. Eight commands — `/swarm:launch` (catch-all), `/swarm:code`, `/swarm:triage`, `/swarm:write` (mode shortcuts), `/swarm:refine` (refine the current branch and PR), `/swarm:workflow` (custom mode entry point), `/swarm:create-workflow` (scaffolding), `/swarm:update-workflow` (refresh generated workflows) — drive an interactive setup that creates a coordinated team of agents with defined roles and rules. Users can extend swarm by creating custom mode skills in their own codebases — either as **full custom modes** or as **thin wrappers** that extend a built-in mode.

## Architecture

**Everything is a prompt.** No runtime composition, no imports, no framework. Commands and skills are self-contained markdown files consumed by the model in one pass.

```
commands/launch.md          # Catch-all command — interactive team setup (Steps 0–8)
commands/code.md            # Mode shortcut — pre-selects Code, delegates to launch.md
commands/triage.md          # Mode shortcut — pre-selects Triage, delegates to launch.md
commands/write.md           # Mode shortcut — pre-selects Writing, delegates to launch.md
commands/refine.md          # Standalone — runs Review/Refine/Deliver against the current branch + PR
commands/workflow.md         # Custom mode entry point — takes a mode skill name, delegates to launch.md
commands/create-workflow.md  # Scaffolding — interviews user, generates mode skill + shortcut command (wrapper or full)
commands/update-workflow.md  # Refresh — regenerates the plugin-owned wiring of an existing shortcut command
skills/code-mode/           # Code mode: lead identity, facilitator title, rules, phase arc
skills/triage-mode/         # Triage mode: diagnose an issue (cause + blast radius), no code change; phase arc has no Refine
skills/writing-mode/        # Writing mode: lead identity, facilitator title, ownership boundaries, editorial baseline, phase arc
skills/general-mode/        # General mode: silent fallback + wrapper base — no shortcut command
skills/workflow-rules/      # CANONICAL governance spec — hard rules, briefing templates, launch mechanics, pulse; invoked by launch.md Step 1 and by custom commands
skills/suggest-members/     # Recommends team composition based on outcomes and mode
skills/writing-style/       # Structural pattern analysis (trope detection) for writing-mode review
skills/resolve-dispute/     # Resolves stuck review findings via put-up-or-concede exchange
skills/define-rubric/       # Available skill for teams that genuinely need formal validation criteria
skills/independent-review-loop/  # Independent pre-delivery review loop — Codex or a swarm-native Codex-style reviewer; runs at the unified Refine/Deliver gate in code-mode and /swarm:refine
.claude-plugin/plugin.json  # Plugin manifest
.claude-plugin/marketplace.json  # Marketplace registry entry
.claude/swarm-ship.md       # Per-project ship definition (created at first launch, user-owned)
```

**Commands** are entry points that can spawn teams (via the Agent tool — teams form implicitly at the first Agent spawn; swarm requires Claude Code ≥ v2.1.178). Shortcut commands (`/swarm:code`, `/swarm:triage`, `/swarm:write`, `/swarm:general`) use `${CLAUDE_PLUGIN_ROOT}` to read launch.md and execute it with mode pre-set. `/swarm:workflow` is the generic entry point for custom modes — it takes a mode skill name as argument. `/swarm:create-workflow` scaffolds a custom mode skill + shortcut command in the user's project. **Skills** are helpers invoked via the Skill tool — they cannot launch teams. **Mode skills** (`swarm:code-mode`, `swarm:triage-mode`, `swarm:writing-mode`, `swarm:general-mode`, and user-defined custom modes) are invoked by the team lead at Step 8b; they return the phase arc and mode-specific rules for that run. `swarm:workflow-rules` returns the universal governance spec (hard rules, briefing templates, launch mechanics, pulse setup) — the canonical single source, invoked by launch.md at Step 1 and by user-authored shortcut commands that cannot access `${CLAUDE_PLUGIN_ROOT}`.

### How launch.md Works

Step 0 (pre-flight) → Step 1 (invoke `swarm:workflow-rules` — the governance spec) → Step 2 (outcomes → explicit tier pick "Defaults — Ultra" / "Defaults — Balanced" → silent mode inference + suggest-members → team approval "Does this team look right?") → Step 7 (confirmation — "Launch the team" / "I have changes") → Step 8 (spawn and execute).

Steps 3–6 are definitions, not a walked sequence: Step 2 drives the two user-answered questions (tier, team); mode and lead research default silently; "I have changes" at Step 7 reuses the same definitions. Three gates stand between outcomes and spawn — tier, team, launch — and inline `$ARGUMENTS` outcomes exempt none of them (that skip caused a real regression: a team spun up without the tier ever being asked). Step 7 and Step 8 labels are load-bearing cross-references throughout the plugin, so they keep their names.

`$ARGUMENTS` is substituted by Claude Code before the model sees the prompt. If the user passes args to `/swarm:launch`, they appear in the `## User-Provided Context` section and the outcomes question is skipped. Mode is inferred from the outcomes when unambiguous. Shortcut commands read launch.md via `${CLAUDE_PLUGIN_ROOT}` and execute it with mode pre-set and a streamlined outcomes flow.

### Team Execution Phase Arc

The phase arc skeleton is universal: Research → Converge → Approve → Execute → Review → Refine → Deliver. The mode skill (invoked at Step 8b) defines what each phase means — who acts, what the deliverable is, how review works. Code mode and Writing mode have meaningfully different phase semantics. A full mode may also omit a phase: Triage mode drops Refine (and the recursive-refinement ladder), because a diagnosis has an evidentiary terminal and polishing past it manufactures false certainty. By defining no Refine phase, the universal "ask refine-or-deliver" rule (which keys to "the Refine phase in the mode skill, if defined") does not fire — its Deliver phase restates this so the lead does not re-import the question by habit.

### Independent Review Loop

`skills/independent-review-loop/` adds an optional **independent review loop** whose differentiator is **independence + exhaustiveness** — a reviewer that fails differently from the authors (a different model via Codex, or a fresh-context agent), run until no in-scope functional finding remains. (The recursive-refinement ladder also hunts bugs as it drives completeness to the full outcome scope; the new axis here is the independent eye run to clean.) At 9/10+, code-mode's Refine presents a **unified pre-ship gate** (thoroughness-descending): *recursive refinement + independent review* / *recursive refinement only* / *independent review loop only* / *ship as is*. For the review options, the loop runs at Deliver **after the ship steps** (PR-then-loop on the common path), reviewing the whole branch diff against the approved outcome each round (base = `main` or the repo's equivalent target — no GitHub PR required; the PR is only a push target); the lead relays each round's reviewer output to the user verbatim with a one-line disposition (non-blocking, clean rounds included — the loop skill's step 3), triages findings in/out-of-scope (the codified "operator once in a while"), fixes the in-scope functional ones (committing each round, pushing per the ship definition), and re-reviews until none remain (backstop: 15 rounds → escalate to user; oscillation matched by title+`file:line` → surfaced to the user, since this loop's reviewer isn't an addressable teammate). The engine is an in-skill sub-choice: **Codex** (independent model, preferred when present — `command -v codex` sets order/default, both always offered) or a **swarm-native fallback** (fresh ephemeral Codex-style reviewer subagents). Codex runs read-only via stdin (`codex exec review -`); the loop depends only on the `codex` binary. The engine choice persists per-project to `.claude/swarm-review.md` (ask-once / read-thereafter, mirroring `swarm-ship.md`'s mechanism; a saved pref selects but never asserts availability — it re-checks at runtime and degrades without rewriting the file). A Codex **usage-limit** error is a distinct class: within a ~5–6h cap (the rolling window) it auto-waits — recorded as a `codex-reset-wait` task and resumed off the pulse — and escalates beyond the cap or on an unparseable reset. Reviewer rubric and prose-only finding format adapted from OpenAI Codex (`codex-rs`, Apache-2.0). The loop skill itself adds no new phase and no changes to the briefing templates.

The gate records the pick as an `independent-review-loop pending` **run-state task** so Deliver runs the loop off durable state, not recall (the fix for the bug where recursive+independent shipped without entering the loop); Deliver is restructured as an ordered ship → loop → terminal definition-of-done. The durable spine is a **session-scoped run-state task list** (closed two-item vocabulary — `independent-review-loop pending`, `codex-reset-wait until <T>` — explicitly not a general tracker), defined in `workflow-rules` (referenced from launch.md Step 8e). The **pulse** now ends the run cleanly at the true terminal — `CronDelete` first, then a keep-open/shutdown question — instead of churning forever after Deliver; two Team Lead rules govern it (terminal-state + pulse-existence), kept in Team Lead Rules (never General Rules) so they stay out of the briefing templates.

**Maintainer note — the pulse holds a pending user decision two deliberately-different ways; do not harmonize them.** A `codex-reset-wait` escalation surfaces once then holds (its durable run-state task carries the state across a compaction, so it needs no re-emission). A decision-grade AskUserQuestion gate that AFK-timed-out is re-emitted in full on each hold (it has no marker, so the re-emission itself is what survives a compaction). This split is intentional — a maintainer "tidying for consistency" would regress one direction or the other. Kept here in AGENTS.md, never in the shipped pulse prompt.

### Mode Skills

Mode skills are invoked by the team lead at runtime (Step 8b) using the Skill tool. Built-in modes use the `swarm:` prefix (`swarm:code-mode`, `swarm:triage-mode`, `swarm:writing-mode`, `swarm:general-mode`). Custom modes use their unqualified name (`blog-mode`, `security-review-mode`). Each returns: lead identity, facilitator title, facilitator identity line, mode-specific rules, suggest-members guidance, and a phase arc. Custom modes may additionally include a Lead Allowlist, Pre-flight Reads, and Information Flow section.

### Custom Workflows

Users extend swarm by creating custom mode skills in their project's `.claude/skills/` directory. Two variants are supported:

- **Full custom mode** — carries its own Lead Identity, Facilitator, Phase Arc, and rules. Use when the workflow's governance truly differs from the built-in modes.
- **Thin wrapper (extension mode)** — declares `extends: swarm:code-mode | swarm:writing-mode | swarm:general-mode` in frontmatter and carries only additive overlays. Phase arc, lead identity, and facilitator are inherited from the base at runtime; extensions add Mode-Specific Rules (additive), Lead Allowlist additions, and a Suggest-Members Guidance supplement. Any full custom mode shipped with the plugin is a valid wrapper base.

Entry points:

- **`/swarm:workflow <mode-name>`** — plugin-shipped command, reads launch.md for governance, invokes the user's local mode skill at Step 8b. Resolves `extends:` at runtime (invokes the base mode and applies additive overlays).
- **Per-workflow shortcut** — a project-local `.claude/commands/<name>.md` that invokes `swarm:workflow-rules` for governance and the local mode skill for domain spec. Generated by `/swarm:create-workflow`.
- **`/swarm:update-workflow <name>`** — regenerates the plugin-owned `## Workflow` section of a shortcut command from the current template. Shows a diff and requires confirmation. Never touches the mode skill (consumer-owned).

`swarm:workflow-rules` is the governance bridge: it provides hard rules, briefing templates, launch mechanics, and the extension-mode contract so that project-local commands (which cannot access `${CLAUDE_PLUGIN_ROOT}`) get swarm governance at runtime via the Skill tool.

**Extension hard contract.** Wrappers cannot override the base's phase arc, lead identity, or facilitator. Their Mode-Specific Rules and Lead Allowlist additions are additive-only — they may add but never remove or contradict base-mode governance. A workflow that needs to change phase semantics must be authored as a full custom mode.

**Full custom mode skill interface (including built-in plugin modes):**
1. Lead Identity
2. Facilitator Title
3. Facilitator Identity
4. Lead Allowlist (optional — permitted/forbidden actions)
5. Pre-flight Reads (optional — domain knowledge files to read before spawning)
6. Mode-Specific Rules
7. Information Flow (optional — custom routing rules)
8. Outcomes Question (optional — domain-specific question for the user)
9. Suggest-Members Guidance
10. Phase Arc

**Custom mode skill interface — wrapper:**
1. `extends:` frontmatter naming the base mode
2. Extension Contract (inlined in the body as documentation)
3. Mode-Specific Rules (additive)
4. Lead Allowlist (additions)
5. Suggest-Members Guidance (supplement)

Generated files carry a `generated-by: swarm@<version>` frontmatter stamp — informational provenance that consumers can use to decide when to run `/swarm:update-workflow`.

## Key Conventions

- **Skill invocations** must use the Skill tool explicitly: "You MUST use the **Skill** tool to invoke `swarm:<name>`. Do NOT perform this step yourself."
- **All members except lead are read-only** (behavioral constraint in hard rules).
- **Hard rules live once** in `skills/workflow-rules/SKILL.md` (canonical); launch.md Step 1 invokes it rather than mirroring it. Edits to the hard rules there are user customizations — preserve them during upgrades.
- **Terse definitions.** One sentence for agent roles, few lines for skills. More context makes LLMs worse (VISION.md compression principle).

## Development Notes

- No build step, no tests, no linter. The deliverables are markdown prompts.
- **`disable-model-invocation: true`** frontmatter on command files tells Claude Code to hide the command from model-suggested invocations — users invoke it explicitly via `/swarm:<name>`. All swarm shortcut commands use this flag; remove only if a command should be proactively offered by the model.
- `REFERENCE_PROMPT.md` is gitignored — it's the original requirements doc, kept locally for reference.
- Plugin enablement requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` in Claude Code settings.
- Swarm requires Claude Code ≥ v2.1.178 (the implicit team-formation model; the old TeamCreate path was dropped 2026-07).
- **No maintainer commentary in shipped files.** Commands and skills are consumed by the model on every run — rationale, provenance, and future-enhancement notes go in the Maintainer Notes section below, never in HTML comments inside `commands/` or `skills/`.
- **Governance is single-source.** `skills/workflow-rules/SKILL.md` is the canonical home of hard rules, briefing templates, launch mechanics, and the pulse; launch.md references it (Step 1, Step 8) rather than mirroring it. Do not re-inline governance into launch.md — the pre-2026-07 mirror demonstrably drifted (the two copies diverged on the Triage ship-check exemption and the confirmation-gate wording).

## Maintainer Notes

Dev-process rationale relocated out of shipped command/skill files (see the Development Notes rule above).

- **Version floor (v2.1.178+, 2026-07).** The TeamCreate/`team_name` version branch was removed: teams form implicitly at first spawn and `team_name` is never passed. Historical context: #40270 (team_name spawn-break) was an old-impl bug (~v2.1.86) that never bound current Claude Code; omit-`team_name` was the proven-safe choice on the implicit path, so the floor collapses the branch to never-pass. If explicit team creation ever returns, resurrect the branch from git history (launch.md 8a, pre-2026-07).
- **Mode-confirm modal removed with the two-beat flow (2026-07).** launch.md previously carried a deferred-relocation note on the Step 3 mode-confirm modal (guarding a fork-then-mode adjacency where a reflex-tap on the outcome fork could carry into the mode confirm). The two-beat flow removed that modal on all paths — mode is inferred silently and surfaced in the Step 7 summary. If a mode-confirm modal is ever reintroduced adjacent to the outcome fork, re-evaluate that adjacency.
- **AskUserQuestion preemption provenance (live-team gate rules).** Preemption is upstream Claude Code, activated by the v2.1.178 implicit/background-spawn model: #64651 (OPEN) — background agent output streams into the foreground chat; #28627 (CLOSED) — the variant where teammate notifications render as Human turns in the lead's stream. The still-open #64651 is why preemption reproduces. Split-pane display (tmux/iTerm2, teammateMode auto) routes notifications out of the stream so the modal can't be preempted; the live-gate net best-efforts + recovers in-process terminals (Ghostty/VS Code). Durable fix is upstream. Do NOT force-set teammateMode — it silently falls back to in-process. Scope/fragility: the content-validity catch assumes a preempted modal returns a detectably-invalid result (rejection/empty) — observed-consistent at n=2, a sound basis for the recovery catch, not proven-universal. Proven on macOS/CLI; web/IDE entrypoint behavior is documented-not-tested. If a future Claude Code returns valid-looking stale content on preemption, the catch needs revisiting.
- **Step 0 future enhancement.** If a web/IDE entrypoint is reliably detectable (e.g. CLAUDE_CODE_ENTRYPOINT distinguishing web/vscode/jetbrains), the disabled branch could scope the "try proceeding" offer to those entrypoints rather than offering it on every empty read. Precondition: confirm CLAUDE_CODE_ENTRYPOINT actually differentiates entrypoints. The soft-hedge in Step 0 is correct regardless.
- **8c future enhancement (flag-set-but-unwired, #34750).** A Step-0 corroborator checking SendMessage availability could catch the silent no-teammate case BEFORE spawning. Cut from v1 because SendMessage is a deferred tool, so its presence is ambiguous to read; revisit if SendMessage becomes non-deferred. The 8c spawn guardrail is the v1 coverage.
- **Known limitation — Fable-tier lead: member model overrides not served (upstream, no swarm fix; revisit).** Observed 2026-07-02 on Claude Code v2.1.198: a non-fork subagent (`subagent_type: swarm-member`) spawned from a Fable-tier parent has its `model` override transmitted and resolved into the child's appended `<env>` block, but not honored by the serving layer — the child runs the parent's Fable weights while its own env and the spawn UI label it as the requested model. Model-agnostic: observed-consistent for `opus` (n=2) and `sonnet` (n=1) in in-session control probes — not proven-universal — with BOTH tiers affected (Ultra and Balanced alike; Balanced is the worse surprise — "cheaper members" silently draw Fable compute and quota). Upstream evidence: the request→serving divergence is downstream of everything the caller controls — the Agent `model` field is a closed alias enum (no concrete-ID workaround), and the tool contract says the override is ignored only for `fork`, so the alias should bind for swarm-member spawns. Swarm-side response is no-fix by user decision (2026-07-02): swarm already requests the right model; bites only when the lead runs on Fable. Revisit hook: the child's context is internally contradictory (harness `<env>` reports the requested model; the server persona line says Fable), so any future detect/warn must key off the server-injected persona line — the harness-reported model cannot reveal the mismatch. That signal is only readable inside the member, so surfacing it needs a member self-report — which collides with the briefing-template anti-ratchet ban above; a revisit must resolve that collision (the protocol-mechanics carve-out or a non-brief channel), not add sections to the briefs.
- **Gate presentation: two-container split (main-window markdown plan + self-sufficient plain-text modal digest) — do not restore the in-modal cram.** Runtime facts (verified on v2.1.198; may drift): the AskUserQuestion question field renders PLAIN TEXT — it does not run the markdown renderer, so `##`/`**` show as literal syntax — and the schema has NO `.max()` on question text or option descriptions, so every over-length failure is SILENT truncation (the old "hard cap fails loud" claim here was wrong; there is no loud failure). Provenance (diff-verified chronology #77→#78→#80→#81): #78 (9d315e7) collapsed the multi-stop setup flow, so setup content and the modal began emitting in one no-pause turn; #80 (8f6dcc3) restored the stop boundaries but kept same-turn emission; #81 (c0d0022) then moved the plan INTO the modal — the cram — as an overcorrection. The observation motivating #81 ("the user saw nothing" despite the prose being emitted) is best explained as a viewport effect — new output auto-pinning the view to the modal, covering same-turn prose in both orderings — but that covering mechanism, like the bridge from #78's collapse to the specific live observation, is reconstructed rationale: consistent with all evidence, not pixel-verified. Verified fact (keep firm): the modal is a live bottom-region component and completed turns commit to static scrollback, so covering is NOT destruction — the main-window plan stays durable and scrollable (default renderer = terminal-native scrollback; opt-in fullscreen/alt-screen = app-managed scroll — phrase visibility as "durable and scrollable," don't pin to a scroll mechanism). The shipped design therefore splits the jobs: the full plan renders as markdown in the main window (readable, durable, referenceable while typing "I have changes" free-text), and the modal carries a gate-specific plain-text digest self-sufficient for that gate's decision — Step 4 carries names + one-line identities (identities ARE the decision content); Step 7 reduces to name-only roster + tier + mode + ship def (launch authorization, not re-judging) — front-loaded (Team + Cost tier first) to survive silent render-clip. This two-container rule governs every setup/confirmation gate — launch Steps 4 & 7, the generated workflow-command step 5, and /swarm:refine Step 3 — not just the two detailed here. If a same-turn modal covers the freshly-rendered plan, that is #81's re-derivation trap, not a reason to move the plan back into the modal: the plan remains in scrollback and the modal is self-sufficient by design. Known residual: shortcuts generated before this change keep the old cram wording until their repo runs `/swarm:update-workflow`.
