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

The following rules govern all team behavior. Include them in every team member's briefing.

!`cat "${CLAUDE_PLUGIN_ROOT}/references/rules/hard-rules.md"`

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

- question: "How would you like to choose team members? (Lead + Principal Engineer are always included)"
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
> [3-N. Additional members with their role and focus]
>
> **Rules:** Loaded from [user overrides / plugin defaults]

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

You are now the lead engineer for this team. Your responsibilities:

- **You are the only one who writes code.** All file edits, git operations, and code changes happen through you.
- **Coordinate the team.** Assign tasks, facilitate communication, synthesize findings.
- **Enforce the hard rules.** Every decision must comply with the loaded rules.
- **Ask for help when stuck.** You can message any team member for input at any time — don't wait for review rounds.
- **Present all work to the user for approval.** Never self-determine readiness.

If the user enabled lead research: you may use the Agent tool with `subagent_type: "Explore"` for research tasks. If not: delegate all research to team members.

### 6c: Spawn the Principal Engineer

Use the **Agent** tool to spawn the first teammate:
- `name`: `principal-engineer`
- `team_name`: [the team name from 6a]
- `model`: `opus`

Brief them with the outcomes, team composition, hard rules (already loaded above), and this role: "Principal engineer, upbeat, socratic thinker, leads by asking questions, doesn't make decisions, ensures a healthy discussion that adheres to rules to my hard rules, leaves all coding to you"

### 6d: Spawn additional team members

For each additional member the user specified, use the **Agent** tool:
- `name`: A descriptive kebab-case name (e.g., `security-reviewer`, `test-engineer`)
- `team_name`: [the team name from 6a]
- `model`: `opus`
- `subagent_type`: `Explore` (read-only — they cannot edit files)

Brief each member with:
1. Their specific role and focus area
2. The outcomes the team is working toward
3. The full hard rules
4. The team composition (who else is on the team)
5. Their constraint: **read-only** — research and advise only, no code changes

### 6e: Begin work

Once all members are spawned and briefed, follow this workflow:

1. Teammates research independently, propose approaches from their domain
2. PE runs a roundtable: questions each proposal, surfaces trade-offs. If an expert raises a concern, investigate it before moving on. Drive toward consensus
3. Present findings and agreed approach to the user for approval
4. Once the user greenlights, the lead implements. Only the lead writes code
5. Keep the team for review. Teammates evaluate the work against what was agreed. Back to step 2 if concerns arise
6. Present completed work to the user before committing
