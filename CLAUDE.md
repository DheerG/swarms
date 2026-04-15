# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Anti-ratchet constraint on launch.md

launch.md Step 8 briefing templates are FIXED. Do not add sections to member briefs. Do not prescribe investigation steps. Do not introduce "first action" items or acknowledgment rituals. If a team run reveals a member needs more context, the fix is to improve the noun-phrase identity in suggest-members, NOT to add sections to the briefing template. This constraint exists because the briefing templates are an observed regression vector — commit f7db555 sprayed "quality-oriented" framing into every brief and created FM-3.1 (premature termination) + FM-1.3 (step repetition) failure modes users observed.

**Carve-out: harness protocol mechanics are permitted.** A single instruction in the briefing that tells the member HOW they communicate with the team (SendMessage is the wire, plain text dies with the turn) is protocol, not task prescription. It does not describe what to investigate, when to act, or what "done" looks like — it only describes the transport layer. Protocol mechanics are allowed. **Task framing, lifecycle framing, phase framing, acknowledgment rituals, and "first action" directives remain forbidden.**

## What This Is

Swarm is a Claude Code plugin for launching agent teams. Six commands — `/swarm:launch` (catch-all), `/swarm:code`, `/swarm:write`, `/swarm:general` (mode shortcuts), `/swarm:workflow` (custom mode entry point), `/swarm:create-workflow` (scaffolding) — drive an interactive setup that creates a coordinated team of agents with defined roles and rules. Users can extend swarm by creating custom mode skills in their own codebases.

## Architecture

**Everything is a prompt.** No runtime composition, no imports, no framework. Commands and skills are self-contained markdown files consumed by the model in one pass.

```
commands/launch.md          # Catch-all command — interactive team setup (Steps 0–8)
commands/code.md            # Mode shortcut — pre-selects Code, delegates to launch.md
commands/write.md           # Mode shortcut — pre-selects Writing, delegates to launch.md
commands/general.md         # Mode shortcut — pre-selects General, delegates to launch.md
commands/workflow.md         # Custom mode entry point — takes a mode skill name, delegates to launch.md
commands/create-workflow.md  # Scaffolding — interviews user, generates mode skill + shortcut command
skills/code-mode/           # Code mode: lead identity, PE title, rules, phase arc
skills/writing-mode/        # Writing mode: lead identity, PE title, ownership boundaries, editorial baseline, phase arc
skills/general-mode/        # General mode: lead identity, PE title, lightweight default
skills/workflow-rules/      # Governance spec for custom workflows — hard rules, briefing templates, launch mechanics
skills/refine-outcomes/     # Converts implementation descriptions into outcome statements
skills/suggest-members/     # Recommends team composition based on outcomes and mode
skills/writing-style/       # Structural pattern analysis (trope detection) for writing-mode review
skills/resolve-dispute/     # Resolves stuck review findings via put-up-or-concede exchange
skills/define-rubric/       # Available skill for teams that genuinely need formal validation criteria
.claude-plugin/plugin.json  # Plugin manifest
.claude-plugin/marketplace.json  # Marketplace registry entry
```

**Commands** are entry points that can spawn teams (TeamCreate + Agent). Shortcut commands (`/swarm:code`, `/swarm:write`, `/swarm:general`) use `${CLAUDE_PLUGIN_ROOT}` to read launch.md and execute it with mode pre-set. `/swarm:workflow` is the generic entry point for custom modes — it takes a mode skill name as argument. `/swarm:create-workflow` scaffolds a custom mode skill + shortcut command in the user's project. **Skills** are helpers invoked via the Skill tool — they cannot launch teams. **Mode skills** (`swarm:code-mode`, `swarm:writing-mode`, `swarm:general-mode`, and user-defined custom modes) are invoked by the team lead at Step 8b; they return the phase arc and mode-specific rules for that run. `swarm:workflow-rules` returns the universal governance spec (hard rules, briefing templates, launch mechanics) for use by user-authored shortcut commands that cannot access `${CLAUDE_PLUGIN_ROOT}`.

### How launch.md Works

