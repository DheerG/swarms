---
description: Launch a custom workflow using a user-defined mode skill
argument-hint: <mode-skill-name> [context]
disable-model-invocation: true
---

# /swarm:workflow

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` and execute it in full — every step, in order — with these overrides:

- **Mode:** the custom mode skill parsed below, fixed. Skip mode inference and mode selection entirely; never ask about mode.
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

**Extension modes.** If the invoked mode skill's frontmatter declares `extends:` naming a base (e.g., `extends: swarm:code-mode`, `extends: swarm:writing-mode`, or `extends: swarm:general-mode`), it is an extension mode. Read the frontmatter directly from the file at `.claude/skills/<name>/SKILL.md` to detect this — do not infer from body prose. Invoke the named base mode skill via the Skill tool **immediately after** the extension. The base provides Lead Identity, Facilitator Title, Facilitator Identity, base Mode-Specific Rules, base Lead Allowlist, base Suggest-Members Guidance, and the Phase Arc. The extension supplies **additive** Mode-Specific Rules, **additive** Lead Allowlist entries (Permitted additions and Forbidden additions), and a Suggest-Members Guidance supplement — treat them all as supplementary, not replacing.

Hard contract for extension modes:
- Phase arc, Lead Identity, and Facilitator are inherited from the base — never overridden.
- Extension's Mode-Specific Rules are additive-only — they cannot remove or contradict base rules.
- Extension's Lead Allowlist additions are additive-only — Permitted additions expand what the lead may do, Forbidden additions expand what the lead must not do. Neither can remove or weaken a base-mode forbidden entry.
- Extension's Suggest-Members Guidance supplements the base — it does not replace it.
- If an extension appears to violate this contract (e.g., redefines phase semantics, removes a base-mode forbidden item), treat it as malformed and surface the issue to the user before proceeding.

If the mode skill (or its base) includes Pre-flight Reads, read those files before spawning.
