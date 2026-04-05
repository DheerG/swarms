# Swarm

A Claude Code plugin for launching agent teams with reusable roles, rules, and interactive setup.

## What It Does

Swarm turns lengthy, repetitive team-setup prompts into a single command. Instead of writing hundreds of lines every time you want an agent team, run `/swarm:launch` and answer three questions. The plugin handles team creation, role assignment, rule enforcement, and coordination.

## Installation

### From a plugin directory

```bash
claude --plugin-dir /path/to/swarm
```

### From a marketplace (when published)

```bash
claude plugin install swarm
```

## Usage

### Launch a team

```
/swarm:launch
```

The command walks you through an interactive setup:

1. **Outcomes** — What are you trying to achieve?
2. **Team members** — Who should be on the team? (Lead + Principal Engineer always included)
3. **Lead research** — Should the lead be able to do research? (Default: no)

After confirming, the plugin creates your team and begins work.

### Refine outcomes

```
/swarm:refine-outcomes
```

Helps reframe implementation steps into outcome statements. Available during team setup or standalone.

### Suggest team members

```
/swarm:suggest-members
```

Recommends team composition based on your stated outcomes. Available during team setup or standalone.

## Prerequisites

Agent teams must be enabled in Claude Code. Add to `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

The `/swarm:launch` command checks this automatically and guides you through enablement if needed.

## Customizing Rules

The plugin ships with default hard rules in `references/rules/hard-rules.md`. On first run, these are copied to your persistent plugin data directory where you can edit them freely. Plugin upgrades replace the defaults but never overwrite your personal copy.

## Ubiquitous Language

This plugin uses consistent terminology:

| Term | Meaning |
|------|---------|
| **swarm** | The plugin/capability |
| **team** | A specific group of agents launched for a task |
| **lead** | The main session that coordinates and writes code |
| **member** | A teammate agent (read-only) |
| **outcome** | What the user wants to achieve |
| **role** | A reusable agent definition |
| **rules** | Hard constraints governing team behavior |
| **launch** | Start a team via `/swarm:launch` |

## License

MIT
