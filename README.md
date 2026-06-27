# Swarm

**Get consistent predictable, well tested results from claude code sessions.**

This plugin gives users a few commands that greatly improve results using agent teams/swarms with outcome based directives. It works well with both coding and non-coding tasks.

Unlike out-of-the-box agent teams, swarm gives the team members much needed instruction on being better at communicating with each other, better at following instructions, staying active during long lasting sessions, applying great quality improvement processes, all while requiring fewer course corrections.

Swarm launches a small team of agents for each task: a lead, a Socratic facilitator, and specialists you pick for the work. They research independently and argue through disagreements before the team scores its own output. Work only reaches you after the team agrees it's at 9 out of 10. Most of the quality work happens in the cycles you never see.

```
/swarm:launch
```

**New here?** Start with `/swarm:onboard`, a short walkthrough of the four concepts before your first launch.

---

## Quick start

Install the plugin:

```bash
claude plugin marketplace add DheerG/swarms
claude plugin install swarm@swarms --scope project
```

Agent teams must also be enabled in Claude Code. Add to `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

`/swarm:launch` checks for this and will enable it for you if it's missing. For local development:

```bash
claude --plugin-dir /path/to/swarms
```

Changes take effect in the next session.

If you ship in **auto mode** to an org that isn't one of this repo's configured remotes (a fork's upstream, a mirror, or a different org), the permission classifier may deny the first push. Press `r` in `/permissions` to approve and ship right then; to stop it recurring, add the destination to `autoMode.environment` in user scope (`~/.claude/settings.json`) or local scope (`.claude/settings.local.json`, gitignored) — Claude Code ignores `autoMode` in shared project scope. Keep `$defaults` (it already trusts this repo's own remotes), and replace the placeholders with your host/org:

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

---

## Why I built this

I built this across hundreds of sessions, pruning rules, memories, and skills until the quality stopped varying. When model quality shifted, small targeted changes kept it working, even on smaller models. Once the results were consistent enough to rely on, I started sharing with teammates and friends.

That's when the real problem showed up. I'd send a prompt to someone I work with and watch them get wildly different results. Their Claude had a different `CLAUDE.md`, different memories, different local skills, different settings hooks. All of that ambient context quietly rewrote what they were trying to do, not just their prompts. The prompt alone wasn't the problem. The environment around it was.

Swarm is the fix. It bundles the rules and the phases into one plugin you install and invoke, so what you share is what actually runs, on your machine or anyone else's. Portable quality, not just personal repeatability.

— Dheer

More on how I think about agents: [dheer.co](https://dheer.co)

---

## Who this is for

**Swarm is for you if:**

- You've noticed the same prompt produces a great result on Tuesday and a mediocre one on Thursday, and you want structural pushback instead of hoping for a good day.
- You're sharing prompts with teammates, friends, or family and their results don't match yours because their local context is different.
- You want a second (and third, and fourth) opinion enforced on every piece of work before it reaches you.
- Your task is complex enough that you want a plan approved before anything runs.

**Swarm is not:**

- A task manager. There's no backlog, no tickets, no sprint.
- A workflow framework. There are no DAGs, no YAML, no runtime composition.

---

## How it works

Running `/swarm:launch` is a guided interaction. At every step you either see something or make a choice, with no silent spawns and no mystery setup.

### 1. State what you want

```
/swarm:launch
```

The first question is always about outcomes. An outcome describes what success looks like when the work is done, rather than what to build.

> **Do you have outcomes defined, or would you like help?**
>
> - I'll provide my outcomes (Recommended)
>   *I know what success looks like and will describe it*
> - Help me define outcomes
>   *Use /swarm:refine-outcomes to reframe my ideas into outcome statements*

Say what you want. The system is looking for state-based results ("users can authenticate with a one-time code") rather than implementation steps ("add an email-OTP endpoint"). If you're not sure, pick the second option and a refinement skill will help you reframe.

### 2. Choose a setup path

Once outcomes are captured, swarm asks how configured you want the setup to be:

> **How would you like to set up the team?**
>
> - Defaults — Ultra (Recommended)
>   *Auto-configure mode, team, and research; full team on the stronger model — reliable rule-following*
> - Defaults — Balanced
>   *Same auto-config; cheaper model for members — lower cost, less reliable rule-following*
> - Configure each step
>   *Choose mode, team members, tier, and research individually*

Defaults path: swarm infers the mode (Code / Triage / Writing / General) from your outcomes, suggests a team automatically, asks which cost tier you want (Ultra recommended for reliable rule-following, or Balanced for lower cost), and jumps to the final confirmation. Configure path: four short questions, your call on each.

### 3. See the team

Swarm presents a proposed roster and asks:

> **Does this team look right?**
>
> - Yes, looks good — *Proceed with this team composition*
> - I want to adjust — *Let me add, remove, or change members*

The team always includes a lead (you, via the main Claude session) and a facilitator (Principal Engineer in Code mode, Principal Investigator in Triage mode, Editorial Director in Writing mode, Chief of Staff in General mode). Everyone else is chosen for the domain expertise your outcomes suggest.

### 4. Approve before anything runs

You see the complete plan before a single agent is spawned:

> **Team Plan**
>
> **Mode:** Code
> **Outcomes:** (your words, verbatim)
> **Team:**
> 1. Team lead — (main session)
> 2. Principal Engineer — Socratic facilitator, read-only
> 3–N. Additional members — personality and behavioral identity
>
> **Cost tier:** Ultra
> **Ship definition:** Create a feature branch from main, commit, push, open PR
> **Rules:** Active
>
> ---
> **Is this plan final, or do you have remaining inputs?**
>
> - Launch the team — *Plan is final — start creating the team now*
> - I have changes — *Let me adjust outcomes, members, or settings first*

Nothing runs until you pick "Launch the team." There's a second approval coming: after the team researches and converges on an approach, you'll approve that approach before Execute begins.

> **Everything the team follows is inline in the commands**, not in your local settings, your CLAUDE.md, or your memory. That's what makes this plan reproducible on anyone else's machine. See [Portable quality across environments](#portable-quality-across-environments) for why.

### 5. Watch the team work (or don't)

Once launched, the lead sends a single plain-text sentence setting expectations:

> Team is launched — I'll check in at Approve and before delivery. You can watch the team's discussion live in AgentChat if you have it.

Then execution goes quiet. Members research independently, the facilitator runs a roundtable, and the team converges on an approach. You don't drive; that's the point.

### 6. Approve the approach

When the facilitator sends `CONVERGED`, the lead presents the facilitator's synthesis for your approval, verbatim and unparaphrased:

> The team converged on [approach]. Key trade-offs: [summary]. Known risks: [summary].
>
> **Does this approach look right?**
>
> - Yes, proceed — *Greenlight Execute*
> - I have changes — *Adjust before execution*

This is the last approval before autonomous execution begins. After this, the lead works the plan through Execute, Review, and Refine without interruption.

### 7. Recursive review until 9/10

The lead implements. The team reviews. If the facilitator judges the work below 9/10, the lead processes feedback, fixes, and the team re-reviews. This loop is autonomous, with no user confirmation between rounds. Eventually:

> **CONFIDENCE REACHED — 9/10. All reviewers confirm the work is ready to present.**

Then you get a choice:

> **9/10+ confidence reached. Run recursive refinement?**
>
> - Deliver now — *Ship the work as-is*
> - Run recursive refinement — *Iterate through 9.25 → 9.5 → 9.75 → 10*

The refinement ladder is optional. Each rung is autonomous once you opt in. Each rung is also a floor: if a fix drops any reviewer's score below the current rung, the ladder holds at that rung and iterates — it does not advance on a score that a post-fix regression has broken. If a rung fails to hold after two fix cycles, the facilitator invokes `swarm:resolve-dispute` to break the loop.

### 8. Deliver

In Code work, once the team reaches 9/10 you choose how to finish at a single gate:

> **9/10+ confidence reached. How should the team finish?**
>
> - Recursive refinement + independent review — *Run the refinement ladder (9.25→10), then an independent review loop*
> - Independent review loop only — *Skip the ladder; just the independent review loop*
> - Ship as is — *No further review*

**Recursive refinement** drives the work to the full scope of your outcome (completeness). The **independent review loop** is the bug-surface counterpart: after the PR is created, a different reviewer reads the whole PR against your outcome, the lead fixes only what's in scope, and the loop repeats — pushing each round's fixes to the PR — until no in-scope functional issues remain. If you pick a review option, you then choose the reviewer engine: **Codex** (an independent model that fails differently from the author; preferred when its CLI is present) or a **swarm-native fallback** (a fresh Codex-style Claude reviewer; always available). The loop keeps findings on-scope by anchoring on your stated outcome and surfaces anything out-of-scope to you rather than silently applying it. The lead ships according to `.claude/swarm-ship.md` (usually a PR against main) and waits for your sign-off. You get the completed work with the team's confidence score attached.

---

## A real Converge, in excerpt

Descriptions of "the facilitator runs a roundtable" don't land until you've seen what one actually sounds like. Here's a representative excerpt from a caching-strategy Converge:

> **Principal Engineer:** Two approaches on the table — cache-aside with a TTL, or read-through with invalidation on write. Security Reviewer, you flagged the TTL approach earlier. What's the actual risk you see?
>
> **Security Reviewer:** TTL means stale data can persist for up to N minutes after a permission change. If this endpoint returns authorization state, that's a window.
>
> **Principal Engineer:** Lead, does this endpoint return authorization state, or pure profile data?
>
> **Lead:** Profile data only — no permissions in the response.
>
> **Principal Engineer:** Then TTL risk is acceptable here. Team, any other concerns before I call CONVERGED?

Three patterns worth noticing:

- **The facilitator doesn't decide.** They surface the blocker, direct it at the right person, and wait for evidence.
- **The lead is a participant, not the center.** They answer a concrete question like anyone else on the team.
- **Synthesis only comes after the concern is resolved.** No `DECIDED:` without evidence.

This is what "the team reaches 9/10" is doing underneath. You don't need to mediate. You see the synthesis; the debate stays in the team.

---

## Why it works

### Outcomes over implementations

Work is described as what the world looks like when it's done, not what to build.

- **Implementation framing:** "Add a Redis cache in front of the user service."
- **Outcome framing:** "User profile reads return in under 50ms and don't hit the DB when cached."

The distinction changes what the team debates. Implementation framing has them comparing Redis and Memcached. Outcome framing has them comparing caching against query optimization, which is the wider and more useful argument.

### Prompts, not frameworks

The consumer of every command is a language model, not a compiler. A self-contained prompt read in one pass outperforms a framework that assembles itself from parts. Swarm commits to this literally.

```markdown
---
description: Interactively launch an agent team with guided setup
disable-model-invocation: true
---