Step 0 (pre-flight) → Step 1 (universal hard rules) → Step 2 (outcomes + defaults/configure fork) → Step 3 (mode selection) → Step 4 (team members, mode-aware) → Step 5 (team shape) → Step 6 (lead research toggle) → Step 7 (confirmation) → Step 8 (spawn and execute).

After outcomes are confirmed, Step 2 asks "Use defaults or Configure each step?" The defaults path silently infers mode, suggests a team, applies Balanced shape and no lead research, then skips to Step 7 confirmation. The configure path walks through Steps 3–6 individually. Steps 3–6 also serve as reference definitions when the user says "I have changes" at Step 7.

`$ARGUMENTS` is substituted by Claude Code before the model sees the prompt. If the user passes args to `/swarm:launch`, they appear in the `## User-Provided Context` section and the outcomes question is skipped. Mode is inferred from the outcomes when unambiguous. Shortcut commands (`/swarm:code`, `/swarm:write`, `/swarm:general`) read launch.md via `${CLAUDE_PLUGIN_ROOT}` and execute it with mode pre-set and a streamlined outcomes flow.

### Team Execution Phase Arc

The phase arc skeleton is universal: Research → Converge → Approve → Execute → Review → Refine → Deliver. The mode skill (invoked at Step 8b) defines what each phase means — who acts, what the deliverable is, how review works. Code mode and Writing mode have meaningfully different phase semantics.

### Mode Skills

Mode skills are invoked by the team lead at runtime (Step 8b) using the Skill tool. Built-in modes use the `swarm:` prefix (`swarm:code-mode`, `swarm:writing-mode`, `swarm:general-mode`). Custom modes use their unqualified name (`blog-mode`, `code-review-mode`). Each returns: lead identity, PE title, PE identity line, mode-specific rules, suggest-members guidance, and a phase arc. Custom modes may additionally include a Lead Allowlist, Pre-flight Reads, and Information Flow section.

### Custom Workflows

Users extend swarm by creating **custom mode skills** in their project's `.claude/skills/` directory. A custom mode follows the same interface as built-in modes. Entry points:

- **`/swarm:workflow <mode-name>`** — plugin-shipped command, reads launch.md for governance, invokes the user's local mode skill at Step 8b.
- **Per-workflow shortcut** — a project-local `.claude/commands/<name>.md` that invokes `swarm:workflow-rules` for governance and the local mode skill for domain spec. Generated by `/swarm:create-workflow`.

`swarm:workflow-rules` is the governance bridge: it provides hard rules, briefing templates, and launch mechanics so that project-local commands (which cannot access `${CLAUDE_PLUGIN_ROOT}`) get swarm governance at runtime via the Skill tool.

**Custom mode skill interface:**
1. Lead Identity
2. PE Title
3. PE Identity
4. Lead Allowlist (optional — permitted/forbidden actions)
5. Pre-flight Reads (optional — domain knowledge files to read before spawning)
6. Mode-Specific Rules
7. Information Flow (optional — custom routing rules)
8. Outcomes Question (optional — domain-specific question for the user)
9. Suggest-Members Guidance
10. Phase Arc

## Key Conventions

- **Skill invocations** must use the Skill tool explicitly: "You MUST use the **Skill** tool to invoke `swarm:<name>`. Do NOT perform this step yourself."
- **All members except lead are read-only** (behavioral constraint in hard rules).
- **Hard rules are inline** in launch.md Step 1 (canonical) and mirrored in `skills/workflow-rules/SKILL.md` for local shortcut commands. Edits to launch.md Step 1 are user customizations — preserve them during upgrades and propagate to workflow-rules.
- **Terse definitions.** One sentence for agent roles, few lines for skills. More context makes LLMs worse (VISION.md compression principle).

## Development Notes

- No build step, no tests, no linter. The deliverables are markdown prompts.
- `REFERENCE_PROMPT.md` is gitignored — it's the original requirements doc, kept locally for reference.
- Plugin enablement requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` in Claude Code settings.
- **Governance sync.** `skills/workflow-rules/SKILL.md` inlines the hard rules from launch.md Step 1. When updating hard rules in launch.md, propagate changes to `workflow-rules/SKILL.md`. launch.md Step 1 is the canonical source.
