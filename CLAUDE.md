# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Anti-ratchet constraint on launch.md

launch.md Step 6 briefing templates are FIXED. Do not add sections to member briefs. Do not prescribe investigation steps. Do not introduce "first action" items or acknowledgment rituals. If a team run reveals a member needs more context, the fix is to improve the noun-phrase identity in suggest-members, NOT to add sections to the briefing template. This constraint exists because the briefing templates are an observed regression vector — commit f7db555 sprayed "quality-oriented" framing into every brief and created FM-3.1 (premature termination) + FM-1.3 (step repetition) failure modes users observed.

## What This Is

Swarm is a Claude Code plugin for launching agent teams. One command (`/swarm:launch`) drives an interactive setup that creates a coordinated team of agents with defined roles and rules.

## Architecture

**Everything is a prompt.** No runtime composition, no imports, no framework. Commands and skills are self-contained markdown files consumed by the model in one pass.

```
commands/launch.md          # The only command — interactive team setup (6 steps)
skills/refine-outcomes/     # Converts implementation descriptions into outcome statements
skills/suggest-members/     # Recommends team composition based on outcomes
skills/define-rubric/       # Available skill for teams that genuinely need formal validation criteria (not referenced from launch.md)
.claude-plugin/plugin.json  # Plugin manifest
.claude-plugin/marketplace.json  # Marketplace registry entry
```

**Commands** are entry points that can spawn teams (TeamCreate + Agent). **Skills** are helpers invoked via the Skill tool — they cannot launch teams.

### How launch.md Works

Step 0 (pre-flight) → Step 1 (hard rules) → Step 2 (outcomes, with `$ARGUMENTS` support) → Step 3 (team members) → Step 4 (lead research toggle) → Step 5 (confirmation) → Step 6 (spawn and execute).

`$ARGUMENTS` is substituted by Claude Code before the model sees the prompt. If the user passes args to `/swarm:launch`, they appear in the `## User-Provided Context` section and the outcomes question is skipped.

### Team Execution Phase Arc

Research → Converge (PE runs roundtable, drives toward agreed approach) → Approve (user greenlights) → Execute (lead only) → Review (team evaluates output against what was agreed) → Deliver.

## Key Conventions

- **Skill invocations** must use the Skill tool explicitly: "You MUST use the **Skill** tool to invoke `swarm:<name>`. Do NOT perform this step yourself."
- **All members except lead are read-only** (spawned as Explore subagents).
- **Hard rules are inline** in launch.md Step 1. Edits there are user customizations — preserve them during upgrades.
- **Terse definitions.** One sentence for agent roles, few lines for skills. More context makes LLMs worse (VISION.md compression principle).

## Development Notes

- No build step, no tests, no linter. The deliverables are markdown prompts.
- `REFERENCE_PROMPT.md` is gitignored — it's the original requirements doc, kept locally for reference.
- Plugin enablement requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` in Claude Code settings.
