---
description: Launch a custom workflow using a user-defined mode skill
argument-hint: <mode-skill-name> [context]
disable-model-invocation: true
model: claude-opus-4-7
---

# /swarm:workflow

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` for Step 0 (pre-flight), Step 1 (hard rules), and Step 8 (launch). This command replaces Steps 2–7.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all research to teammates.

## Parsing $ARGUMENTS

$ARGUMENTS

The first word of $ARGUMENTS is the **mode skill name** (e.g., `blog-mode`). Everything after it is the **user-provided context**. If $ARGUMENTS is empty, ask the user: "Which custom mode skill should I use?" (plain text, not AskUserQuestion). Wait for their response.

## Settings

- **Mode:** Custom (the mode skill name parsed above)
- **Defaults:** suggest-members (custom mode), Balanced shape, no lead research

## Mode Skill Invocation

Invoke the mode skill by its **unqualified name** via the Skill tool (e.g., `blog-mode`, not `swarm:blog-mode`) **before the setup/outcomes flow** (Workflow step 1 below). User-defined mode skills live in the project's `.claude/skills/` directory and are resolved without namespace prefix.

If the Skill tool cannot find the mode skill, tell the user: "Mode skill '[name]' not found. Verify that `.claude/skills/[name]/SKILL.md` exists in your project." Stop and wait.

The mode skill may define a domain-specific outcomes question. If so, use it instead of the generic fallback.

## Workflow

1. **Mode spec.** Invoke the mode skill via the Skill tool. Read its full operational spec. If it defines an outcomes question, use it. Otherwise fall back to "What are you working on?" If it includes Pre-flight Reads, read those files before spawning.
2. **Setup.** AskUserQuestion — "How would you like to set up the team?" Options: "Use defaults (Recommended)" / "Configure each step."
3. **Outcomes.** If user-provided context (everything after the mode skill name) is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Accept without confirmation.
4. **Team configuration.** Defaults path: apply the defaults above and immediately proceed to step 5 in the same response — do not pause for user input. Configure path: follow launch.md Steps 4–6, then step 5.
5. **Confirmation.** Follow launch.md Step 7. Mode is the custom mode skill name.
6. **Launch.** Follow launch.md Step 8. At Step 8b, the mode skill is already invoked — apply its spec directly.
