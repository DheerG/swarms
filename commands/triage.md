---
description: Launch a triage-mode agent team — diagnose an issue without changing it
argument-hint: <issue to diagnose>
disable-model-invocation: true
---

# /swarm:triage

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` and execute it in full — every step, in order — with these overrides:

- **Mode:** Triage, fixed. Skip mode inference and mode selection entirely; never ask about mode.
- **Outcomes question (Step 2):** "What do you want the team to diagnose? (Describe what you're seeing — the symptom, where it shows up, and any context. The team will identify the likely cause and the blast radius of fixing it, without making any change.)"
- **User-Provided Context:** the section below stands in for launch.md's `$ARGUMENTS` — launch.md's own context section is unsubstituted when read from disk.

**Triage changes nothing.** This mode diagnoses — it does not branch, commit, edit, or open a PR. The deliverable is a confidence-rated diagnosis presented in-session.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all evidence-gathering to teammates.

## User-Provided Context

$ARGUMENTS
