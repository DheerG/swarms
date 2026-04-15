---
description: Scaffold a custom workflow — generates a mode skill and shortcut command
argument-hint: <workflow name> [description]
disable-model-invocation: true
model: claude-opus-4-6
---

# /swarm:create-workflow

You are scaffolding a custom swarm workflow. This generates two files in the user's project:
1. A **mode skill** (`.claude/skills/<name>-mode/SKILL.md`) — the domain-specific operational spec
2. A **shortcut command** (`.claude/commands/<name>.md`) — the entry point users invoke

The interaction model is **generate first, edit after**. Ask the minimum needed to infer the full spec, generate everything, then let the user adjust.

## Step 0: Gather

$ARGUMENTS

**If $ARGUMENTS contains a name and description** (e.g., `write-article takes raw dictated thoughts and produces a polished blog post`): extract both and proceed directly to Step 1. Do not ask any questions.

**If $ARGUMENTS contains only a name** (one word): use it as the workflow name. Ask one question (plain text): "What does this workflow do? What does the user get at the end?" Wait for their response. Then proceed to Step 1.

**If $ARGUMENTS is empty**: ask one question (plain text): "What's this workflow called, and what does it do? (e.g., `write-article — takes raw dictated thoughts and produces a polished blog post`)" Wait for their response. Parse the name and purpose. Then proceed to Step 1.

Validate: the name should be kebab-case. If not, convert it silently.

---

## Step 1: Generate Spec

From the **name** and **purpose statement**, infer the complete workflow spec. Do not ask the user any questions in this step — generate everything using smart defaults and present it for review.

### Inference rules

**Closest built-in mode.** Identify which built-in mode (Code, Writing, General) is closest to this workflow's domain. Use its mode skill as a structural template for the generated spec.

**Lead Identity.** Infer from the domain. The lead is the person who coordinates the team and produces the final output. Give them a clear title and one-sentence identity. Example: writing domain → "Editor-in-Chief — shapes the article's structure, maintains narrative coherence, and ensures the final piece is publish-ready."

**Lead Allowlist.** Infer permitted and forbidden actions from the lead identity and domain. Every workflow needs at least: what the lead CAN do (their core responsibilities) and what the lead MUST NOT do (domain-specific constraints — e.g., "do not alter the user's core message").

**PE Title and Identity.** The PE is a senior facilitator who leads by asking questions and ensures healthy team discussion. The PE title MUST NOT overlap with the lead's domain — if the lead is editorial, the PE is strategic; if the lead is technical, the PE brings architectural perspective; if the lead is operational, the PE brings quality assurance. Pick a senior, recognized title (Chief Content Strategist, Principal Engineer, Chief of Staff, etc.) and write a one-line identity. Do not ask the user to choose.

**Suggest-Members Guidance.** Team composition is determined at runtime by `swarm:suggest-members` based on the user's outcomes. Write lean guidance for what kinds of voices to suggest for this domain (e.g., "writing-domain voices: voice/tone specialist, domain experts relevant to the topic, and a reader-perspective reviewer"). Do not ask the user to define static team composition.

**Outcomes Question.** Infer from the purpose. Writing workflow → "What do you want to write about? Dictate your thoughts — raw is fine." Code workflow → "What are you building?" Review workflow → "What needs review?" Pick the most natural prompt for this domain.

**Phase Arc.** Default to the standard skeleton (Research → Converge → Approve → Execute → Review → Refine → Deliver) with phase semantics adapted for the domain. Only deviate from standard if the purpose statement clearly implies a non-standard pipeline.

**Information Flow.** Default to standard (PE runs roundtables, lead coordinates). Only define custom routing if the purpose statement implies it (e.g., "writers should never see raw feedback").

**Pre-flight Reads.** Default to none. Only include if the purpose mentions external knowledge files (e.g., voice profiles, style guides).

**Mode-Specific Rules.** Draft ONLY rules that are genuinely domain-specific. Do NOT include rules already covered by swarm's universal hard rules. The following are already governed by swarm and must NOT be duplicated:
- Final delivery requires user approval
- 9/10+ confidence before shipping
- No mid-review changes
- Readonly members
- Wait for all reviews before making changes
- No idle chatter
- Verbatim relay of user input
- Greenfield execution (no task framing in briefs)
- Autonomous post-greenlight execution
- Ask about refinement before delivering

Only include rules that would NOT apply to a generic swarm run — behavioral constraints specific to this workflow's domain.

### Present the spec

Present the complete spec in this format:

