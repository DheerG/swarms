---
description: Regenerate an existing custom workflow's shortcut command wiring from the current swarm template
argument-hint: <workflow name>
disable-model-invocation: true
---

# /swarm:update-workflow

You are updating an existing custom workflow's shortcut command to match the current swarm template. This command regenerates **only** the plugin-owned wiring of `.claude/commands/<name>.md` — the `## Workflow` section and default wiring that comes from swarm. It **never** touches the mode skill at `.claude/skills/<name>-mode/SKILL.md` — that file is consumer-owned.

## Step 0: Parse argument

$ARGUMENTS

The argument is the **workflow name** (kebab-case, matching the existing file name without `.md`). If $ARGUMENTS is empty, ask the user (plain text, not AskUserQuestion): "Which workflow should I update? (Pass the name — e.g., `triage-gh-issue`.)" Wait for their response.

## Step 1: Locate and read the existing file

The target file is `.claude/commands/<name>.md` in the current working directory.

- If the file does not exist: tell the user "No workflow found at `.claude/commands/<name>.md`. This command updates existing workflows — use `/swarm:create-workflow` to create a new one." Stop.
- If the file exists: use the **Read** tool to read it.

Do **not** read or modify `.claude/skills/<name>-mode/SKILL.md`. That file is consumer-owned.

## Step 2: Extract consumer-owned sections

From the existing shortcut command, extract these consumer-owned values and blocks verbatim. These will be preserved:

- **Frontmatter fields:** `description`, `argument-hint`, `disable-model-invocation`, and any other fields present. Preserve all of them.
- **`## Settings` section** — the entire block under the `## Settings` heading, including Mode, Outcomes question, Defaults, and any other settings the consumer has added.
- **`## User-Provided Context` section** — the block under that heading (typically `$ARGUMENTS`).
- **`## Pre-flight` section if present** — the block under that heading (intake-specific actions, bash commands, arg parsing). This is consumer-owned.
- **Any section not recognized as plugin-owned** — preserve as-is.

Consumer ownership rule: anything that is not the plugin-owned wiring (the template preamble and the `## Workflow` section) belongs to the consumer.

## Step 3: Regenerate the plugin-owned sections

The plugin-owned parts of a custom shortcut command are:

1. **The preamble** — the line directing the lead to invoke `swarm:workflow-rules` and the "No lead research unless enabled." paragraph.
2. **The `## Workflow` section** — the numbered steps that wire the run.

Use this current template for the plugin-owned parts, substituting `<name>` with the workflow name:

```markdown
# /<name>

You MUST use the **Skill** tool to invoke `swarm:workflow-rules`. It returns the governance spec for this team run: pre-flight check, hard rules, briefing templates, and launch mechanics. Follow that spec for the entire run.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all research to teammates.
```

And for the Workflow section:

```markdown
## Workflow

1. **Pre-flight.** Follow the pre-flight check from `swarm:workflow-rules`.
2. **Setup.** AskUserQuestion — "How would you like to set up the team?" Options: "Defaults — Ultra (Recommended)" (auto-configure mode/team/research; full team on the stronger model — reliable rule-following) / "Defaults — Balanced" (same auto-config; cheaper model for members — lower cost, less reliable rule-following) / "Configure each step" (choose mode, team, tier, research individually).
3. **Outcomes.** If User-Provided Context is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Accept without confirmation.
4. **Team configuration.** Defaults path (either Defaults option): apply the defaults above with the tier set to the option picked (Ultra or Balanced), and immediately proceed to step 5 in the same response — do not pause for user input. Configure path: ask about team members, tier, and lead research individually, then step 5.
5. **Confirmation.** Present team plan summary (include a `Cadence: Serial (default) — one member at a time; far fewer rate-limit errors and much less cross-chatter, marginally slower; Parallel only with rate-limit headroom` line). AskUserQuestion: "Is this plan final, or do you have remaining inputs?" Options: "Launch the team" / "I have changes."
6. **Launch.** Follow the launch mechanics from `swarm:workflow-rules`. Invoke `<name>-mode` via the Skill tool (unqualified name) — this is your mode skill. Apply its spec, read any Pre-flight Reads files, then spawn the team.
```

