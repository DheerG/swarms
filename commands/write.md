---
description: Launch a writing-mode agent team
argument-hint: <outcomes>
disable-model-invocation: true
---

# /swarm:write

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` and execute it in full — every step, in order — with these overrides:

- **Mode:** Writing, fixed. Skip mode inference and mode selection entirely; never ask about mode.
- **Outcomes question (Step 2):** "What are you writing?"
- **User-Provided Context:** the section below stands in for launch.md's `$ARGUMENTS` — launch.md's own context section is unsubstituted when read from disk.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all research to teammates.

## User-Provided Context

$ARGUMENTS
