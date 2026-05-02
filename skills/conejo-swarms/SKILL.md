---
name: conejo-swarms
description: Install the swarm plugin (multi-agent team launcher with /swarm:launch, /swarm:code, /swarm:write, /swarm:general, /swarm:refine, /swarm:workflow) into a Claude Code project, after honestly enumerating the costs (hooks installed globally, token spend on recursive review loops, governance overrides). Use when the user asks to install swarm, set up agent teams in this project, or wants /swarm:* commands available locally — including reinstalling into a second project after the first one. Triggers on "install swarm", "set up swarm here", "add swarm to this project", "give me /swarm:launch", or explicit `/conejo-swarms` invocation. Do NOT use for explaining what swarm is, debugging an existing swarm install, or running a launch.
---

# conejo-swarms

Install the [swarm](https://github.com/arthrod/swarms) Claude Code plugin into the current project. Conejo-flavored: name the costs before running the install, don't oversell the upside.

## What swarm is, in one paragraph

A plugin that adds `/swarm:launch`, `/swarm:code`, `/swarm:write`, `/swarm:general`, `/swarm:refine`, `/swarm:workflow`, and `/swarm:create-workflow` to Claude Code. Each launches a small team of agents (lead + Socratic facilitator + specialists) that research, converge on an approach, get user approval, execute, and recursively self-review until the team scores ≥9/10. Optional refinement ladder to 10/10 after that. Phase arc is fixed (Research → Converge → Approve → Execute → Review → Refine → Deliver); modes (Code / Writing / General) define what each phase means.

## When to use this skill

- User says "install swarm", "set up swarm here", "add swarm to this project", "I want /swarm:launch in this repo", or invokes `/conejo-swarms` directly.
- User pastes a `/swarm:*` command in a fresh project and gets "command not found" — offer this skill.
- User has swarm in one project and wants it in another.
- User is bootstrapping a new repo and wants the agent-team workflow available before doing anything else.

## When NOT to use

- Swarm is already installed in the target project. Check first (see Step 0). If installed, route to `/swarm:update` for upgrades.
- User is asking how swarm works, what it does, or whether to use it — that's a discussion, not an install. Answer the question; don't trigger the skill.
- User is debugging a broken swarm install (commands missing, hooks erroring) — that's a repair, not a fresh install. Investigate before reinstalling.
- The `claude` CLI is not on PATH — flag it and stop. Don't try alternate install paths.
- User explicitly asked to evaluate the cons before installing — give them the costs section below as text and let them decide; don't auto-run the install.

## Costs to name before installing

Read these to the user in one short message before running the install. They are real, they are not in the README's marketing voice, and the user deserves to hear them once:

1. **Two global Claude Code hooks** get registered:
   - `SessionStart` runs `check-update.sh` on every Claude Code session, not just swarm sessions. It phones home to GitHub once per 24h.
   - `PreToolUse` on `SendMessage` runs `confirm-shutdown.sh` and can block tool calls. Adds latency to every agent message in any session.
2. **Token spend.** A swarm launch spawns N agents (Sonnet members + Opus facilitator on Balanced; all Opus on Ultra) and runs a recursive review loop until ≥9/10. Optional refinement ladder (9.25 → 9.5 → 9.75 → 10) on top. Simple tasks become expensive.
3. **Governance overrides project CLAUDE.md and memory** during a team run. The user's local rules get suppressed.
4. **Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`** in user settings — an experimental flag that may change behavior across Claude Code releases.
5. **Wall-clock latency.** Multi-phase arc + two human approval gates (plan, approach) means simple work takes longer than direct.

If the user has already heard these (e.g., they just read the README or asked you to install after seeing them), skip restating; one line ("installing — costs noted earlier") is fine.

## Install procedure

### Step 0 — Pre-flight

Run these in parallel:

```bash
command -v claude
pwd
git rev-parse --is-inside-work-tree 2>/dev/null
claude plugin list 2>/dev/null | grep -i swarm
```

Decide:
- If `claude` is missing: stop. Tell the user to install Claude Code first (https://docs.claude.com/en/docs/claude-code) and rerun.
- If swarm is already in `claude plugin list`: stop. Tell the user it's installed and recommend `/swarm:update` if they want a newer version.
- If `pwd` is not a git repository: warn the user that project-scope install will create `.claude/` here anyway, and confirm they want this directory before proceeding.

### Step 1 — Confirm install target with the user

Show the resolved path and ask: "Install swarm into `<pwd>` at project scope? (project / user / cancel)". Wait for an answer. Project scope is the default — `.claude/` lives in the repo and travels with it. User scope (`~/.claude/`) makes swarm available everywhere but doesn't pin it to a repo.

### Step 2 — Add the marketplace and install the plugin

```bash
claude plugin marketplace add arthrod/swarms
claude plugin install swarm@swarms --scope project   # or --scope user, per Step 1
```

Both commands must succeed. If either fails, surface the error verbatim — don't paper over it.

### Step 3 — Enable the experimental agent-teams flag

Required for `/swarm:launch` to work. Check `~/.claude/settings.json`:

- File doesn't exist: create it with `{"env": {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"}}`.
- File exists and `jq` is available: merge in the env key without clobbering anything else:
  ```bash
  jq '.env = (.env // {}) | .env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"' \
    ~/.claude/settings.json > ~/.claude/settings.json.tmp \
    && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
  ```
- File exists, `jq` missing: read the file, show the user the exact JSON they need to add, and let them edit it themselves. Do not attempt a regex merge — too easy to corrupt the file.

If the flag was already set, say so and skip.

### Step 4 — Confirm and hand off

Tell the user:
- The install is done.
- Changes take effect in the **next** Claude Code session — they need to restart.
- For a guided first run, type `/swarm:onboard`. Otherwise jump to `/swarm:launch`.
- If they're on auto mode (Max / Team / Enterprise / API), `/swarm:launch` will offer to add a source-control trust string to user settings on first run; no action needed now.

## What this skill does NOT do

- Does not run `/swarm:launch` or any `/swarm:*` command on the user's behalf. Hand off cleanly.
- Does not modify the project's `CLAUDE.md`.
- Does not write to `.claude/settings.json` (project-shared scope) — the experimental flag goes to user scope only.
- Does not enable auto-mode trust strings — that's `/swarm:launch`'s job on first run.
- Does not uninstall a prior swarm install. If the user wants to reinstall, ask them to run `claude plugin uninstall swarm` first.

## Repair / re-run

If the user invokes this skill and swarm is partially installed (some files present, plugin not in `claude plugin list`), treat it as broken state: show what was found, ask whether to clean up first, and only then re-run the procedure.

## Source of truth

- Repo: https://github.com/arthrod/swarms
- Plugin manifest: `.claude-plugin/plugin.json` (current version: `0.4.0` at time of writing — verify with `claude plugin list` after install).
- Marketplace alias: `swarms` — plugin name: `swarm`.
- Bootstrap (for users who don't have swarm yet and want this skill globally before installing the rest): copy this `SKILL.md` to `~/.claude/skills/conejo-swarms/SKILL.md`. After that, `/conejo-swarms` is invokable in any project and will perform the install.
