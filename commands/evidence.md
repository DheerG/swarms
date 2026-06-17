---
description: Launch an evidence-mode agent team (code mode + a durable evidence record)
argument-hint: <outcomes>
disable-model-invocation: true
---

# /swarm:evidence

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` for Step 0 (pre-flight), Step 1 (hard rules), and Step 8 (launch). This command replaces Steps 2–7.

**Evidence mode is an extension of Code mode (beta).** It behaves exactly like Code mode, and additionally: the lead maintains a durable, human-readable evidence record at `~/.claude/teams/<team-name>/evidence.md` (in the Claude team directory, outside the user's repo), and members are spawned as the read-only `evidence-member` agent so the team references settled findings in the record instead of re-stating them. It changes none of swarm's default artifacts: `launch.md`, the `swarm-member` agent, and the briefing templates are untouched. Members remain read-only and are briefed with the standard fixed templates; their only behavioral difference is the light evidence convention carried by the `evidence-member` agent. Only the lead writes the record.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all research to teammates.

## Settings

- **Mode:** Evidence (extends Code)
- **Mode skill:** At Step 8b, invoke `swarm:evidence-mode`. Per its `extends:` frontmatter, also invoke the base `swarm:code-mode` and apply the evidence-mode overlays additively — see the extension contract in `swarm:workflow-rules`.
- **Member agent:** At Step 8c and 8d, override the spawn `subagent_type` — spawn the facilitator and all non-lead members with `subagent_type: evidence-member` (not `swarm-member`). evidence-member is read-only (identical tool kit to swarm-member) plus a light evidence-citation / reference-the-record convention. `launch.md` and the `swarm-member` agent are not edited; this command supplies the override.
- **Outcomes question:** "What outcomes do you want the team to achieve? (Describe what success looks like — what should be working differently or better when the work is done?)"
- **Defaults:** suggest-members (Code mode guidance), tier picked at setup (Ultra recommended), no lead research

## User-Provided Context

$ARGUMENTS

## Workflow

1. **Setup.** AskUserQuestion — "How would you like to set up the team?" Options: "Defaults — Ultra (Recommended)" (auto-configure mode/team/research; full team on the stronger model — reliable rule-following) / "Defaults — Balanced" (same auto-config; cheaper model for members — lower cost, less reliable rule-following) / "Configure each step" (choose mode, team, tier, research individually).
2. **Outcomes.** If User-Provided Context is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Then echo the outcomes back verbatim — copy-paste, no condensation, no paraphrase — and use AskUserQuestion with options "Yes, that's what I meant" / "Let me add to this". If "Let me add to this", ask what they'd like to add (plain text), append it, and re-echo with AskUserQuestion until confirmed.
3. **Team configuration.** Defaults path (either Defaults option): apply the defaults above with the tier set to the option picked (Ultra or Balanced), and immediately proceed to step 4 in the same response — do not pause for user input. Configure path: follow launch.md Steps 4–6, then step 4.
4. **Confirmation.** Follow launch.md Step 7. Mode is Evidence (extends Code).
5. **Launch.** Follow launch.md Step 8, with one override: at Step 8c and 8d spawn members with `subagent_type: evidence-member` instead of `swarm-member` (see Settings → Member agent). At Step 8b, invoke `swarm:evidence-mode` (which extends `swarm:code-mode`); the lead seeds the evidence record before Research begins, shares its path in the Research kickoff message, and maintains it through the run per the mode skill.