## Step 4: Assemble the proposed file

Compose the new file by merging consumer-owned sections (Step 2) with regenerated plugin-owned sections (Step 3):

1. Frontmatter (consumer-owned, preserved as-is — but if `generated-by` is missing from the frontmatter, add `generated-by: swarm@<current version>` by reading the version from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`; if present, update its value to the current version). If `${CLAUDE_PLUGIN_ROOT}` is unset or the plugin.json read fails, skip the stamp rather than aborting the update — provenance is informational, not load-bearing, and the update must still succeed.
2. Plugin-owned preamble (from Step 3).
3. `## Settings` section (consumer-owned, preserved as-is).
4. `## User-Provided Context` section (consumer-owned, preserved as-is).
5. `## Pre-flight` section if present in the original (consumer-owned, preserved as-is).
6. Plugin-owned `## Workflow` section (from Step 3).
7. Any other consumer-owned sections from the original, preserved in their original order.

## Step 5: Detect consumer edits in the Workflow section, then show the diff and confirm

**5a. Proactive consumer-edit scan.** Before presenting the diff, compare the original `## Workflow` section (extracted from the file read in Step 1) against the current template's `## Workflow` section (from Step 3) line-by-line. For every line present in the original that is NOT present in the template, surface it explicitly above the diff as a warning:

> **Consumer edit detected in the Workflow section — this content will be removed if you apply:**
> - "[quoted line]"
> - "[quoted line]"
>
> If you still want this content after the update, copy it now and re-add it manually after the update is applied.

If no consumer edits are detected in the Workflow section, omit this warning.

**5b. Show the diff and ask.** Compute the textual diff between the current file contents (from Step 1) and the proposed file contents (from Step 4).

- **If the diff is empty**: tell the user "`<name>` is already in sync with the current swarm template. No changes needed." Stop.
- **If the diff is non-empty**: present the diff as a labeled "Before / After" split (not unified diff format — Before/After is readable without diff tooling and the audience for this command is workflow authors, not code reviewers), with the Step 5a warning above it if any consumer edits were detected. Then use **AskUserQuestion**:
  - question: "Apply this update to `.claude/commands/<name>.md`?"
  - header: "Apply"
  - options:
    - label: "Apply the update"
      description: "Write the regenerated file — your consumer-owned sections are preserved"
    - label: "Skip"
      description: "Leave the file unchanged"

The Step 5a warning is load-bearing. A user who accepts the diff without noticing a single deleted sentence inside the Workflow section loses consumer content silently; the explicit line-by-line callout prevents that.

## Step 6: Apply or abort

**If "Apply the update"**: use the **Write** tool to write the composed file from Step 4 to `.claude/commands/<name>.md`. Then tell the user:

> Updated `.claude/commands/<name>.md` to swarm@<version>. The mode skill at `.claude/skills/<name>-mode/SKILL.md` was not touched (consumer-owned).

**If "Skip"**: tell the user "Skipped. No changes written." Stop.

## Scope

This command updates the **shortcut command only**. It never reads or writes the mode skill. Mode skill drift — including the Refine and Deliver phase stubs in full custom modes that are plugin-owned boilerplate at generation time — is out of scope for this command. The mode skill is consumer-owned in its entirety from the moment it is generated; the consumer decides whether to update it manually.

**To convert an existing full custom mode to a thin wrapper**, run `/swarm:create-workflow` and select "Thin wrapper" at Step 0.5 — it will generate a wrapper mode skill and shortcut in the same location, overwriting the old files. Move any domain content (Rules, Allowlist additions, Suggest-Members guidance) from the old mode skill into the new wrapper's additive sections manually before running, or merge afterward.
