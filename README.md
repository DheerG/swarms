# Swarm

A Claude Code plugin for launching agent teams for code, writing, and general-purpose work.

## What It Does

Swarm turns team-setup into a single command. Describe your outcomes, choose defaults or configure each step, and the plugin handles mode selection, team creation, role assignment, rule enforcement, and coordination.

## Installation

### From GitHub (recommended)

```bash
claude plugin marketplace add DheerG/swarms
claude plugin install swarm@swarms --scope project
```

### For development/testing

```bash
claude --plugin-dir /path/to/swarms
```

Loads the plugin directly from local source, bypassing the marketplace cache. Changes take effect in the next session.

## Usage

### Launch a team

```
/swarm:launch
```

Interactive setup: provide outcomes, choose defaults or configure (mode, team, shape, research), review the plan, then launch.

### Mode shortcuts

Skip mode selection and streamline setup:

```
/swarm:code           # Code team
/swarm:write          # Writing team
/swarm:general        # General team
```

Pass outcomes inline to go even faster:

```
/swarm:write Help me write a blog article on healing traumas
```

### Modes

| Mode | Lead | Facilitator | Review |
|------|------|-------------|--------|
| **Code** | Writes code | Principal Engineer | Technical review |
| **Writing** | Coordinates (can write) | Editorial Director | Editor-sandwich review |
| **General** | Produces deliverable | Chief of Staff | Facilitator-driven review |

### Team shapes

| Shape | Members | Facilitator |
|-------|---------|-------------|
| **Balanced** (default) | Sonnet | Opus |
| **Ultra** | Opus | Opus |

### Other skills

```
/swarm:refine-outcomes    # Reframe ideas into outcome statements
/swarm:suggest-members    # Recommend team composition
```

## Updating

Run `/swarm:update` to check for and install the latest version.

Manual update:

```bash
claude plugin marketplace update swarms
claude plugin update swarm@swarms --scope project
```

## Prerequisites

Agent teams must be enabled in Claude Code. Add to `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

The launch command checks this automatically and guides you through enablement.

## Customizing Rules

Hard rules are in `commands/launch.md` under "Hard Rules." Mode-specific rules are in each mode's skill file under `skills/mode-*/SKILL.md`. Edit directly. Re-apply edits after upgrading.

## Ubiquitous Language

| Term | Meaning |
|------|---------|
| **swarm** | The plugin |
| **team** | A group of agents launched for a task |
| **lead** | The main session that coordinates work |
| **member** | A teammate agent (read-only) |
| **facilitator** | The Socratic facilitator role (Principal Engineer / Editorial Director / Chief of Staff) |
| **outcome** | What the user wants to achieve |
| **mode** | The team's domain configuration (Code, Writing, General) |
| **shape** | Model allocation tier (Balanced, Ultra) |
| **phase arc** | Research, Converge, Approve, Execute, Review, Deliver |
| **launch** | Start a team via `/swarm:launch` or a mode shortcut |

## Contributing

All changes go through branches and pull requests. Automated version bumps by `github-actions[bot]` are the only exception.

## License

MIT