# /swarm:launch

You are launching an agent team using the Swarm plugin. Follow every step below in exact order...
```

That's the top of `commands/launch.md`. The entire coordination system, from pre-flight through delivery, lives in one self-contained markdown file. **No imports.** You can read the whole thing: [commands/launch.md](commands/launch.md).

There's no DSL to learn and no runtime composition. When you extend swarm, you write another markdown file.

### Recursive review to 9/10

The review gate is explicit and structural:

> 9/10+ means: logic is correct, tests pass where applicable, no regressions introduced, no known defects left unaddressed, reviewers would ship this.
>
> — `skills/code-mode/SKILL.md:78`

Below 9/10, the team cycles: lead fixes, team re-reviews. Above 9/10, you get an optional refinement ladder:

> Run recursive refinement (9.25 → 9.5 → 9.75 → 10)
>
> — `skills/code-mode/SKILL.md:82`

The critical mechanic: **the facilitator, not the lead, controls the gate.** The person who did the work cannot declare their own work done. That structural separation is what prevents performative review. A model reviewing its own output tends to produce the cheapest approving token it can find; a different agent with a different role pushes back with something actually worth reading.

### Portable quality across environments

Every rule that governs a team is inline in the command file. When `CLAUDE.md` instructions, memories, local skills, or settings hooks conflict with swarm governance, swarm wins:

> Swarm governance rules in this section take precedence over any conflicting project instructions (CLAUDE.md) or memory-system preferences during a team run.
>
> — `commands/launch.md:58`

That's why `/swarm:audit-context` exists. Its job is exactly this:

> Evaluates ambient context artifacts (CLAUDE.md, memory, local skills, settings hooks) for compatibility with swarm governance. Returns a classified report so users can address interference before launching a team.
>
> — `skills/audit-context/SKILL.md`

Run it before a launch if you're in a project with heavy local configuration, or before sharing a swarm workflow with a teammate. If you share a workflow and they get a different result, the cause is almost always in their environment rather than in the prompt. Audit-context finds it. You fix once, share again.

The plugin is the contract that travels with the work.

---

## Modes and tiers

### Modes

| Mode | Lead | Facilitator | Review model |
|------|------|-------------|--------------|
| **Code** | Writes code | Principal Engineer | Technical — logic correctness, no regressions, reviewers would ship |
| **Triage** | Diagnoses (no changes) | Principal Investigator | Diagnosis honesty — cause traced to the breaking point, evidence for/against, blast radius, honestly declared confidence; no Refine ladder |
| **Writing** | Coordinates (can write) | Editorial Director | Editor-sandwich — writer isolation, structural + line pass |
| **General** | Produces deliverable | Chief of Staff | Facilitator-driven — tailored to the deliverable type |

Mode shortcuts bypass the mode question: `/swarm:code`, `/swarm:triage`, `/swarm:write`, `/swarm:general`.

### Cost tiers

| Tier | Members | Facilitator | When to use |
|------|---------|-------------|-------------|
| **Ultra** (recommended) | Opus | Opus | Reliable rule-following across the whole team — the recommended pick |
| **Balanced** | Sonnet | Opus | Lower cost; well-scoped, lower-stakes work where occasional rule-slips are acceptable |

The tier is an explicit pick at setup (Ultra is pre-selected as Recommended) rather than a silent default, so no one lands on a tier they didn't choose. The tier applies to the spawn-time model assignment. The facilitator always uses the `opus` alias (resolved via `ANTHROPIC_DEFAULT_OPUS_MODEL`) regardless of tier; they own judgment review. See [Preferring the 1M context variant for the facilitator](#preferring-the-1m-context-variant-for-the-facilitator-anthropic-api) if you want to pin the 1M context variant for the facilitator.

> Model names are resolved through `ANTHROPIC_DEFAULT_OPUS_MODEL` and `ANTHROPIC_DEFAULT_SONNET_MODEL`. Sonnet and Opus are the defaults on Anthropic direct — not requirements. See [Custom model providers](#custom-model-providers) for how this works on Fireworks, OpenRouter, Bedrock, and others.

**Per-member reasoning effort is not a tier.** Swarm can only set *which model* each teammate runs, not its reasoning effort — the agent-teams spawn path honors `model` but ignores per-member `effort`. Lowering your session's reasoning effort (`/effort medium` before launch) is a separate cost lever, and it stacks with the tier rather than replacing it — Balanced members at medium effort is the weakest configuration we'd still recommend, and only for low-stakes work; below medium, the review phase (gap analysis, independent scoring) starts going through the motions, and the gap grows across the refine rungs (9.25→10), so the last checks before ship are where it bites most. Effort is session-wide, so it also lowers the facilitator (always Opus, the judgment-review seat).

> Two harness settings sit above the tier picker and can override it silently. `CLAUDE_CODE_SUBAGENT_MODEL`, if set, forces one model for every teammate — collapsing all tiers to that model; unset it (or set `inherit`) for the picker to take effect. And session effort (`/effort`) is global, lowering the facilitator along with the members.

### Custom model providers

Swarm works with any Anthropic-compatible provider (Fireworks AI, OpenRouter, Bedrock, Vertex, Foundry). If you installed swarm before this section existed and are hitting a model-not-found error, run `/swarm:update` to pick up the fix. The lead session inherits whatever model your Claude Code session is running. Spawned teammates use the `opus` and `sonnet` aliases, which the harness resolves through `ANTHROPIC_DEFAULT_OPUS_MODEL` and `ANTHROPIC_DEFAULT_SONNET_MODEL`. Point both at a capable model from your provider in `.claude/settings.json` and Balanced and Ultra both work. Swarm only relies on these two aliases; other `ANTHROPIC_*` env vars are for Claude Code's internal tooling and don't need to be set for swarm.

Example for Fireworks AI:

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

The top-level `model` sets the lead session's model; the `ANTHROPIC_DEFAULT_*` vars resolve the `opus` and `sonnet` aliases used by spawned teammates. Third-party providers typically wire credentials through `apiKeyHelper` rather than `ANTHROPIC_API_KEY`.

If your provider's best available model is meaningfully weaker than Opus, expect the 9/10 review gate to take more iterations.

### Preferring the 1M context variant for the facilitator (Anthropic API)

Opus 4.8 has a native 1M context window. On Max, Team, and Enterprise plans, the `opus` alias is automatically upgraded to 1M — no action needed. On Pro, 1M requires extra usage; on API pay-as-you-go, it's included. On either, pin the variant explicitly by setting `ANTHROPIC_DEFAULT_OPUS_MODEL` in your `.claude/settings.json`:

```json
{
  "env": {
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-8[1m]"
  }
}
```

On Opus 4.8, swarm runs at your session's default reasoning effort — no additional config needed.

Why 1M: not to chase the token limit. Team runs rarely fill the context window, because the team lead doesn't research directly and only makes targeted edits, and the facilitator usually does the same. The 1M variant prevents quality degradation from compaction on the rare larger run where context does grow.

This setting is Anthropic-API-specific. If you already configured `ANTHROPIC_DEFAULT_OPUS_MODEL` for a custom provider (per the section above), do **not** replace it with the Anthropic ID — `claude-opus-4-8[1m]` is Anthropic-direct only and will error on Bedrock, Vertex, Foundry, or other providers. See the [model configuration docs](https://code.claude.com/docs/en/model-config) for provider-specific guidance on aliases, the `[1m]` suffix, and effort levels.

The team lead is your own Claude Code session, so swarm can't set its model or effort. To strengthen the lead, configure your session directly: `/model opus[1m]`, or set `"model": "claude-opus-4-8[1m]"` in your settings.

---

## Commands

### Launch a team

```
/swarm:launch            # Interactive setup (any mode)
/swarm:code              # Code team
/swarm:triage            # Triage team — diagnose an issue without changing it
/swarm:write             # Writing team
/swarm:general           # General team
/swarm:onboard           # Walkthrough for new users
```

Pass outcomes inline to skip the opening question:

```
/swarm:write Help me write a blog article on healing trauma
```

### Refine an existing branch and PR

```
/swarm:refine            # Review and recursively refine the current branch/PR against stated outcomes
```

`/swarm:refine` runs against work already on a branch — it reads the current branch, the open PR (if any), and the diff against the PR's base branch, then enters at Review → Refine → Deliver. Pass the outcomes the branch was supposed to achieve, and a fixed roster of correctness, outcomes, and regression reviewers iterates the recursive refinement ladder to 10. Use it when a PR is "almost done" and you want the team to push it the rest of the way.

### Other commands

```
/swarm:audit-context     # Detect ambient context that may interfere with swarm
/swarm:refine-outcomes   # Reframe ideas into outcome statements
/swarm:suggest-members   # Recommend team composition
/swarm:create-workflow   # Scaffold a custom mode for your project
/swarm:workflow <name>   # Launch against an existing custom mode
/swarm:update            # Check for and install the latest version
```

Swarm checks for updates on session start. When an update is available, the assistant is notified and mentions it in its first reply — run `/swarm:update` to upgrade. On the Claude Code CLI the notice may also appear directly as a startup line; in the VS Code, JetBrains, and web clients, Claude Code does not render startup hook messages ([claude-code#15344](https://github.com/anthropics/claude-code/issues/15344)), so the assistant's reply is the only place it appears there. Set `SWARM_SKIP_UPDATE_CHECK=1` to silence the check.

---

## Custom workflows

When a workflow needs its own phases, review model, or production stages, build a purpose-built mode for it. Run `/swarm:create-workflow` to scaffold a custom mode: a skill that defines lead identity, facilitator title, mode-specific rules, and a phase arc. Once created, launch against it with `/swarm:workflow <name>`.

A mode skill's Phase Arc section is what's actually substituted into a team run. Example from Code mode:

> ### Converge
>
> The facilitator runs a roundtable: questions each proposal, surfaces trade-offs. If an expert raises a concern, investigate it before moving on. Drive toward consensus on an approach.
>
> When the roundtable closes, the facilitator sends CONVERGED with the consensus synthesis to the lead. The lead does not advance past Converge without it.
>
> — `skills/code-mode/SKILL.md:54-58`

Writing mode and General mode define their Converge differently. Custom modes can do the same: the phase names stay, the semantics are yours.

---

## Watching your team (optional)

Swarm runs fine in plain Claude Code; you see the lead's messages and approvals inline. If you want more visibility into the team's reasoning, [AgentChat](https://github.com/DheerG/agent-chat) is an optional companion tool that surfaces agent-to-agent conversations in real time. Not required.

---

## Ubiquitous Language

<details>
<summary>Glossary of terms used throughout swarm</summary>

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

All changes go through branches and pull requests. Automated version bumps by `github-actions[bot]` are the only exception.

## License

MIT
