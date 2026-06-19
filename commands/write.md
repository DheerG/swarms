---
description: Launch a writing-mode agent team
argument-hint: <outcomes>
disable-model-invocation: true
---

# /swarm:write

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` for Step 0 (pre-flight), Step 1 (hard rules), and Step 8 (launch). This command replaces Steps 2–7.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all research to teammates.

## Settings

- **Mode:** Writing
- **Outcomes question:** "What are you writing?"
- **Defaults:** suggest-members (Writing mode), tier picked at setup (Ultra recommended), no lead research

## User-Provided Context

$ARGUMENTS

## Workflow

1. **Setup.** AskUserQuestion — "How would you like to set up the team?" Options: "Defaults — Ultra (Recommended)" (auto-configure mode/team/research; full team on the stronger model — reliable rule-following) / "Defaults — Balanced" (same auto-config; cheaper model for members — lower cost, less reliable rule-following) / "Configure each step" (choose mode, team, tier, research individually).
2. **Outcomes.** If User-Provided Context is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Do NOT echo the outcomes back verbatim — run the outcome reflection instead: You MUST use the **Skill** tool to invoke `swarm:reflect-outcome` with the user's exact words as `args`, and do not author its wording yourself. If it returns `NO FORK` (the common case), show nothing — no echo, no confirmation beat — and carry the outcome forward as the premise of the next step. If it returns a ready-to-render fork, present it with AskUserQuestion exactly as returned (do not reword the question or labels) and record the user's choice as a one-line supplement. The user's verbatim words are still captured for the Step 8 briefs (launch.md verbatim-capture rule); the user can still adjust at Step 7.
3. **Team configuration.** Defaults path (either Defaults option): apply the defaults above with the tier set to the option picked (Ultra or Balanced), and immediately proceed to step 4 in the same response — do not pause for user input. Configure path: follow launch.md Steps 4–6, then step 4.
4. **Confirmation.** Follow launch.md Step 7. Mode is Writing.
5. **Launch.** Follow launch.md Step 8.
