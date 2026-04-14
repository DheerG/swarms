---
description: Launch a general-mode agent team
argument-hint: <outcomes>
disable-model-invocation: true
model: claude-opus-4-6
---

# /swarm:general

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` for Step 0 (pre-flight), Step 1 (hard rules), and Step 8 (launch). This command replaces Steps 2–7.

## Settings

- **Mode:** General
- **Outcomes question:** "What are you trying to achieve?"
- **Defaults:** suggest-members (General mode), Balanced shape, no lead research

## User-Provided Context

$ARGUMENTS

## Workflow

1. **Setup.** AskUserQuestion — "How would you like to set up the team?" Options: "Use defaults (Recommended)" / "Configure each step."
2. **Outcomes.** If User-Provided Context is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Accept without confirmation.
3. **Team configuration.** Defaults path: apply the defaults above, go to step 4. Configure path: follow launch.md Steps 4–6, then step 4.
4. **Confirmation.** Follow launch.md Step 7. Mode is General.
5. **Launch.** Follow launch.md Step 8.
