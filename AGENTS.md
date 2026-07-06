# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Anti-ratchet constraint on the briefing templates

- **The briefing templates are FIXED** (canonical in skills/workflow-rules/SKILL.md). No added sections, no prescribed investigation steps, no "first action" items, no acknowledgment rituals. If a member needs more context, improve the noun-phrase identity in suggest-members — never the template. (Observed regression vector: f7db555 sprayed framing into every brief → premature-termination and step-repetition failures.)
- **Carve-out: harness protocol mechanics are permitted.** One instruction on HOW members communicate (SendMessage is the wire; plain text dies with the turn) is transport, not task prescription. Task framing, lifecycle framing, phase framing, and rituals remain forbidden.

## What This Is

Swarm is a Claude Code plugin for launching agent teams. Eight commands drive an interactive setup that creates a coordinated team with defined roles and rules; users extend it with custom mode skills — full modes or thin wrappers over a built-in mode.

## Architecture

**Everything is a prompt.** No runtime composition, no imports, no framework — self-contained markdown consumed in one pass.

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
skills/workflow-rules/      # CANONICAL governance spec — hard rules, briefing templates, gate presentation contract, launch mechanics, pulse
skills/gate-presentation/   # Frozen per-gate constants (question/options/digest/preview) — invoked fresh at each gate
skills/suggest-members/     # Recommends team composition based on outcomes and mode
skills/writing-style/       # Structural pattern analysis (trope detection) for writing-mode review
skills/resolve-dispute/     # Resolves stuck review findings via put-up-or-concede exchange
skills/define-rubric/       # Available skill for teams that genuinely need formal validation criteria
skills/independent-review-loop/  # Independent pre-delivery review loop — Codex or swarm-native fallback
.claude-plugin/plugin.json  # Plugin manifest
.claude-plugin/marketplace.json  # Marketplace registry entry
.claude/swarm-ship.md       # Per-project ship definition (created at first launch, user-owned)
```

- **Commands** spawn teams (Agent tool; teams form implicitly at first spawn; requires Claude Code ≥ v2.1.178). Shortcuts read launch.md via `${CLAUDE_PLUGIN_ROOT}` and run it with mode pre-set; `/swarm:workflow` takes a custom mode name as argument.
- **Skills** are Skill-tool helpers — they cannot launch teams. Mode skills are invoked by the lead at Step 8b and return the phase arc + mode rules. `swarm:workflow-rules` is the canonical governance spec (hard rules, briefing templates, gate presentation contract, launch mechanics, pulse) — invoked by launch.md Step 1 and by project-local commands that cannot read `${CLAUDE_PLUGIN_ROOT}`. `swarm:gate-presentation` holds the frozen per-gate constants, invoked fresh at each gate.

### How launch.md works

- **Flow:** Step 0 pre-flight → Step 1 governance → Step 2 (outcomes → explicit tier pick → silent mode inference + suggest-members → team approval) → Step 7 confirmation → Step 8 spawn. Steps 3–6 are definitions serving Step 2 and "I have changes," not a walked sequence.
- **Three gates stand between outcomes and spawn — tier, team, launch.** Inline `$ARGUMENTS` outcomes exempt none of them (that skip caused a real regression). `$ARGUMENTS` is substituted before the model sees the prompt; when present, only the outcomes question is skipped.
- **Step 7 and Step 8 labels are load-bearing cross-references** throughout the plugin — keep the names.

### Phase arc

Research → Converge → Approve → Execute → Review → Refine → Deliver — the universal skeleton; the mode skill defines each phase's semantics and may omit a phase. Triage drops Refine (a diagnosis has an evidentiary terminal); its Deliver restates the omission so the lead doesn't re-import the refine-or-deliver question by habit.

### Independent review loop

- **What:** an independent reviewer (Codex preferred; swarm-native fallback of fresh Codex-style subagents) reads the whole branch diff against the approved outcome; the lead triages, fixes in-scope functional findings, and re-runs until clean (backstop 15 rounds; oscillation → user). Differentiator: independence + exhaustiveness — distinct from the recursive-refinement ladder, never a replacement.
- **When:** offered at code-mode's unified pre-ship gate (recursive+independent / recursive only / independent only / ship as is); runs at Deliver AFTER the ship steps. No GitHub PR required — the PR is only a push target. The lead relays every round's reviewer output verbatim with a one-line disposition, clean rounds included.
- **Engine:** persists to `.claude/swarm-review.md` (ask-once / read-thereafter; a saved pref selects but never asserts availability — re-checks at runtime, degrades without rewriting the file). Codex runs read-only via stdin (`codex exec review -`); depends only on the `codex` binary. Usage-limit errors auto-wait on a durable `codex-reset-wait` task within a ~5–6h cap, escalating beyond it. Rubric adapted from OpenAI Codex (`codex-rs`, Apache-2.0).
- **Durable state, not recall:** the gate records `independent-review-loop pending` as a run-state task; Deliver branches on it (ship → loop → terminal). The run-state task list is a closed two-item vocabulary defined in workflow-rules — not a general tracker. The pulse ends the run at the true terminal (CronDelete first, then keep-open/shutdown); its two governing rules live in Team Lead Rules, never General Rules.
- **The pulse holds pending decisions two deliberately-different ways — do not harmonize.** A codex-reset-wait escalation surfaces once then holds (its durable task survives compaction); an AFK-timed-out decision gate is re-emitted in full on each hold (the re-emission is what survives compaction). Kept here, never in the shipped pulse prompt.

### Mode skills and custom workflows

- **Invocation:** the lead invokes the mode skill at Step 8b — built-ins with the `swarm:` prefix, custom modes by unqualified name from the project's `.claude/skills/`.
- **Full-mode interface:** Lead Identity; Facilitator Title; Facilitator Identity; Lead Allowlist (opt); Pre-flight Reads (opt); Mode-Specific Rules; Information Flow (opt); Outcomes Question (opt); Suggest-Members Guidance; Phase Arc.
- **Wrapper interface:** `extends:` frontmatter; Extension Contract; additive Mode-Specific Rules; Lead Allowlist additions; Suggest-Members supplement. Any full mode is a valid wrapper base.
- **Extension hard contract:** wrappers cannot override the base's phase arc, lead identity, or facilitator; their additions are additive-only. A workflow needing different phase semantics is authored as a full mode.
- **Entry points:** `/swarm:workflow <mode>` (plugin-shipped; resolves `extends:` at runtime); per-workflow shortcuts generated by `/swarm:create-workflow` (they invoke `swarm:workflow-rules` for governance); `/swarm:update-workflow <name>` regenerates only the plugin-owned `## Workflow` section, with diff + confirmation. Generated files carry `generated-by: swarm@<version>`.

