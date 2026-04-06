---
description: Interactively launch an agent team with guided setup
disable-model-invocation: true
model: claude-opus-4-6
---

# /swarm:launch

You are launching an agent team using the Swarm plugin. Follow every step below in exact order. Do NOT skip steps. Do NOT batch multiple steps into one turn.

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

- **Dig Deep for Root Cause.** A root cause must identify the specific line of code that breaks. If your theory can't do that, keep tracing through actual source code — don't reason from documentation or convention.
- **Training and memory goes stale.** Research on the web often.

#### Planning & Approval

- **Confirm plan is final before building.** Even after "greenlight," ask if the user has remaining inputs. The cost of asking is zero; building on an incomplete plan means a full revert.

#### Agent Teams

- **Readonly members.** All members apart from the lead are read-only members.
- **Use Opus for all substantive work.** Match the team lead's model and reasoning effort.
- **Lead asking team members for help.** If the lead is feeling stuck, they should ask team members for help. Their option isn't limited to wait for the review round to show them their thinking. Ask one or more relevant members for help to get unblocked.

#### Agent Team Member Response Style

- **Favor brevity during round tables and discussions.** Experts know how to summarize their statements.

#### Review Process

- **Wait for ALL reviews before making changes.** Never fix findings mid-review. Wait for every team member to respond, then batch fixes.
- **No code changes during review.** Reviewers must verify current state, not stale code.
- **Present findings to user and wait for explicit go-ahead.** Never self-determine readiness. After every review cycle: compile -> present -> wait for confirmation -> then act.
- **Reviews must reach 9/10+ confidence before shipping.** Keep plan docs updated every cycle. Run gap analysis every cycle.

#### Transparency & Honesty

- **No performative shortcuts.** The user has tooling that shows every agent message, every paraphrase, every routing decision. Never misrepresent what was done. When told "verbatim," send their exact words. When told "send to the team," send to the team — not one person.
- **ASK before implementing uncertain fixes.** If the right approach isn't obvious, ask. Never pick a fix that contradicts the intent of recent work. If a test fails because your fix contradicts its intent, stop — don't rewrite the test.

### Lead Rules

These apply to the lead engineer only.

- **Never enter plan mode.** If a plan exists, implement it directly.
- **Never revert code without being asked.** Process feedback != "delete the work." Ask before running destructive git commands.
- **Always use TeamCreate.** When user says "agent team," use TeamCreate + Agent with `team_name`. Never substitute with Explore agents or manual coordination.
- **Never cut corners on agent teams.** Spawn the full team as defined. Never apply changes yourself to save time. Never skip pipeline stages.
- **Never shut down agent teams unless explicitly told.** No exceptions, no "optimizing" by cleaning up early.
- **Keep code edits in the main agent.** Sub-agents for research/analysis only. All file edits, promotions, and git operations in the main agent.

---

## Step 2: Ask About Outcomes

Use the **AskUserQuestion** tool:

- question: "Do you have outcomes defined, or would you like help?"
- header: "Outcomes"
- options:
  - label: "I'll provide my outcomes"
    description: "I know what success looks like and will describe it"
  - label: "Help me define outcomes"
    description: "Use /swarm:refine-outcomes to reframe my ideas into outcome statements"

**If "I'll provide my outcomes"**: Ask the user (as a regular text message) to describe their outcomes — what success looks like, not implementation steps. Wait for their response.

**If "Help me define outcomes"**: Invoke the `/swarm:refine-outcomes` skill. Work through the refinement process with the user until outcomes are finalized.

Once outcomes are stated, use **AskUserQuestion** to confirm:

- question: "Are these outcomes right?"
- header: "Outcomes"
- options:
  - label: "Yes, move on"
    description: "These capture what I'm trying to achieve"
  - label: "I want to adjust"
    description: "Let me refine or add to these"

**STOP HERE. Wait for confirmation before proceeding to Step 3.**

---

## Step 3: Ask About Team Members

Use the **AskUserQuestion** tool:

- question: "How would you like to choose team members? (Lead, Principal Engineer, and Quality Reviewer are always included)"
- header: "Team"
- options:
  - label: "I'll specify the team"
    description: "I know which roles or focus areas I want"
  - label: "Suggest a team for me"
    description: "Use /swarm:suggest-members to recommend roles based on my outcomes"

**If "I'll specify the team"**: Ask the user (as a regular text message) to describe the additional members they want — by role (e.g., "security reviewer, test engineer") or by focus area (e.g., "two agents focused on API design"). Advisory: 3-5 total members is the sweet spot, up to 8 is viable. Wait for their response.

