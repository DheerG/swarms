# Swarm

**Describe what you want. Get a reviewed, ship-ready PR — without babysitting the agent.**

Out-of-the-box agent teams rubber-stamp their own work. Swarm's team argues with itself, and won't hand you the work until it's actually ready to ship.

```
/swarm:code fix the flaky checkout test
```

Swarm spins up a small team of Claude agents that research the problem, debate the approach, build it, and review each other until the work is ready — then hand you a PR. You approve the plan and the approach, then stay out of the build. You have the final say before anything ships.

*Swarm also runs triage, writing, and general-purpose teams — see [other ways to launch](#commands).*

---

## What you get

- **Ships code that holds up** — reviewed by a different agent, not rubber-stamped by its author.
- **Runs unattended for hours — even across days.**
- **Survives interrupted turns without stalling.**
- **Avoids the rate-limit errors parallel teams hit — at a fraction of the tokens.**

---

## Quick start

Swarm is a [Claude Code](https://code.claude.com) plugin, so you'll need the CLI installed first.

```bash
claude plugin marketplace add DheerG/swarms
claude plugin install swarm@swarms --scope project
```

Agent teams must be enabled in Claude Code. Add this to `~/.claude/settings.json` (or let `/swarm:code` enable it for you on first run):

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Restart Claude Code so the plugin and the flag take effect, then run `/swarm:code` and describe what you want.

---

## How it works

Three moments need you. The rest runs itself.

1. **Tell it what you want** — 1-2 sentences describing the outcome. It has the ability to refine the outcome with you and work around prompting gotchas that would normally result in poor code.
2. **Approve the plan** — and, mid-run, the approach the team converged on. Nothing irreversible happens without your sign-off.
3. **Decide how to finish** — when the team hits the bar, you choose to refine further or ship; you see the result, not the debate.

You see the whole plan before a single agent runs:

> **Team Plan**
>
> **Mode:** Code
> **Outcomes:** (your words, verbatim)
> **Team:** lead (your Claude session) + Principal Engineer facilitator + specialists for the work
> **Cost tier:** Ultra
> **Ship definition:** Create a feature branch from main, commit, push, open PR
>
> ---
> **Is this plan final, or do you have remaining inputs?**
>
> - Launch the team — *Plan is final — start creating the team now*
> - I have changes — *Let me adjust outcomes, members, or settings first*

Nothing runs until you pick "Launch the team."

---

## A real Converge, in excerpt

Here is an excerpt from a real caching-strategy Converge:

> **Principal Engineer:** Two approaches on the table — cache-aside with a TTL, or read-through with invalidation on write. Security Reviewer, you flagged the TTL approach earlier. What's the actual risk you see?
>
> **Security Reviewer:** TTL means stale data can persist for up to N minutes after a permission change. If this endpoint returns authorization state, that's a window.
>
> **Principal Engineer:** Lead, does this endpoint return authorization state, or pure profile data?
>
> **Lead:** Profile data only — no permissions in the response.
>
> **Principal Engineer:** Then TTL risk is acceptable here. Team, any other concerns before I call CONVERGED?

Notice that the facilitator never settles the question itself. It hands the blocker to whoever can answer it and waits for evidence, and the lead fields that question like any other member. The security risk only surfaced because someone other than the implementer was looking. On their own, they'd have shipped the stale-data window. What reaches you is the conclusion; the argument stays inside the team.

---

## Why it works

### Outcomes over implementations

You describe what the world looks like when the work is done, rather than the steps to build it. That changes what the team debates.

- **Implementation framing:** "Add a Redis cache in front of the user service."
- **Outcome framing:** "User profile reads return in under 50ms and don't hit the DB when cached."

Implementation framing has the team comparing Redis and Memcached. Outcome framing has them weigh caching against query optimization, the wider and more useful argument.

### Everything is a prompt

Most agent frameworks bury what's actually running behind config and abstraction, so changing how the agents behave means digging through someone else's machinery. Swarm keeps the whole coordination system, from pre-flight through delivery, in one readable markdown file you can open:

```markdown
# /swarm:launch

You are launching an agent team using the Swarm plugin. Follow every step below in exact order...
```

No imports, no runtime composition. To change how a team works, you edit the prompt. Read the whole thing: [commands/launch.md](commands/launch.md).

### Recursive review until it's ready

The review gate is explicit and structural:

> 9/10+ means: logic is correct, tests pass where applicable, no regressions introduced, no known defects left unaddressed, reviewers would ship this.

Below the bar, the team cycles: lead fixes, team re-reviews. Above it, you get an optional refinement ladder (9.25 → 9.5 → 9.75 → 10) that drives the work to the full scope of your outcome. The critical mechanic: **the facilitator, not the lead, controls the gate.** The agent that did the work cannot declare its own work done. A model grading its own output usually waves it through. A reviewer with a different job, coming in fresh, actually pushes back.

You can also run the whole change past an independent reviewer, one that fails differently from the authors: a different model via Codex, or a fresh-context agent. It reads the change against your outcome before delivery, the lead fixes what it surfaces, and the loop repeats until nothing in scope remains.

### Built to run anyway

Long agent-team runs hit a wall that has nothing to do with the work: rate limits. Run the members in parallel and they hammer the API hard enough to trip those limits, and the whole run can stall out partway through, often without a word. Swarm avoids that by spawning members one at a time, which keeps it under the limits and, as a side effect, costs a fraction of a parallel team's tokens. A heartbeat keeps the lead moving, and if a turn gets cut off, the team re-checks its last action and picks up where it left off.

### Portable quality across environments

Every rule that governs a team is inline in the command file, and swarm governance wins over conflicting local context:

> Swarm governance rules take precedence over any conflicting project instructions (CLAUDE.md) or memory-system preferences during a team run.

That's why `/swarm:audit-context` exists — it flags ambient context (CLAUDE.md, memory, local skills, settings hooks) that could interfere before you launch. Run it before sharing a workflow with a teammate: if they get a different result, the cause is almost always their environment, not the prompt.

And all of this is built with swarm itself — its independent-review loop, serial cadence, and refinement ladder were each built by `/swarm:code` (PRs #67, #66, #48).

---

## Why I built this

I'm a principal engineer, and across hundreds of sessions I refined the rules and corrections I gave the team until the quality stopped varying — then kept going until it was writing better code than I do by hand. Once it was reliable, I shared it, and watched teammates get wildly different results from the same prompt. Their Claude had a different `CLAUDE.md`, different memories, different local skills. That ambient context quietly rewrote what they were trying to do. The prompt wasn't the problem; the environment around it was.

Swarm is the fix: it bundles the rules and the phases into one plugin, so what you share is what actually runs — on your machine or anyone else's. It's now used daily by other principal engineers and CTOs on their own codebases.

— Dheer ([dheer.co](https://dheer.co))

---

## Who this is for

Swarm is for you if:

- the same prompt gives you a great result one day and a mediocre one the next,
- you share prompts with people whose results never match yours, or
- you want a second, third, and fourth opinion enforced on every piece of work before it reaches you.

It is **not** a task manager (no backlog, no tickets) or a workflow framework (no DAGs, no YAML, nothing to wire together).

---

## Modes and tiers

| Mode | Lead | Facilitator | Review focus |
|------|------|-------------|--------------|
| **Code** | Writes code | Principal Engineer | Logic correctness, no regressions, reviewers would ship |
| **Triage** | Diagnoses (no changes) | Principal Investigator | Cause traced to the breaking point, blast radius, honest confidence; no Refine ladder |
| **Writing** | Coordinates (can write) | Editorial Director | Writer isolation, structural + line pass |
| **General** | Produces deliverable | Chief of Staff | Tailored to the deliverable type |

Shortcuts skip the mode question: `/swarm:code`, `/swarm:triage`, `/swarm:write`, `/swarm:general`.

| Tier | Members | Facilitator | When to use |
|------|---------|-------------|-------------|
| **Ultra** (recommended) | Opus | Opus | Reliable rule-following across the whole team |
| **Balanced** | Sonnet | Opus | Lower cost; well-scoped, lower-stakes work |

The facilitator is always Opus — it owns judgment review. Model names resolve through `ANTHROPIC_DEFAULT_OPUS_MODEL` / `ANTHROPIC_DEFAULT_SONNET_MODEL`, so swarm runs on any Anthropic-compatible provider (Bedrock, Vertex, OpenRouter, Fireworks, and others).

<details>
<summary><b>Advanced model config</b> — custom providers, 1M context, reasoning effort</summary>

**Custom providers.** Swarm works with any Anthropic-compatible provider. The lead session inherits your Claude Code model; spawned teammates use the `opus` and `sonnet` aliases, resolved through `ANTHROPIC_DEFAULT_OPUS_MODEL` and `ANTHROPIC_DEFAULT_SONNET_MODEL`. Point both at a capable model and both tiers work. Example for Fireworks AI:

```json
{
  "model": "accounts/fireworks/models/kimi-k2p5",
  "apiKeyHelper": "bash -c 'echo <your-provider-token>'",
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.fireworks.ai/inference",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "accounts/fireworks/models/kimi-k2p5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "accounts/fireworks/models/kimi-k2p5"
  }
}
```

Third-party providers typically wire credentials through `apiKeyHelper` rather than `ANTHROPIC_API_KEY`. If your provider's best model is meaningfully weaker than Opus, expect the review gate to take more iterations. (Installed before this worked? Run `/swarm:update`.)

**1M context for the facilitator (Anthropic API).** Opus 4.8 has a native 1M context window. On Max, Team, and Enterprise plans the `opus` alias is upgraded to 1M automatically; on Pro it needs extra usage; on API pay-as-you-go it's included. Pin it explicitly:

```json
{
  "env": {
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-8[1m]"
  }
}
```

This isn't about chasing the token limit — team runs rarely fill the window — it prevents quality loss from compaction on the rare larger run. Anthropic-direct only: `claude-opus-4-8[1m]` errors on Bedrock, Vertex, or Foundry, so don't set it if you've pointed the alias at a custom provider. To strengthen the lead (your own session), set `/model opus[1m]` directly.

**Reasoning effort is not a tier.** Swarm sets *which model* each teammate runs, not its reasoning effort — the spawn path honors `model` but ignores per-member `effort`. Lowering session effort (`/effort medium`) is a separate cost lever that stacks with the tier; below medium, the review and refine phases start going through the motions. Effort is session-wide, so it also lowers the facilitator. Separately, `CLAUDE_CODE_SUBAGENT_MODEL`, if set, forces one model for every teammate and collapses all tiers — unset it (or set `inherit`) for the tier picker to take effect.

</details>

---

## Commands

### Launch a team

```
/swarm:code              # Code team — the primary use
/swarm:triage            # Diagnose an issue without changing it
/swarm:write             # Writing team
/swarm:general           # General team
/swarm:launch            # Interactive setup (any mode)
/swarm:onboard           # Walkthrough for new users
```

Pass outcomes inline to skip the opening question:

```
/swarm:code fix the flaky checkout test
/swarm:write Help me write a blog article on healing trauma
```

### Refine an existing branch and PR

```
/swarm:refine            # Review and recursively refine the current branch/PR
```

`/swarm:refine` runs against work already on a branch — it reads the branch, the open PR (if any), and the diff against the PR's base, then enters at Review → Refine → Deliver. Pass the outcomes the branch was supposed to achieve, and a fixed roster of correctness, outcomes, and regression reviewers iterates the refinement ladder to 10. Use it when a PR is "almost done" and you want the team to push it the rest of the way.

### Other commands

```
/swarm:audit-context     # Detect ambient context that may interfere with swarm
/swarm:refine-outcomes   # Reframe ideas into outcome statements
/swarm:suggest-members   # Recommend team composition
/swarm:create-workflow   # Scaffold a custom mode for your project
/swarm:workflow <name>   # Launch against an existing custom mode
/swarm:update            # Check for and install the latest version
```

Swarm checks for updates on session start and mentions one in the assistant's first reply when available. (On the CLI the notice may also appear as a startup line; the VS Code, JetBrains, and web clients don't render startup hook messages, so the reply is the only place it shows there — [claude-code#15344](https://github.com/anthropics/claude-code/issues/15344).) Set `SWARM_SKIP_UPDATE_CHECK=1` to silence it.

---

## Custom workflows

When a workflow needs its own phases, review model, or stages, build a purpose-built mode. Run `/swarm:create-workflow` to scaffold one (a skill defining lead identity, facilitator title, mode-specific rules, and a phase arc), then launch it with `/swarm:workflow <name>`. The phase names stay; the semantics are yours.

---

## Watching your team (optional)

Swarm runs fine in plain Claude Code — you see the lead's messages and approvals inline. For more visibility into the team's reasoning, [AgentChat](https://github.com/DheerG/agent-chat) surfaces agent-to-agent conversations in real time. Not required.

---

<details>
<summary><b>Troubleshooting</b> — first push denied in auto mode</summary>

If you ship in **auto mode** to an org that isn't one of this repo's configured remotes (a fork's upstream, a mirror, or a different org), the permission classifier may deny the first push. Press `r` in `/permissions` to approve and ship right then. To stop it recurring, add the destination to `autoMode.environment` in user scope (`~/.claude/settings.json`) or local scope (`.claude/settings.local.json`, gitignored) — Claude Code ignores `autoMode` in shared project scope. Keep `$defaults` and replace the placeholders with your host/org:

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: <your-host>/<your-org>. Pushing branches and opening pull requests is part of the standard development workflow."
    ]
  }
}
```

</details>

<details>
<summary><b>Ubiquitous language</b> — glossary of swarm terms</summary>

| Term | Meaning |
|------|---------|
| **swarm** | The plugin |
| **team** | A group of agents launched for a task |
| **lead** | The main session that coordinates work |
| **member** | A teammate agent (read-only) |
| **facilitator** | The Socratic facilitator role (Principal Engineer / Principal Investigator / Editorial Director / Chief of Staff) |
| **outcome** | What the user wants to achieve, state-based, not implementation steps |
| **mode** | The team's domain configuration (Code, Triage, Writing, General) |
| **tier** | Model allocation tier (Ultra, Balanced) |
| **phase arc** | Research, Converge, Approve, Execute, Review, Refine, Deliver |
| **launch** | Start a team via `/swarm:launch` or a mode shortcut |
| **ship definition** | Per-project rules for branch strategy and delivery, stored in `.claude/swarm-ship.md` |
| **CONFIDENCE REACHED** | Facilitator signal that the team has scored work at 9/10 or above |

</details>

---

## Contributing

All changes go through branches and pull requests; automated version bumps by `github-actions[bot]` are the only exception.

For local development:

```bash
claude --plugin-dir /path/to/swarms
```

## License

MIT
