---
description: Launch a custom workflow using a user-defined mode skill
argument-hint: <mode-skill-name> [context]
disable-model-invocation: true
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

**Extension modes.** If the invoked mode skill's frontmatter declares `extends:` naming a base (e.g., `extends: swarm:code-mode`, `extends: swarm:writing-mode`, or `extends: swarm:general-mode`), it is an extension mode. Read the frontmatter directly from the file at `.claude/skills/<name>/SKILL.md` to detect this — do not infer from body prose. Invoke the named base mode skill via the Skill tool **immediately after** the extension. The base provides Lead Identity, Facilitator Title, Facilitator Identity, base Mode-Specific Rules, base Lead Allowlist, base Suggest-Members Guidance, and the Phase Arc. The extension supplies **additive** Mode-Specific Rules, **additive** Lead Allowlist entries (Permitted additions and Forbidden additions), and a Suggest-Members Guidance supplement — treat them all as supplementary, not replacing.

Hard contract for extension modes:
- Phase arc, Lead Identity, and Facilitator are inherited from the base — never overridden.
- Extension's Mode-Specific Rules are additive-only — they cannot remove or contradict base rules.
- Extension's Lead Allowlist additions are additive-only — Permitted additions expand what the lead may do, Forbidden additions expand what the lead must not do. Neither can remove or weaken a base-mode forbidden entry.
- Extension's Suggest-Members Guidance supplements the base — it does not replace it.
- If an extension appears to violate this contract (e.g., redefines phase semantics, removes a base-mode forbidden item), treat it as malformed and surface the issue to the user before proceeding.

The mode skill (or the base mode, for extensions) may define a domain-specific outcomes question. If so, use it instead of the generic fallback.

## Workflow

1. **Mode spec.** Invoke the mode skill via the Skill tool. If it is an extension mode, also invoke its declared base (see "Extension modes" above) and combine: use the base's Lead Identity, Facilitator, Phase Arc, base rules, and base allowlist; append the extension's additive Mode-Specific Rules, additive Lead Allowlist entries (Permitted and Forbidden), and Suggest-Members Guidance supplement. If the mode (or its base) defines an outcomes question, use it. Otherwise fall back to "What are you working on?" If the mode (or its base) includes Pre-flight Reads, read those files before spawning.
2. **Setup.** AskUserQuestion — "How would you like to set up the team?" Options: "Use defaults (Recommended)" / "Configure each step."
3. **Outcomes.** If user-provided context (everything after the mode skill name) is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Accept without confirmation.
4. **Team configuration.** Defaults path: apply the defaults above and immediately proceed to step 5 in the same response — do not pause for user input. Configure path: follow launch.md Steps 4–6, then step 5.
5. **Confirmation.** Follow launch.md Step 7. Mode is the custom mode skill name.
6. **Launch.** Follow launch.md Step 8. At Step 8b, the mode skill is already invoked — apply its spec directly.