## Key Conventions

- **Skill invocations** must use the Skill tool explicitly: "You MUST use the **Skill** tool to invoke `swarm:<name>`. Do NOT perform this step yourself."
- **All members except lead are read-only** (behavioral constraint in hard rules).
- **Hard rules live once** in `skills/workflow-rules/SKILL.md` (canonical); launch.md Step 1 invokes it rather than mirroring it. Edits to the hard rules there are user customizations — preserve them during upgrades.
- **Terse definitions.** One sentence for agent roles, few lines for skills. More context makes LLMs worse (VISION.md compression principle).

## Development Notes

- No build step, no tests, no linter. The deliverables are markdown prompts.
- **`disable-model-invocation: true`** on all shortcut commands — users invoke explicitly; remove only if a command should be model-offered.
- `REFERENCE_PROMPT.md` is gitignored — the original requirements doc, kept locally.
- Plugin enablement requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"`; swarm requires Claude Code ≥ v2.1.178 (TeamCreate path dropped 2026-07).
- **No maintainer commentary in shipped files.** Rationale, provenance, and future-enhancement notes go in Maintainer Notes below — never in `commands/` or `skills/`.
- **Governance is single-source.** `skills/workflow-rules/SKILL.md` is canonical; launch.md references it (Step 1, Step 8). Do not re-inline governance into launch.md — the pre-2026-07 mirror demonstrably drifted.