> **Workflow: /[name]**
>
> **Purpose:** [one sentence]
>
> **Lead:** [title] — [identity]
>
> **Lead Allowlist:**
> - Permitted: [list]
> - Forbidden: [list]
>
> **PE:** [title] — [identity]
> *(The PE is a senior facilitator who leads discussions by asking questions and ensures the team adheres to the rules. They don't make decisions — they surface trade-offs and drive consensus.)*
>
> **Team Guidance:** Runtime-dependent via `swarm:suggest-members`. [domain-specific guidance]
>
> **Phases:** Standard (Research → Converge → Approve → Execute → Review → Refine → Deliver) [or custom if inferred]
>
> **Information Flow:** Standard [or custom if inferred]
>
> **Pre-flight Reads:** [files or "None"]
>
> **Outcomes Question:** "[inferred question]"
>
> **Mode-Specific Rules:**
> [only domain-specific rules, bulleted]

Then use **AskUserQuestion**:
- question: "Does this spec look right?"
- header: "Confirm"
- options:
  - label: "Generate the files"
    description: "Create the mode skill and shortcut command in my project"
  - label: "I have changes"
    description: "Let me adjust before generating"

If "I have changes": ask what to change (plain text), apply it, re-present the full spec. Repeat until confirmed.

---

## Step 2: Generate Files

### 2a: Generate the mode skill

Create the file at `.claude/skills/[name]-mode/SKILL.md` in the user's project directory (the current working directory). Use the **Write** tool.

Use this template, filling from the confirmed spec:

```markdown
---
name: [name]-mode
user-invocable: false
description: |
  [Purpose sentence] mode operational spec. Returns lead identity, PE identity, lead allowlist, pre-flight reads (optional), mode-specific rules, suggest-members guidance, and phase arc.
keywords: [domain-relevant keywords]
---

Return the following mode definition verbatim to the team lead. Do not summarize or interpret — the lead needs the full specification.

---

# [Name] Mode

## Lead Identity

[Lead identity statement]

## PE Title

[PE title]

## PE Identity

[PE identity line]

## Lead Allowlist

**Permitted:**
[- each permitted action]

**Forbidden:**
[- each forbidden action]

[Include Pre-flight Reads section ONLY if domain knowledge files were specified:]

## Pre-flight Reads

Before spawning the team, read these files and carry their content into spawn prompts:
[- each file path with brief description]

[End conditional section]

## Mode-Specific Rules

[Each rule as a bullet, grouped by section if multiple concerns]

[Include Information Flow section ONLY if custom routing was defined:]

## Information Flow

[Routing rules]

[End conditional section]

## Outcomes Question

[outcomes question]

## Suggest-Members Guidance

[Team composition guidance]

## Phase Arc

[Each phase as a ### heading. For phases that require user input or approval, state the AskUserQuestion call explicitly — do not leave transitions implicit. Follow the same structure as code-mode and writing-mode phase arcs.

Pre-fill Refine and Deliver with these stubs:]

### Refine (optional)

When the team reaches 9/10+ confidence, the lead asks the user via AskUserQuestion: question "9/10+ confidence reached. Run recursive refinement?", header "Refine", options "Deliver now" / "Run recursive refinement (9.25 → 9.5 → 9.75)".

If "Deliver now": skip to Deliver. If "Run recursive refinement": starting at 9.25, the lead asks the team "What specific changes — surgical only, no new scope — would raise your score to [threshold]?" Lead implements, team re-reviews to confirm the threshold is met, then advances to the next rung. The sequence is 9.25 → 9.5 → 9.75. This loop is autonomous once the user opts in. After 9.75 is confirmed, proceed to Deliver.

### Deliver

When 9/10+ confidence is reached, present completed work to the user. Do not commit or ship without explicit user sign-off.
```

### 2b: Generate the shortcut command

Create the file at `.claude/commands/[name].md` in the user's project directory. Use the **Write** tool.

Use this template:

```markdown
---
description: [purpose sentence]
argument-hint: [appropriate hint based on outcomes question]
disable-model-invocation: true
model: claude-opus-4-6
---

# /[name]

You MUST use the **Skill** tool to invoke `swarm:workflow-rules`. It returns the governance spec for this team run: pre-flight check, hard rules, briefing templates, and launch mechanics. Follow that spec for the entire run.

**No lead research unless enabled.** Unless the user explicitly enables lead research, do not read codebase files, spawn subagents, or perform research. Delegate all research to teammates.

## Settings

- **Mode:** [name]-mode (invoke via Skill tool at launch — use unqualified name, no `swarm:` prefix)
- **Outcomes question:** "[outcomes question]"
- **Defaults:** suggest-members (pass the Suggest-Members Guidance from [name]-mode and confirmed outcomes as context), Balanced shape, no lead research

## User-Provided Context

$ARGUMENTS

[If the workflow has intake-specific setup actions (argument parsing, branch creation, etc.), add:]

## Pre-flight

[- intake-specific actions only — domain knowledge files are in the mode skill's Pre-flight Reads section]

[End conditional section]

## Workflow

1. **Pre-flight.** Follow the pre-flight check from `swarm:workflow-rules`.
2. **Setup.** AskUserQuestion — "How would you like to set up the team?" Options: "Use defaults (Recommended)" / "Configure each step."
3. **Outcomes.** If User-Provided Context is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Accept without confirmation.
4. **Team configuration.** Defaults path: apply the defaults above and immediately proceed to step 5 in the same response — do not pause for user input. Configure path: ask about team members, shape, and lead research individually, then step 5.
5. **Confirmation.** Present team plan summary. AskUserQuestion: "Is this plan final, or do you have remaining inputs?" Options: "Launch the team" / "I have changes."
6. **Launch.** Follow the launch mechanics from `swarm:workflow-rules`. Invoke `[name]-mode` via the Skill tool (unqualified name) — this is your mode skill. Apply its spec, read any Pre-flight Reads files, then spawn the team.
```

### 2c: Report

Tell the user what was generated:

> **Generated files:**
>
> 1. `.claude/skills/[name]-mode/SKILL.md` — your custom mode skill
> 2. `.claude/commands/[name].md` — your shortcut command
>
> **To use it:** Run `/[name]` followed by your context (e.g., `/[name] build a dashboard`).
>
> **To customize:** Edit the mode skill to adjust phases, rules, or team guidance. The shortcut command rarely needs changes — it's thin wiring.
>
> **Swarm governance:** Hard rules, briefing templates, and team protocol come from swarm via `swarm:workflow-rules`. Your mode skill provides the domain-specific layer. Keep your swarm plugin updated to get governance improvements.
