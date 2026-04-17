# Swarm

Good Claude Code sessions are repeatable. Swarm is the structure that makes them that way.

I built this across hundreds of sessions, pruning rules, memories, and skills until the quality stopped varying. When model quality shifted, small targeted changes kept it working, even on smaller models. Once the results were consistent enough to rely on, I started sharing with teammates and friends.

## Prerequisites

Agent teams must be enabled in Claude Code. Add to `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

The launch command checks this automatically and guides you through enablement if it's missing.

## Installation

```bash
claude plugin marketplace add DheerG/swarms
claude plugin install swarm@swarms --scope project
```

For development or local testing:

```bash
claude --plugin-dir /path/to/swarms
```

Changes take effect in the next session.

## Usage

### Launch a team

```
/swarm:launch
```

Describe your outcomes, choose defaults or configure each step, review the plan, then launch. Pass outcomes inline to skip the opening question:

```
/swarm:write Help me write a blog article on healing traumas
```

### Mode shortcuts

```
/swarm:code           # Code team
/swarm:write          # Writing team
/swarm:general        # General team
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
/swarm:audit-context      # Check your project for artifacts that may interfere with swarm
/swarm:refine-outcomes    # Reframe ideas into outcome statements
/swarm:suggest-members    # Recommend team composition
```

## How it works

Every team follows the same phase arc: Research, Converge, Approve, Execute, Review, Refine, Deliver. Phases run in order.

Review is recursive: if the team doesn't reach a 9/10 confidence score, it cycles back through Refine before presenting to you. The facilitator drives this, not the lead. Work reaches you only after the team has agreed it clears the threshold. Most of the quality work happens in the cycles you never see.

## Watching your team

The most useful signal isn't the final output. It's the discussion. Watching agents reason, push back, and converge tells you whether the team is actually working. [AgentChat](https://github.com/DheerG/agent-chat) is a companion tool that surfaces agent conversations in real time. You'll likely find yourself watching the discussion more than Claude Code itself.

## Custom workflows

Run `/swarm:create-workflow` to scaffold a custom mode for your project: domain-specific phases plus a shortcut command. Use `/swarm:workflow <mode-name>` to launch against any existing custom mode.

## Updating

Run `/swarm:update` to check for and install the latest version.

```bash
claude plugin marketplace update swarms
claude plugin update swarm@swarms --scope project
```

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
