---
description: Interactively launch an agent team with guided setup
disable-model-invocation: true
model: claude-opus-4-6
---

# /swarm:launch

You are launching an agent team using the Swarm plugin. Follow every step below in exact order. Do NOT skip steps. Do NOT batch multiple steps into one turn.

## Greenfield execution

When executing `/swarm:launch`, the briefing templates in Step 8c and Step 8d are the exclusive source of truth for team member context. Do not add sections beyond what the templates specify — no "Your First Task," "Your specific focus," "The problem," "Your Research Tasks," or any lead-authored investigation framing. If you feel the urge to add context to a briefing, stop. That urge is the bug this preamble exists to prevent.

## Step 0: Pre-flight Check

Check if the TeamCreate tool is available to you. If TeamCreate is in your available tools, agent teams are **ENABLED** — proceed to Step 1.

If TeamCreate is NOT available, agent teams are **DISABLED**. Use the **AskUserQuestion** tool:

- question: "Agent teams are not enabled. Want me to enable it?"
- header: "Setup"
- options:
  - label: "Yes, enable it (Recommended)"
    description: "I'll add the setting to your project or global config"
  - label: "No, I'll do it myself"
    description: "I'll show you what to add to your settings"

**If "Yes"**: Check if `.claude/settings.json` exists in the current project directory. If it does, use the Read tool to read it, then use the Edit tool to add `"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"` to the `env` object (create the `env` object if it doesn't exist). If `.claude/settings.json` does not exist in the project, do the same in `~/.claude/settings.json` instead. Then tell the user:

> Done. Restart Claude Code for the change to take effect, then run `/swarm:launch` again.

**If "No"**: Tell the user:

> Add this to your `.claude/settings.json` (project) or `~/.claude/settings.json` (global), then restart Claude Code:
> ```json
> {
>   "env": {
>     "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
>   }
> }
> ```

**STOP HERE if agent teams are not enabled. Do NOT proceed until confirmed enabled.**

**If ENABLED**, proceed to Step 1.

---

## Step 1: Hard Rules

### General Rules

These rules govern all team behavior. They are non-negotiable. Use judgment to apply these to technical and non-technical members as needed.

#### Troubleshooting

- **Training and memory goes stale.** Research on the web often.

#### Planning & Approval

- **Before greenlight: confirm plan is final.** Ask if the user has remaining inputs. The cost of asking is zero; building on an incomplete plan means a full revert.
- **After greenlight: execute autonomously.** Do not ask for confirmation between phases. Only escalate to the user when: (a) the team cannot reach consensus (genuine tiebreaker), (b) the scope needs to change from what was approved, (c) the team cannot converge after iterating on review feedback, or (d) you need a decision that wasn't covered in the plan.

#### Agent Teams

- **Readonly members.** All members apart from the lead are read-only members.
- **Match your assigned model.** Match the reasoning effort of your assigned model. Don't sandbag, don't strain beyond it, don't second-guess the assignment.
- **Lead asking team members for help.** If the lead is feeling stuck, they should ask team members for help. Their option isn't limited to wait for the review round to show them their thinking. Ask one or more relevant members for help to get unblocked.

#### Agent Team Member Response Style

- **Favor brevity during round tables and discussions.** Experts know how to summarize their statements.
- **No idle chatter.** If you have nothing new to report, do not send a message. Never send messages that only confirm you are available or waiting.
- **Don't regurgitate decided points.** Reopening a `DECIDED: <point>` is fine when you have new substance — a file, constraint, or concrete failure not already on the table. Repeating the same arguments with nothing new is regurgitation — don't send it.

#### Review Process

- **Wait for ALL reviews before making changes.** Never fix findings mid-review. Wait for every team member to respond, then batch fixes.
- **Intermediate review cycles are autonomous.** The PE drives review rounds and determines when the team has reached sufficient confidence. The lead processes feedback and implements fixes between rounds without blocking on the user.
- **Final delivery requires user approval.** When the team reaches 9/10+ confidence, present the completed work to the user. Do not commit or ship without explicit user sign-off.
- **Reviews must reach 9/10+ confidence before shipping.** Keep plan docs updated every cycle. Run gap analysis every cycle.
- **Break review loops with evidence.** If a finding survives arbitration without new evidence, the PE invokes `swarm:resolve-dispute` to force a put-up-or-concede exchange.

Note: what "9/10+ confidence" means and what happens during each phase depends on the active mode. The mode file defines this.

#### Transparency & Honesty

- **No performative shortcuts.** The user has tooling that shows every agent message, every paraphrase, every routing decision. Never misrepresent what was done. When told "verbatim," send their exact words. When told "send to the team," send to the team — not one person.
- **ASK before implementing uncertain fixes.** If the right approach isn't obvious, ask. Never pick a fix that contradicts the intent of recent work. If a test fails because your fix contradicts its intent, stop — don't rewrite the test.

### Team Lead Rules

These apply to the team lead only.

- **Never enter plan mode.** If a plan exists, implement it directly.
- **Always use TeamCreate.** When user says "agent team," use TeamCreate + Agent with `team_name`. Never substitute with Explore agents or manual coordination.
- **Never cut corners on agent teams.** Spawn the full team as defined. Never apply changes yourself to save time. Never skip pipeline stages.
- **Never shut down agent teams without explicit user instruction; always use the shutdown_request protocol via SendMessage.**
- **Being asked to commit, create a PR, ship, deliver, etc. is not a shutdown request.**
- **Shutdown protocol.** The user's shutdown request is the permission — do not re-ask. Create `/tmp/swarm-shutdown-authorized` via Bash, then send shutdown_request to each teammate individually (never broadcast structured messages). If the hook blocks, follow its instructions.
- **Don't repeat yourself while waiting.** When waiting for user input, say so once. Teammate idle notifications do not require a user-facing response.

---

## User-Provided Context

$ARGUMENTS

---

## Step 2: Ask About Outcomes

**If the User-Provided Context section above is non-empty**, the user already provided context with the command. Skip the "Do you have outcomes?" question below. Do NOT echo their input back or reformat it as numbered outcomes — their context is already visible above. Read their context carefully, then briefly state what you understand the goal to be in a single natural sentence (e.g., "Got it — you want to [goal]."). Then go directly to the confirmation prompt below. Use their context to inform the team brief in Step 8, where their original words will be preserved.

**If the User-Provided Context section above is empty**, use the **AskUserQuestion** tool:

- question: "Do you have outcomes defined, or would you like help?"
- header: "Outcomes"
- options:
  - label: "I'll provide my outcomes (Recommended)"
    description: "I know what success looks like and will describe it"
  - label: "Help me define outcomes"
    description: "Use /swarm:refine-outcomes to reframe my ideas into outcome statements"

**If "I'll provide my outcomes"**: Ask the user (as a regular text message) to describe their outcomes — what success looks like, not implementation steps. Wait for their response. Then present their outcomes back using their exact words — do NOT paraphrase, summarize, or reword, even if conversational in tone.

**If "Help me define outcomes"**: You MUST use the **Skill** tool to invoke `swarm:refine-outcomes`, passing the user's context as the `args` parameter. Do NOT perform this step yourself.

Once outcomes are stated, use **AskUserQuestion** to confirm:

- question: "Are these outcomes right?"
- header: "Outcomes"
- options:
  - label: "Yes, move on"
    description: "These capture what I'm trying to achieve"
  - label: "I want to adjust"
    description: "Let me refine or add to these"
  - label: "Help me refine these into outcomes"
    description: "Reframe what I described into outcome statements"

**If "Help me refine these into outcomes"**: You MUST use the **Skill** tool to invoke `swarm:refine-outcomes`, passing the user's stated outcomes as the `args` parameter. Do NOT perform this step yourself. After refinement, preserve the user's original words alongside the refined outcomes — the team needs both to fill in gaps. Return to this confirmation prompt.

**Verbatim capture rule (mandatory).** The user's original words are the PRIMARY reference for all downstream team briefings. Capture them verbatim and store as a literal string for Step 8c and 8d substitution. If the user invokes `swarm:refine-outcomes`, the skill MUST return both the refined outcomes AND preserve the user's verbatim original. The refined outcomes NEVER replace the verbatim; they supplement it. Both flow to Step 8 as separate blocks. Any deviation between the user's exact words and what appears in team briefs is a hard rules violation.

**After outcomes are confirmed**, use the **AskUserQuestion** tool:

- question: "How would you like to set up the team?"
- header: "Setup"
- options:
  - label: "Use defaults (Recommended)"
    description: "Auto-configure mode, team, shape, and research — review before launch"
  - label: "Configure each step"
    description: "Choose mode, team members, shape, and research individually"

**If "Use defaults"**: Apply these defaults silently (do NOT ask each question):
1. **Mode**: Infer from outcomes (Writing/Code/General per Step 3 rules). If genuinely ambiguous, ask just this one question using Step 3's AskUserQuestion. Once answered, immediately invoke suggest-members and proceed to Step 7 in the same response — do not pause again.
2. **Team**: Invoke `swarm:suggest-members` with the inferred mode and outcomes.
3. **Shape**: Balanced.
4. **Lead research**: No.

Then, in the same response — without pausing or waiting for user input — skip to **Step 7 (Confirmation)** and present the full summary with AskUserQuestion. The user reviews everything and can adjust before launch.

**If "Configure each step"**: Proceed to Step 3 and follow Steps 3–6 in order, then Step 7.

**STOP HERE. Wait for the user's selection.**

---

## Step 3: Select Mode

Infer the mode from the user's stated outcomes — whether they came from `$ARGUMENTS` or from the Step 2 Q&A:
- Writing outcomes (articles, blog posts, essays, documentation, copy, narrative) → **Writing**
- Engineering or code outcomes (building, fixing, refactoring, debugging software) → **Code**
- Clearly neither (research synthesis, vendor evaluation, planning, analysis) → **General**
- Genuinely ambiguous → ask without pre-selecting

**If inference is clear**, use **AskUserQuestion** to confirm:

- question: "This looks like [Writing / Code / General] work — is that right?"
- header: "Mode"
- options:
  - label: "Yes, [inferred mode]"
    description: "[one-line description of that mode]"
  - label: "No, let me choose"
    description: "Show me the mode options"

**If "Yes"**: store the inferred mode and proceed to Step 4.
**If "No"** or **if ambiguous**: use **AskUserQuestion**:

- question: "What kind of work is this?"
- header: "Mode"
- options:
  - label: "Code"
    description: "Building, fixing, or refactoring software"
  - label: "Writing"
    description: "Articles, essays, documentation, or other prose"
  - label: "General"
    description: "Work that doesn't fit a specific mode"

Store the selected mode. It informs: suggest-members guidance in Step 4, and the phase arc and team identity in Step 8.

**STOP HERE. Wait for the user's selection before proceeding to Step 4.**

---

## Step 4: Ask About Team Members

Use the **AskUserQuestion** tool:

- question: "How would you like to choose team members? (Lead and Principal Engineer are always included)"
- header: "Team"
- options:
  - label: "Suggest a team for me (Recommended)"
    description: "Use /swarm:suggest-members to recommend roles based on my outcomes"
  - label: "I'll specify the team"
    description: "I know which roles or focus areas I want"

**If "I'll specify the team"**: Ask the user (as a regular text message) to describe the additional members they want — by role (e.g., "security reviewer, test engineer") or by focus area (e.g., "two agents focused on API design"). Advisory: 3-5 total members is the sweet spot, up to 8 is viable. Wait for their response. Present the team composition based on their input, then immediately use **AskUserQuestion**:

- question: "Does this team look right?"
- header: "Team"
- options:
  - label: "Yes, looks good"
    description: "Proceed with this team composition"
  - label: "I want to adjust"
    description: "Let me add, remove, or change members"

If adjusting, ask what they'd like to change (free text), apply changes, then confirm again with AskUserQuestion.

**If "Suggest a team for me"**: You MUST use the **Skill** tool to invoke `swarm:suggest-members`, passing the confirmed outcomes from Step 2 AND the selected mode from Step 3 as the `args` parameter (e.g., "Mode: Writing\n\n[outcomes]"). Do NOT perform this step yourself. Immediately after the skill returns, use **AskUserQuestion** in the same response — do NOT wait for user input first:

- question: "Does this team look right?"
- header: "Team"
- options:
  - label: "Yes, looks good"
    description: "Proceed with this team composition"
  - label: "I want to adjust"
    description: "Let me add, remove, or change members"

If adjusting, ask what they'd like to change (free text), apply changes, then confirm again with AskUserQuestion.

**STOP HERE. Wait for the team composition to be confirmed before proceeding to Step 5.**

---

## Step 5: Ask About Team Shape

Use the **AskUserQuestion** tool:

- question: "Which team shape?"
- header: "Shape"
- options:
  - label: "Balanced (Recommended)"
    description: "Full team, strong quality at lower cost. Good for well-scoped work."
  - label: "Ultra"
    description: "Maximum depth on every decision. For hard problems and novel architecture."

Store the selection. Step 8 uses it for the spawn-time `model` field. Default: Balanced.

**STOP HERE. Wait for the user's selection before proceeding to Step 6.**

---

## Step 6: Ask About Lead Research

Use the **AskUserQuestion** tool:

- question: "Should the team lead be able to do research?"
- header: "Research"
- options:
  - label: "No (Recommended)"
    description: "Lead focuses on coordination — teammates handle research"
  - label: "Yes"
    description: "Lead can delegate research to Explore subagents in addition to teammates"

**STOP HERE. Wait for the user's selection before proceeding to Step 7.**

---

## Step 7: Confirmation

Present a summary of the team plan:

> **Team Plan**
>
> **Mode:** [Code / Writing / General]
>
> **Outcomes:**
> [list each confirmed outcome numbered — use the exact confirmed wording, do NOT paraphrase]
>
> **User's original context:**
> [if outcomes were refined via the refine-outcomes skill, include the user's original words here — otherwise omit this section]
>
> **Team:**
> 1. Team lead — (main session) [research: yes/no]
> 2. [PE title from mode file] — Socratic facilitator, read-only
> [3-N. Additional members — personality and behavioral identity, not task assignments or focus areas]
>
> **Team shape:** [Balanced / Ultra — the selection from Step 5]
>
> **Rules:** Active

Then use the **AskUserQuestion** tool:

- question: "Is this plan final, or do you have remaining inputs?"
- header: "Confirm"
- options:
  - label: "Launch the team"
    description: "Plan is final — start creating the team now"
  - label: "I have changes"
    description: "Let me adjust outcomes, members, or settings first"

**If "Launch the team"**: Proceed to Step 8.

**If "I have changes"**: Ask what they'd like to change (free text). Apply the change using the relevant step definition (Steps 3–6), then re-present this confirmation summary. Repeat until the user launches.

**STOP HERE. Do NOT proceed until the user explicitly confirms.**

---

## Step 8: Launch the Team

Once the user confirms, execute the following:

### 8a: Create the team

Use **TeamCreate** with a descriptive team name derived from the outcomes. For example, if the outcome is "Build a REST API for user management," use team name `user-management-api`.

### 8b: You ARE the team lead

You MUST use the **Skill** tool to invoke `swarm:[selected_mode]-mode` — use the lowercase mode name (e.g., `swarm:code-mode`, `swarm:writing-mode`, `swarm:general-mode`). The skill returns your operational spec for the rest of this team run. It defines:
- Your **lead identity** (paste into the Step 8c PE brief's identity line and apply to your own role)
- The **PE identity line** (use in the Step 8c brief in place of the default code-mode identity)
- **Mode-specific rules** (these extend the Step 1 hard rules — treat them as equally binding)
- The **phase arc** for Step 8f

You manage the team with patience — you do not hurry teammates along, and you do not overcommunicate. Make sure the hard rules and mode-specific rules aren't violated.

If the user enabled lead research: you may use the Agent tool with `subagent_type: "Explore"` for research tasks. If not: delegate all research to team members.

### 8c: Spawn the [PE title]

Use the **Agent** tool to spawn the first teammate:
- `name`: [kebab-case of PE title from mode file, e.g. `principal-engineer`, `editorial-director`, `chief-of-staff`]
- `team_name`: [the team name from 8a]
- `model`: `opus` (both Ultra and Balanced — this role is always Opus, because it owns judgment review)

Brief by pasting this template EXACTLY, filling [brackets], and sending it. Do NOT expand. Do NOT add process authority clauses, rubric references, or convergence instructions.

```
[PE title from mode file] — upbeat, socratic thinker, leads by asking questions, doesn't make decisions, ensures a healthy discussion that adheres to the hard rules, [paste the PE identity line from the mode file].

The user's request, verbatim:

> [paste the user's original $ARGUMENTS or Step 2 input — full text, unmodified]

Hard rules:
[paste the full Step 1 general rules block verbatim]

Your only channel to the team is the SendMessage tool. Plain text output is not visible to teammates — it dies with your turn. Every contribution — findings, questions, reviews, disagreements — must be sent via SendMessage. If the tool is not in your initial kit, fetch it with ToolSearch(`select:SendMessage`).

Team composition:
[paste the Step 7 approved roster]
```

### 8d: Spawn additional team members

For each additional member in the Step 7 confirmed roster, use the **Agent** tool:
- `name`: A descriptive kebab-case name (e.g., `security-reviewer`, `test-engineer`)
- `team_name`: [the team name from 8a]
- `model`: `opus` if Ultra, `sonnet` if Balanced

Brief each member by pasting this template EXACTLY, filling [brackets], and sending it. The template is a literal copy-paste structure with substitution points. Do NOT add sections beyond the fields specified.

```
[name] — [identity from Step 7 approved roster — personality, behavioral style, and domain lens are good; task assignments, focus areas, and "focused on X" are not]

The user's request, verbatim:

> [paste the user's original $ARGUMENTS or Step 2 input — full text, unmodified, as a quoted block]

[If outcomes were refined via swarm:refine-outcomes, add: "Refined outcomes (supplementary reference): [paste refined outcomes]" — but the verbatim block above remains primary]

Hard rules:
[paste the full Step 1 general rules block verbatim]

Your only channel to the team is the SendMessage tool. Plain text output is not visible to teammates — it dies with your turn. Every contribution — findings, questions, reviews, disagreements — must be sent via SendMessage. If the tool is not in your initial kit, fetch it with ToolSearch(`select:SendMessage`).

Team composition:
[paste the Step 7 approved roster]

Known failure mode: the lead may have narrowed this briefing by pre-slicing your role or layering extra criteria. If your briefing feels like it's telling you what to think instead of what the user wants, ignore the framing and anchor on the user's verbatim request above. You share ownership of the whole outcome, not a slice of it.
```

Do not add any sections, headings, or content beyond the fields in this template. The user's verbatim request and the member's own expertise guide their investigation — not lead-authored framing.

### 8e: Set up the pulse

After spawning all team members, create a heartbeat that prevents the lead from stalling. Use **CronCreate** with:
- **cron**: `3,23,43 * * * *` (every ~20 minutes, offset from round marks)
- **prompt**: "Pulse: check your state. If you asked the user a question, evaluate whether you genuinely need their answer to proceed — if not, continue without it. If idle with no pending decisions, advance to your next phase. Only wait when you need a decision not covered by the approved plan. Do not narrate or acknowledge this pulse."
- **recurring**: true
- **durable**: false

The pulse fires only when the REPL is idle — it will not interrupt active work. If the lead is progressing normally, it should not narrate or acknowledge the pulse.

### 8f: Begin work

Follow the **phase arc defined in the mode file** you read in Step 8b. The mode file specifies what each phase means — who acts, what the deliverable is, how transitions work.

**Universal rules that apply across all modes:**
- Lead does no research unless the user explicitly enabled it in Step 6
- Questions the team cannot resolve internally go to the user via AskUserQuestion — most consequential first, one at a time, using options when the answer is one of a small known set
- Post-greenlight execution is autonomous — escalate only per the hard rules (tiebreaker, scope change, convergence failure, uncovered decision)
- When an explicit shutdown request has been received, delete the pulse cron job using CronDelete after the team has been shut down
