---
description: Scaffold a custom workflow — generates a mode skill and shortcut command
argument-hint: <workflow name>
disable-model-invocation: true
model: claude-opus-4-6
---

# /swarm:create-workflow

You are scaffolding a custom swarm workflow. This generates two files in the user's project:
1. A **mode skill** (`.claude/skills/<name>-mode/SKILL.md`) — the domain-specific operational spec
2. A **shortcut command** (`.claude/commands/<name>.md`) — the entry point users invoke

Follow every step below in order. Do NOT skip steps.

## Step 0: Parse Arguments

$ARGUMENTS

If $ARGUMENTS is non-empty, use the first word as the **workflow name**. Everything after is **domain context** — use it to inform your questions below (pre-fill where obvious, but still confirm with the user).

If $ARGUMENTS is empty, ask the user (plain text): "What's this workflow called? (e.g., blog-write, code-review, design-critique)" Wait for their response.

Validate: the name should be kebab-case, no spaces. If not, convert it.

---

## Step 1: Domain Interview

Ask the following questions to understand the workflow domain. Use **AskUserQuestion** for structured choices. Use plain text for open-ended questions. Ask one question at a time — do not batch.

### 1a: Purpose

Ask (plain text): "Describe what this workflow does in one sentence. What does the user get at the end?"

### 1b: Lead Identity

Ask (plain text): "What does the team lead do in this workflow? What are they responsible for, and what should they NOT touch?"

From their response, draft:
- **Lead Identity** statement (one sentence — what the lead does)
- **Lead Allowlist** — Permitted and Forbidden actions

Present back to the user for confirmation (plain text, not AskUserQuestion).

### 1c: PE Role

Use **AskUserQuestion**:
- question: "What should the PE (facilitator) role be called in this workflow?"
- header: "PE Role"
- options:
  - label: "Principal Engineer"
    description: "Technical leadership — good for engineering workflows"
  - label: "Editorial Director"
    description: "Editorial leadership — good for writing and content workflows"
  - label: "Chief of Staff"
    description: "Operational leadership — good for general workflows"
  - label: "Custom title"
    description: "I'll provide a domain-specific title"

If "Custom title": ask (plain text) what the PE should be called and a one-line description of their identity.

For all options, ask (plain text): "In one sentence, what lens does the PE bring? (e.g., 'leaves all coding to the team lead', 'facilitates strategic direction, never makes editorial decisions')"

### 1d: Team Composition Guidance

Ask (plain text): "What kinds of team members work best for this workflow? Describe the mix — e.g., 'technical and domain experts, plus someone representing the customer' or 'strategist, editor, and subject-matter experts'."

### 1e: Phase Arc

Present the standard swarm phase arc as a starting point:

> **Standard skeleton:** Research → Converge → Approve → Execute → Review → Refine → Deliver

Use **AskUserQuestion**:
- question: "How should the phase arc work for this workflow?"
- header: "Phases"
- options:
  - label: "Use standard phases (Recommended)"
    description: "Research → Converge → Approve → Execute → Review → Refine → Deliver"
  - label: "Customize phases"
    description: "Rename, reorder, add, or remove phases"

If "Use standard phases": confirm with the user (plain text): "Standard phases work. I'll pre-fill the phase arc based on your domain — you can adjust in the generated file." Do NOT ask per-phase descriptions for standard phases. The mode skill will use the standard skeleton and the lead will interpret phase semantics from the Lead Identity and Mode-Specific Rules.

If "Customize phases": ask (plain text) the user to describe their phases — name, what happens in each, and who acts. Map their phases onto the skeleton where possible. Only ask for per-phase descriptions for the phases the user is customizing.

### 1f: Information Flow (optional)

Use **AskUserQuestion**:
- question: "Does this workflow need custom routing rules?"
- header: "Routing"
- options:
  - label: "No, use standard routing"
    description: "PE runs roundtables, lead coordinates — works for most workflows"
  - label: "Yes, define routing"
    description: "Specific rules for who talks to whom (e.g., writer never sees raw feedback)"

If "Yes": ask (plain text) the user to describe their routing rules — who sends to whom, what goes through whom.