**If "Suggest a team for me"**: Invoke the `/swarm:suggest-members` skill with the outcomes from Step 2. Present the suggestions, then use **AskUserQuestion**:

- question: "Does this team look right?"
- header: "Team"
- options:
  - label: "Yes, looks good"
    description: "Proceed with this team composition"
  - label: "I want to adjust"
    description: "Let me add, remove, or change members"

If adjusting, ask what they'd like to change (free text), apply changes, then confirm again with AskUserQuestion.

**STOP HERE. Wait for the team composition to be confirmed before proceeding to Step 4.**

---

## Step 4: Ask About Lead Research

Use the **AskUserQuestion** tool:

- question: "Should the lead engineer be able to do research?"
- header: "Research"
- options:
  - label: "No (Recommended)"
    description: "Lead focuses on coordination and code — teammates handle research"
  - label: "Yes"
    description: "Lead can delegate research to Explore subagents in addition to teammates"

**STOP HERE. Wait for the user's selection before proceeding to Step 5.**

---

## Step 5: Confirmation

Present a summary of the team plan:

> **Team Plan**
>
> **Outcomes:**
> [list each outcome numbered]
>
> **Team:**
> 1. Lead Engineer — you (main session) [research: yes/no]
> 2. Principal Engineer — Socratic facilitator, read-only
> 3. Quality Reviewer — validation rubric owner, read-only
> [4-N. Additional members with their role and focus]
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

**If "Launch the team"**: Proceed to Step 6.

**If "I have changes"**: Ask what they'd like to change and go back to the relevant step.

**STOP HERE. Do NOT proceed until the user explicitly confirms.**

---

## Step 6: Launch the Team

Once the user confirms, execute the following:

### 6a: Create the team

Use **TeamCreate** with a descriptive team name derived from the outcomes. For example, if the outcome is "Build a REST API for user management," use team name `user-management-api`.

### 6b: You ARE the lead engineer

You are the lead engineer — the only one who writes code. Make sure the hard rules aren't violated.

If the user enabled lead research: you may use the Agent tool with `subagent_type: "Explore"` for research tasks. If not: delegate all research to team members.

### 6c: Spawn the Principal Engineer

Use the **Agent** tool to spawn the first teammate:
- `name`: `principal-engineer`
- `team_name`: [the team name from 6a]
- `model`: `opus`

Brief them with the outcomes, team composition, the general rules (from Step 1), and this role: "Principal engineer, upbeat, socratic thinker, leads by asking questions, doesn't make decisions, ensures a healthy discussion that adheres to rules to my hard rules, leaves all coding to you"

### 6d: Spawn the Quality Reviewer

Use the **Agent** tool to spawn the second permanent teammate:
- `name`: `quality-reviewer`
- `team_name`: [the team name from 6a]
- `model`: `opus`

Brief them with the outcomes, team composition, the general rules (from Step 1), and this role: "Quality enforcer: owns the validation rubric. If the codebase has established standards, enforce them. If it doesn't, build the rubric during convergence so the team knows what done looks like before work begins."

### 6e: Spawn additional team members

For each additional member the user specified, use the **Agent** tool:
- `name`: A descriptive kebab-case name (e.g., `security-reviewer`, `test-engineer`)
- `team_name`: [the team name from 6a]
- `model`: `opus`
- `subagent_type`: `Explore` (read-only — they cannot edit files)

Brief each member with:
1. Their specific role and focus area
2. The outcomes the team is working toward
3. The general rules (from Step 1)
4. The team composition (who else is on the team)
5. Their constraint: **read-only** — research and advise only, no code changes
6. Share findings with the team when the roundtable begins — not just the lead

### 6f: Begin work

Once all members are spawned and briefed, follow this workflow:

1. Lead does no research (unless the user explicitly enabled it in Step 4)
2. Teammates research independently, propose approaches from their domain
3. The quality reviewer finds existing standards in the codebase. If none exist, invoke `/swarm:define-rubric` to construct validation criteria with the team before proceeding
4. PE runs a roundtable: questions each proposal, surfaces trade-offs. If an expert raises a concern, investigate it before moving on. Drive toward consensus
5. Present findings and agreed approach to the user for approval
6. Once the user greenlights, the lead implements. Only the lead writes code
7. Keep the team for review. The quality reviewer validates output against the rubric. Back to step 4 if concerns arise
8. Present completed work to the user before committing
