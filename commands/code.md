---
description: Launch a code-mode agent team
argument-hint: <outcomes>
disable-model-invocation: true
---

# /swarm:code

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` for Step 0 (pre-flight), Step 1 (hard rules), and Step 8 (launch). This command replaces Steps 2–7.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all research to teammates.

## Settings

- **Mode:** Code
- **Outcomes question:** "What outcomes do you want the team to achieve? (Describe what success looks like — what should be working differently or better when the work is done?)"
- **Defaults:** suggest-members (Code mode), tier picked at setup (Ultra recommended), no lead research

## User-Provided Context

$ARGUMENTS

## Workflow

1. **Setup.** AskUserQuestion — "How would you like to set up the team?" Options: "Defaults — Ultra (Recommended)" (auto-configure mode/team/research; full team on the stronger model — reliable rule-following) / "Defaults — Balanced" (same auto-config; cheaper model for members — less reliable rule-following) / "Configure each step" (choose mode, team, tier, research individually).
2. **Outcomes.** If User-Provided Context is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Then echo the outcomes back verbatim — copy-paste, no condensation, no paraphrase — and use AskUserQuestion with options "Yes, that's what I meant" / "Let me add to this". If "Let me add to this", ask what they'd like to add (plain text), append it, and re-echo with AskUserQuestion until confirmed.
3. **Team configuration.** Defaults path (either Defaults option): apply the defaults above with the tier set to the option picked (Ultra or Balanced), and immediately proceed to step 4 in the same response — do not pause for user input. Configure path: follow launch.md Steps 4–6, then step 4.
4. **Confirmation.** Follow launch.md Step 7. Mode is Code.
5. **Launch.** Follow launch.md Step 8.