### 1g: Domain Knowledge Files (optional)

Use **AskUserQuestion**:
- question: "Does this workflow use domain knowledge files?"
- header: "Knowledge"
- options:
  - label: "No"
    description: "No companion skill files needed"
  - label: "Yes"
    description: "The lead should read local files before spawning the team (e.g., voice profiles, style guides, reference docs)"

If "Yes": ask (plain text) what files and where they live (or should live). Note these for the mode skill's pre-flight reads.

### 1h: Outcomes Question

Ask (plain text): "When a user runs this workflow, what question should they answer to describe what they want? (e.g., 'What are you writing about?', 'What are you building?', 'What needs review?')"

---

## Step 2: Mode-Specific Rules

Based on the interview, draft mode-specific rules. These extend the universal hard rules. Include rules from:
- Lead allowlist constraints restated as rules
- Domain-specific behavioral rules (e.g., "Writer isolation" for writing, "No code changes during review" for code)
- Any routing or ownership rules from the information flow

Present the drafted rules to the user. Ask (plain text): "Here are the mode-specific rules I've drafted. Anything to add, remove, or change?"

---

## Step 3: Confirmation

Present the full spec as a summary:

> **Workflow: /[name]**
>
> **Purpose:** [one sentence]
>
> **Lead Identity:** [statement]
>
> **Lead Allowlist:**
> - Permitted: [list]
> - Forbidden: [list]
>
> **PE:** [title] — [identity]
>
> **Team Guidance:** [composition description]
>
> **Phases:** [list of phases with one-line descriptions]
>
> **Information Flow:** [standard or custom description]
>
> **Pre-flight Reads:** [files or "none"]
>
> **Outcomes Question:** "[question]"
>
> **Mode-Specific Rules:** [summary]

Use **AskUserQuestion**:
- question: "Does this spec look right?"
- header: "Confirm"
- options:
  - label: "Generate the files"
    description: "Create the mode skill and shortcut command in my project"
  - label: "I have changes"
    description: "Let me adjust before generating"

If "I have changes": ask what to change, apply it, re-present. Repeat until confirmed.

---

## Step 4: Generate Files

### 4a: Generate the mode skill

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

[Lead identity statement from interview]

## PE Title

[PE title]

## PE Identity

[PE identity line]

## Lead Allowlist

**Permitted:**
[- each permitted action]

**Forbidden:**
[- each forbidden action]

[Include Pre-flight Reads section ONLY if domain knowledge files were specified in Step 1g:]

## Pre-flight Reads

Before spawning the team, read these files and carry their content into spawn prompts:
[- each file path with brief description]

[End conditional section]

## Mode-Specific Rules

[Each rule as a bullet, grouped by section if multiple concerns]

[Include Information Flow section here ONLY if custom routing was defined:]

## Information Flow

[Routing rules from interview]

## Outcomes Question

[outcomes question from Step 1h]

## Suggest-Members Guidance

[Team composition guidance from interview]

## Phase Arc

[Each phase as a ### heading. For phases that require user input or approval, state the AskUserQuestion call explicitly — do not leave transitions implicit. Follow the same structure as code-mode and writing-mode phase arcs.

If standard phases were selected, pre-fill Refine and Deliver with these stubs:]

### Refine (optional)

When the team reaches 9/10+ confidence, the lead asks the user via AskUserQuestion: question "9/10+ confidence reached. Run recursive refinement?", header "Refine", options "Deliver now" / "Run recursive refinement (9.25 → 9.5 → 9.75)".

If "Deliver now": skip to Deliver. If "Run recursive refinement": starting at 9.25, the lead asks the team "What specific changes — surgical only, no new scope — would raise your score to [threshold]?" Lead implements, team re-reviews to confirm the threshold is met, then advances to the next rung. The sequence is 9.25 → 9.5 → 9.75. This loop is autonomous once the user opts in. After 9.75 is confirmed, proceed to Deliver.

### Deliver

When 9/10+ confidence is reached, present completed work to the user. Do not commit or ship without explicit user sign-off.
```

### 4b: Generate the shortcut command

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
- **Outcomes question:** "[outcomes question from interview]"
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

### 4c: Report

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
