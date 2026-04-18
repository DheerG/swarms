---
description: Scaffold a custom workflow — generates a mode skill and shortcut command
argument-hint: <workflow name> [description]
disable-model-invocation: true
---

# /swarm:create-workflow

You are scaffolding a custom swarm workflow. This generates two files in the user's project:
1. A **mode skill** (`.claude/skills/<name>-mode/SKILL.md`) — the domain-specific operational spec
2. A **shortcut command** (`.claude/commands/<name>.md`) — the entry point users invoke

The interaction model is **generate first, edit after**. Ask the minimum needed to infer the full spec, generate everything, then let the user adjust.

## Step 0: Gather

$ARGUMENTS

**If $ARGUMENTS contains a name and description** (has sentence structure, verbs, or a separator like `write-article — takes raw thoughts and produces a polished blog post`): extract both and proceed directly to Step 1.

**If $ARGUMENTS appears to be a name only** (kebab-case identifier, no verb or sentence structure — e.g., `write-article`, `code-review`): use it as the workflow name. Ask one question (plain text): "What does this workflow do? What does the user get at the end?" Wait for their response. Then proceed to Step 1.

**If $ARGUMENTS is empty**: ask one question (plain text): "What's this workflow called, and what does it do? (e.g., `write-article — takes raw dictated thoughts and produces a polished blog post`)" Wait for their response. Parse the name and purpose. Then proceed to Step 1.

Validate: the name should be kebab-case. If not, convert it silently.

---

## Step 1: Generate Spec

From the **name** and **purpose statement**, infer the complete workflow spec. Do not ask the user any questions in this step — generate everything using smart defaults and present it for review. If the purpose statement is too thin to infer a domain confidently, make your best guess and note it in the spec presentation (e.g., "I inferred this as a writing workflow — adjust if that's wrong"). Do not stop to ask.

### Inference rules

**Closest built-in mode.** Identify which built-in mode (Code, Writing, General) is closest to this workflow's domain. Use its mode skill as a structural template for the generated spec.

**Lead Identity.** Infer from the domain. The lead is the person who coordinates the team and produces the final output. Give them a clear title and one-sentence identity. Example: writing domain → "Editor-in-Chief — shapes the article's structure, maintains narrative coherence, and ensures the final piece is publish-ready."

**Lead Allowlist.** Infer permitted and forbidden actions from the lead identity and domain. Every workflow needs at least: what the lead CAN do (their core responsibilities) and what the lead MUST NOT do (domain-specific constraints — e.g., "do not alter the user's core message").

**Facilitator Title and Identity.** The facilitator leads by asking questions and ensures healthy team discussion. The facilitator title MUST NOT overlap with the lead's domain — if the lead is editorial, the facilitator is strategic; if the lead is technical, the facilitator brings architectural perspective; if the lead is operational, the facilitator brings quality assurance. Pick a senior, recognized title (Chief Content Strategist, Principal Engineer, Chief of Staff, etc.) and write a one-line identity. Do not ask the user to choose.

**Suggest-Members Guidance.** Team composition is determined at runtime by `swarm:suggest-members` based on the user's outcomes. Write lean but substantive guidance for what kinds of voices to suggest for this domain. Examples: writing workflow → "Favor writing-domain voices: a voice/tone specialist to preserve the user's style, domain experts relevant to the topic, and a reader-perspective reviewer." Code workflow → "Favor technical voices: at least one architect-level thinker, domain-specific experts relevant to the stack, and someone representing the end-user or business perspective." This guidance is passed to suggest-members at runtime, so make it actionable, not a placeholder. Do not ask the user to define static team composition.

**Outcomes Question.** Infer from the purpose. Writing workflow → "What do you want to write about? Dictate your thoughts — raw is fine." Code workflow → "What are you building?" Review workflow → "What needs review?" Pick the most natural prompt for this domain.

**Phase Arc.** Default to the standard skeleton (Research → Converge → Approve → Execute → Review → Refine → Deliver) with phase semantics adapted for the domain. Only deviate from standard if the purpose statement clearly implies a non-standard pipeline.

