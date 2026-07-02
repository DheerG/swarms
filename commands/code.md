---
description: Launch a code-mode agent team
argument-hint: <outcomes>
disable-model-invocation: true
---

# /swarm:code

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` and execute it in full — every step, in order — with these overrides:

- **Mode:** Code, fixed. Skip mode inference and mode selection entirely; never ask about mode. If the user asks to change the mode at the Step 7 gate, say the mode is fixed for this command and point them to `/swarm:launch` (or the matching shortcut) — do not switch modes mid-command.
- **Outcomes question (Step 2):** "What outcomes do you want the team to achieve? (Describe what success looks like — what should be working differently or better when the work is done?)"
- **User-Provided Context:** the section below stands in for launch.md's `$ARGUMENTS` — launch.md's own context section is unsubstituted when read from disk.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all research to teammates.

## User-Provided Context

$ARGUMENTS
