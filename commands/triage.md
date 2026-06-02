---
description: Launch a triage-mode agent team — diagnose an issue without changing it
argument-hint: <issue to diagnose>
disable-model-invocation: true
---

# /swarm:triage

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` for Step 0 (pre-flight), Step 1 (hard rules), and Step 8 (launch). This command replaces Steps 2–7.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all evidence-gathering to teammates.

**Triage changes nothing.** This mode diagnoses — it does not branch, commit, edit, or open a PR. The deliverable is a confidence-rated diagnosis presented in-session.

## Settings

- **Mode:** Triage
- **Outcomes question:** "What do you want the team to diagnose? (Describe what you're seeing — the symptom, where it shows up, and any context. The team will identify the likely cause and the blast radius of fixing it, without making any change.)"
- **Defaults:** suggest-members (Triage mode), tier picked at setup (Ultra recommended), no lead research

## User-Provided Context

$ARGUMENTS

## Workflow

1. **Setup.** AskUserQuestion — "How would you like to set up the team?" Options: "Defaults — Ultra (Recommended)" (auto-configure mode/team/research; full team on the stronger model — reliable rule-following) / "Defaults — Balanced" (same auto-config; cheaper model for members — lower cost, less reliable rule-following) / "Configure each step" (choose mode, team, tier, research individually).
2. **Outcomes.** If User-Provided Context is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Then echo the outcomes back verbatim — copy-paste, no condensation, no paraphrase — and use AskUserQuestion with options "Yes, that's what I meant" / "Let me add to this". If "Let me add to this", ask what they'd like to add (plain text), append it, and re-echo with AskUserQuestion until confirmed.
3. **Team configuration.** Defaults path (either Defaults option): apply the defaults above with the tier set to the option picked (Ultra or Balanced), and immediately proceed to step 4 in the same response — do not pause for user input. Configure path: follow launch.md Steps 4–6, then step 4.
4. **Confirmation.** Follow launch.md Step 7. Mode is Triage.
5. **Launch.** Follow launch.md Step 8.
