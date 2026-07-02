---
description: Launch a custom workflow using a user-defined mode skill
argument-hint: <mode-skill-name> [context]
disable-model-invocation: true
---

# /swarm:workflow

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` and execute it in full — every step, in order — with these overrides:

- **Mode:** the custom mode skill parsed below, fixed. Skip mode inference and mode selection entirely; never ask about mode. If the user asks to change the mode at the Step 7 gate, say the mode is fixed for this run and point them to `/swarm:workflow <other-mode>` (or a built-in shortcut / `/swarm:launch` for built-in modes) — do not switch modes mid-command.
- **Mode skill invocation:** invoke the mode skill here, before the outcomes flow (see "Mode Skill Invocation" below). At launch.md Step 8b it is already invoked — apply its spec directly, do not re-invoke.
- **Outcomes question (Step 2):** the mode skill's Outcomes Question (or its base's, for extensions) if it defines one; otherwise "What outcomes do you want the team to achieve? (Describe what should be different or better when the work is done.)"
- **Suggest-members:** when invoking `swarm:suggest-members`, pass the mode skill's Suggest-Members Guidance (for extensions: the base's guidance plus the supplement) along with the confirmed outcomes.
- **User-Provided Context:** everything after the mode-skill name in the arguments below stands in for launch.md's `$ARGUMENTS` — launch.md's own context section is unsubstituted when read from disk.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all research to teammates.

## Parsing $ARGUMENTS

$ARGUMENTS

The first word of $ARGUMENTS is the **mode skill name** (e.g., `blog-mode`). Everything after it is the **user-provided context**. If $ARGUMENTS is empty, ask the user: "Which custom mode skill should I use?" (plain text, not AskUserQuestion). Wait for their response.

## Mode Skill Invocation

Invoke the mode skill by its **unqualified name** via the Skill tool (e.g., `blog-mode`, not `swarm:blog-mode`) **before the outcomes flow**. User-defined mode skills live in the project's `.claude/skills/` directory and are resolved without namespace prefix.

If the Skill tool cannot find the mode skill, tell the user: "Mode skill '[name]' not found. Verify that `.claude/skills/[name]/SKILL.md` exists in your project." Stop and wait.

**Extension modes.** If the invoked mode skill's frontmatter declares `extends:` naming a base (e.g., `extends: swarm:code-mode`), it is an extension mode. Read the frontmatter directly from the file at `.claude/skills/<name>/SKILL.md` to detect this — do not infer from body prose. Invoke the named base mode skill via the Skill tool **immediately after** the extension, then combine the two per the **Invoke your mode skill** section and **Extension hard contract** in the governance spec (`swarm:workflow-rules`, invoked at launch.md Step 1): the base provides lead identity, facilitator, phase arc, and base rules; the extension's contributions are additive-only; a violating extension is malformed — surface it to the user before proceeding.

If the mode skill (or its base) includes Pre-flight Reads, read those files before spawning.