**Information Flow.** Default to standard (facilitator runs roundtables, lead coordinates). Only define custom routing if the purpose statement implies it (e.g., "writers should never see raw feedback").

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
> **Lead (the person who does the work):** [title] — [identity]
>
> **Lead Allowlist:**
> - Permitted: [list]
> - Forbidden: [list]
>
> **Facilitator (shapes discussion, asks the hard questions, never makes the decisions):** [title] — [identity]
>
> **Team Guidance (who gets suggested at runtime):** Team composition is determined when you run the workflow, based on what you're working on. We'll tell `swarm:suggest-members` to favor: [domain-specific guidance].
>
> **Phases:** Standard (Research → Converge → Approve → Execute → Review → Refine → Deliver) [or custom if inferred]
>
> **Information Flow:** Standard [or custom if inferred]
>
> **Pre-flight Reads:** [files or "None"]
>
> **Outcomes Question (what the user is asked when they run the workflow):** "[inferred question]"
>
> **Mode-Specific Rules (domain constraints on top of swarm's standard governance):**
> [only domain-specific rules, bulleted]

Then use **AskUserQuestion**:
- question: "Does this spec look right?"
- header: "Confirm"
- options:
  - label: "Generate the files"
    description: "Create the mode skill and shortcut command in my project"
  - label: "I have changes"
    description: "Let me adjust before generating"

If "I have changes": ask what to change with a prompt that names the editable fields — e.g., "What would you like to adjust? You can change the lead title, facilitator role, phases, rules, outcomes question, or any other field above." Apply the change, re-present the **full** spec (not just the changed field — the user needs the complete picture). Repeat until confirmed.

---

## Step 2: Generate Files

### 2a: Generate the mode skill

Create the file at `.claude/skills/[name]-mode/SKILL.md` in the user's project directory (the current working directory). Use the **Write** tool.

Use this template, filling from the confirmed spec. Include `## Pre-flight Reads` only if domain knowledge files were specified. Include `## Information Flow` only if custom routing was defined. Omit those sections entirely (heading and body) if they don't apply.

```markdown
---
name: [name]-mode
user-invocable: false
description: |
  [Purpose sentence] mode operational spec. Returns lead identity, facilitator identity, lead allowlist, pre-flight reads (optional), mode-specific rules, outcomes question (optional), suggest-members guidance, and phase arc.
keywords: [domain-relevant keywords]
---

Return the following mode definition verbatim to the team lead. Do not summarize or interpret — the lead needs the full specification.

---

# [Name] Mode

## Lead Identity

[Lead identity statement]

## Facilitator Title

[facilitator title]

## Facilitator Identity

[facilitator identity line]

## Lead Allowlist

**Permitted:**
[- each permitted action]

**Forbidden:**
[- each forbidden action]

## Pre-flight Reads

Before spawning the team, read these files and carry their content into spawn prompts:
[- each file path with brief description]

## Mode-Specific Rules

[Each rule as a bullet, grouped by section if multiple concerns]

## Information Flow

[Routing rules]

## Outcomes Question

[outcomes question]

## Suggest-Members Guidance

[Team composition guidance]

## Phase Arc

[Each phase as a ### heading. For Research through Review, infer phase semantics from the domain and lead identity — write them out as full paragraphs matching code-mode and writing-mode depth. Use the closest built-in mode as a structural template. For phases that require user input or approval, state the AskUserQuestion call explicitly — do not leave transitions implicit. The Review phase must explicitly state: "When 9/10+ confidence is reached, proceed to Refine — do not skip to Deliver."

Pre-fill Refine and Deliver with these stubs:]

### Refine (optional)

When the team reaches 9/10+ confidence, the lead asks the user via AskUserQuestion: question "9/10+ confidence reached. Run recursive refinement?", header "Refine", options "Deliver now" / "Run recursive refinement (9.25 → 9.5 → 9.75 → 10)".

If "Deliver now": skip to Deliver. If "Run recursive refinement": starting at 9.25, the lead asks the team "What specific changes — surgical only, no new scope — would raise your score to [threshold]?" Lead implements, team re-reviews to confirm the threshold is met, then advances to the next rung. The sequence is 9.25 → 9.5 → 9.75 → 10. For the 10 rung, the lead asks: "What, if anything, would you still change? If nothing, say so." This loop is autonomous once the user opts in. After 10 is confirmed, proceed to Deliver.

### Deliver

When 9/10+ confidence is reached, present completed work to the user. Follow the ship definition from `.claude/swarm-ship.md` — execute the defined shipping steps with the user's approval. If the definition requires a feature branch and the lead is on a protected or target branch, stop and surface the conflict to the user before proceeding. Do not commit or ship without explicit user sign-off.
```

When generating both files (mode skill and shortcut command), omit all bracket comments, placeholder instructions, and conditional markers. Generated files should contain only filled content. If a conditional section doesn't apply (e.g., no Pre-flight Reads, no Information Flow, no intake-specific Pre-flight), omit the entire section including its heading. Remove extra blank lines left by omitted sections.

### 2b: Generate the shortcut command

Create the file at `.claude/commands/[name].md` in the user's project directory. Use the **Write** tool.

Use this template:

```markdown
---
description: [purpose sentence]
argument-hint: [appropriate hint based on outcomes question]
disable-model-invocation: true
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


## Workflow

1. **Pre-flight.** Follow the pre-flight check from `swarm:workflow-rules`.
2. **Setup.** AskUserQuestion — "How would you like to set up the team?" Options: "Use defaults (Recommended)" / "Configure each step."
3. **Outcomes.** If User-Provided Context is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Accept without confirmation.
4. **Team configuration.** Defaults path: apply the defaults above and immediately proceed to step 5 in the same response — do not pause for user input. Configure path: ask about team members, shape, and lead research individually, then step 5.
5. **Confirmation.** Present team plan summary. AskUserQuestion: "Is this plan final, or do you have remaining inputs?" Options: "Launch the team" / "I have changes."
6. **Launch.** Follow the launch mechanics from `swarm:workflow-rules`. Invoke `[name]-mode` via the Skill tool (unqualified name) — this is your mode skill. Apply its spec, read any Pre-flight Reads files, then spawn the team.
```

Apply the same cleanup rules from Step 2a: omit bracket comments, conditional markers, and sections that don't apply (e.g., Pre-flight if no intake actions). No orphaned blank lines.

### 2c: Report

Tell the user what was generated:

> **Generated files:**
>
> 1. `.claude/skills/[name]-mode/SKILL.md` — your custom mode skill
> 2. `.claude/commands/[name].md` — your shortcut command
>
> **To use it:** Run `/[name]` followed by your context.
>
> **To customize:** Edit the mode skill to adjust phases, rules, or team guidance. The shortcut command rarely needs changes — it's thin wiring.
>
> **Swarm governance:** Hard rules, briefing templates, and team protocol come from swarm via `swarm:workflow-rules`. Your mode skill provides the domain-specific layer. Keep your swarm plugin updated to get governance improvements.