## Maintainer Notes

Dev-process rationale relocated out of shipped command/skill files (see Development Notes).

- **Version floor (v2.1.178+, 2026-07).** The TeamCreate/`team_name` branch was removed — teams form implicitly, `team_name` never passed. If explicit team creation returns, resurrect from git history (launch.md 8a, pre-2026-07).
- **Mode-confirm modal removed (2026-07).** Mode is inferred silently and surfaced at Step 7. If a mode-confirm modal is reintroduced adjacent to the outcome fork, re-evaluate the reflex-tap adjacency.
- **AskUserQuestion preemption is upstream (#64651 OPEN).** Live teammate notifications can preempt a modal; split-pane (tmux/iTerm2) avoids it; the live-gate net recovers in-process terminals. Do NOT force-set teammateMode — it silently falls back. The recovery catch assumes a preempted modal returns detectably-invalid content (observed n=2, not proven universal); revisit if a future Claude Code returns valid-looking stale content.
- **Step 0 future enhancement.** If CLAUDE_CODE_ENTRYPOINT reliably distinguishes web/IDE entrypoints, scope the disabled-branch "try proceeding" offer to them. Verify it actually differentiates first.
- **8c future enhancement (#34750).** A Step-0 SendMessage-availability check could catch the silent no-teammate case pre-spawn; cut because SendMessage is deferred (presence ambiguous). Revisit if it becomes non-deferred.
- **Known limitation — Fable-tier lead: member model overrides not served (upstream; no swarm fix by user decision 2026-07-02).** A swarm-member spawned from a Fable parent runs Fable weights despite the transmitted `model` override (opus n=2, sonnet n=1; both tiers — Balanced silently draws Fable quota). Any future detect/warn must key off the server persona line inside the member; a member self-report collides with the anti-ratchet ban — resolve via the protocol carve-out or a non-brief channel, never brief sections.
- **Gate presentation is catalog-driven, split hybrid** (contract, partition rule, and authoring rubric: the Gate Presentation section in skills/workflow-rules/SKILL.md; frozen per-gate constants: skills/gate-presentation/SKILL.md, invoked fresh at each gate and rendered same-turn). Each lead→user gate is a frozen constant — question, header, options, digest field-list, preview content — projected into three renders (question text / option `preview` / AFK plain-text restatement) under a verbatim-transport contract: runtime fills declared slots and selects among frozen options, never authors shape. The hybrid split is a user decision (2026-07-03) over the resident-section shape it replaced: constants are byte-sensitive and the late gates (Approve/Finish/Refine/Terminal) render post-compaction — a compaction preserves meaning, not bytes — so constants re-read from disk per gate, while the discipline rules are comprehension-material and stay resident. Partition rule: no field in two carriers at the same fidelity — question carries handles, preview carries elaboration. Sites (launch Steps 2/4/7, /swarm:refine Step 3, generated workflow steps 3–5, mode-skill Approve/Finish/Refine/Terminal gates) name their gate only — the invoke-fresh instruction lives ONCE, as a Team Lead rule in workflow-rules (user steer 2026-07-03: no per-site invocation boilerplate); do not re-inline presentation at a site, and do not fold the constants back into workflow-rules. The transport layer is verifiable (string-match against the catalog); the authoring rubric is an authoring-time aid, not a runtime guarantee. Runtime facts (v2.1.198): question field renders plain text only; `preview` renders markdown (single-select only); no schema caps — over-length truncates silently. Two dead ends, do not re-walk: don't cram the full markdown block into the question text — it renders as literal syntax noise and flattens into an unreadable wall; and don't instruct "print the plan in the main window" — that target is undefined for the executing model, and the same-turn modal covers whatever gets printed anyway (also why the Approve synthesis now rides in the modal preview). Both were shipped and reverted (history, if needed: PRs #78/#81/#83). Residual: pre-change shortcuts keep old wording until their repo runs `/swarm:update-workflow`.
