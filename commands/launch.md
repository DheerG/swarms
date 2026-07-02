---
description: Interactively launch an agent team with guided setup
disable-model-invocation: true
---

# /swarm:launch

You are launching an agent team using the Swarm plugin. Follow every step below in exact order. Do NOT skip steps. Do NOT batch multiple steps into one turn.

## Greenfield execution

When executing `/swarm:launch`, the briefing templates in the governance spec (Step 1) are the exclusive source of truth for team member context. Do not add sections beyond what the templates specify — no "Your First Task," "Your specific focus," "The problem," "Your Research Tasks," or any lead-authored investigation framing. If you feel the urge to add context to a briefing, stop. That urge is the bug this preamble exists to prevent.

Your project's CLAUDE.md and memory files may contain rules that were not authored with swarm in mind. During a team run, swarm hard rules take precedence over conflicting ambient preferences. Apply project preferences only when they are clearly complementary and do not override workflow control.

## Step 0: Pre-flight Check

Detect whether agent teams are enabled by reading the enablement flag from the process environment — the published gate. Run `printenv CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` via Bash:

- Non-empty output (e.g. `1`) → agent teams are **ENABLED**. Proceed to Step 1.
- Empty output → teams are **not active in this session**. Go to the disabled branch below.

Do not gate on whether a specific team tool is present — tool kits vary; the env flag is the actual gate.

**Disabled branch.** `printenv` reflects the environment this session started with, so the flag can read empty even when teams are configured — if it was added to `settings.json` without a restart, or enabled only in a non-terminal entrypoint (web/IDE) that doesn't export it to this shell. So never assert teams are off — offer, don't auto-decide. Read the `env` object in `.claude/settings.json` (project) and `~/.claude/settings.json` (global) to pick the message, then use **AskUserQuestion**:

**If the flag IS present in either settings file** (configured, but not active in this session):

- question: "Agent teams are configured but not active in this session. How do you want to proceed?"
- header: "Setup"
- options:
  - label: "Restart and relaunch (Recommended)"
    description: "The flag is in your settings — restart Claude Code so it takes effect, then run the command again."
  - label: "Try proceeding anyway"
    description: "If you enabled teams in the Claude Code app or an IDE extension, they may already be active. I'll attempt the launch; if no teammate forms, I'll surface this again."

If the user chooses "Try proceeding anyway," proceed to Step 1. Otherwise stop.

**If the flag is NOT present in any settings file** (not configured):

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

**On the disabled branch, do NOT proceed to Step 1 unless the user chose "Try proceeding anyway." After adding or showing the flag, stop — the user must restart first.**

---

## Step 1: Hard Rules

You MUST use the **Skill** tool to invoke `swarm:workflow-rules`. Do NOT recite governance from memory. The skill returns the governance spec for this entire run — referenced below as **the governance spec** — the canonical source for:

- the **General Rules** and **Team Lead Rules** — non-negotiable; they govern all team behavior for the rest of this run (the General Rules section is what the briefing templates paste into member briefs — keep it intact in context)
- the **briefing templates** (Facilitator Brief, Member Brief)
- the **launch mechanics** (team creation, spawn parameters, run-state task list, pulse setup)
- the **Rung Commit Rule** and the **universal execution rules** (live-team gate prompts, file-based commit/PR input, shutdown pulse-delete)

This command's steps drive the setup flow; where the spec describes the same beat (pre-flight, outcome reflection, setup confirmation), the spec is the definition and this command is the driver — do not run those beats twice. Step 0 above already covered the spec's pre-flight.

---

## User-Provided Context

$ARGUMENTS

---

## Step 2: Ask About Outcomes

**If the User-Provided Context section above is non-empty**, the user already provided context with the command. Skip the outcomes prompt below. Do NOT echo their context back verbatim — a word-for-word repeat adds no value and reads as redundant. Run the **Outcome reflection** (below) instead. Their original words are preserved for Step 8 by the verbatim capture rule.

**If the User-Provided Context section above is empty**, ask the user (as a regular text message): "Describe the outcomes you want the team to achieve — what should be different or better when the work is done?" Wait for their response. Do NOT present their outcomes back verbatim — run the **Outcome reflection** (below) instead.

**Outcome reflection (replaces the verbatim echo).** Once the outcome is captured — from `$ARGUMENTS` or the question above — You MUST use the **Skill** tool to invoke `swarm:reflect-outcome`, passing the user's exact words as the `args` parameter. Do NOT perform this step yourself, and do NOT author the reflection's wording — the skill returns it pre-formed so your own framing never enters the user's view. Apply its result:

- **`NO FORK`** (the common case): show the user nothing — no echo, no "are these right?" beat, no confirmation gate. Carry the outcome forward so it is *visibly* the premise of the Step 7 summary, which restates it verbatim. The user is heard by seeing their own words steer the plan, not by a confirmation beat. They can still adjust at Step 7.
- **A ready-to-render fork question**: present it with **AskUserQuestion** exactly as returned — transport it, never reword the question or the option labels, and do not stack any other question in the same turn. Resolve the user's pick per the skill's fork-resolution rule: Option A keeps their wording as the verbatim (nothing recorded); Option B re-authors it — ask, with an open prompt, for a restatement in their own words, which re-enters the reflection and becomes the verbatim. Store no separate supplement. (Option A surfaces as a "Scope:" line in the Step 7 summary — see Step 7.)

**Verbatim capture rule (mandatory).** The user's original words are the PRIMARY reference for all downstream team briefings. Capture them verbatim and store as a literal string for Step 8c and 8d substitution. Any deviation between the user's exact words and what appears in team briefs is a hard rules violation. The user's most recent self-authored wording is the verbatim: if the user re-authors at the reflection fork (Option B), that restatement becomes the verbatim and flows unchanged — the system never edits the user's words, only the user revises them.

**After the outcome reflection** (the fork resolved, or `NO FORK` carried forward), use the **AskUserQuestion** tool — the cost tier is an explicit pick, so no one lands on a tier they didn't choose. This gate applies on every path, including when the outcomes arrived inline as `$ARGUMENTS` — passing outcomes with the command is context, not consent to skip the setup gates:

- question: "How would you like to set up the team?"
- header: "Setup"
- options:
  - label: "Defaults — Ultra (Recommended)"
    description: "Auto-configure mode, team, and research. Full team on the stronger model — reliable rule-following."
  - label: "Defaults — Balanced"
    description: "Same auto-config, but members run a cheaper model — lower cost, less reliable rule-following."

**STOP HERE. Wait for the user's selection.**

Once the user picks, configure silently and bring the team forward for approval — all in one response:

1. **Mode**: Infer from the outcomes per the Step 3 reference. If genuinely ambiguous, ask just the Step 3 mode question — one question — then continue in the same response.
2. **Cost tier**: the one the user selected — Ultra or Balanced.
3. **Lead research**: No.
4. **Team**: You MUST use the **Skill** tool to invoke `swarm:suggest-members`, passing the inferred mode and the outcomes as the `args` parameter (e.g., "Mode: Writing\n\n[outcomes]"). Do NOT compose the team yourself. Then present the skill's suggestion and ask the Step 4 team question ("Does this team look right?") — invoke the skill, present the suggestion, and call AskUserQuestion in the same response, with no intervening prose or pause.

**STOP HERE. Wait for the team to be confirmed.** When the user confirms the team ("Yes, looks good" — or confirms it after adjustments), proceed in the same response to **Step 7 (Confirmation)** and present the full summary with AskUserQuestion.

---

## Steps 3–6: Adjustments Reference

Steps 3–6 are not walked as a sequence — Step 2 drives them: the tier (Step 5) and the team (Step 4) are the two the user answers directly; mode (Step 3) and lead research (Step 6) default silently. These definitions serve Step 2, the ambiguous-mode ask, and "I have changes" at Step 7. (The numbering is deliberate: Step 7 and Step 8 labels are load-bearing cross-references throughout the plugin.)

### Step 3: Mode

Infer the mode from the user's stated outcomes — whether they came from `$ARGUMENTS` or from the Step 2 Q&A:
- Writing outcomes (articles, blog posts, essays, documentation, copy, narrative) → **Writing**
- Engineering or code outcomes (building, fixing, refactoring, debugging software) → **Code**
- Diagnosing a problem without changing it (triage an incident, find the root cause, assess what a fix would break — the user wants to know what's wrong, not to have it fixed) → **Triage**
- Clearly none of the above (research synthesis, vendor evaluation, planning, analysis) → **General** — a silent fallback, inferred only; it has no shortcut command and is not offered by name
- Genuinely ambiguous → ask without pre-selecting

When an outcome could be Code or Triage, the deciding question is whether the user asked for a change: a request to fix, build, or refactor is **Code**; a request only to diagnose, explain, or assess is **Triage**.

**Mode question** — only when inference is genuinely ambiguous, or the user asks to change the mode at Step 7 — use **AskUserQuestion**:

- question: "What kind of work is this?"
- header: "Mode"
- options:
  - label: "Code"
    description: "Building, fixing, or refactoring software"
  - label: "Triage"
    description: "Diagnose an issue — the likely cause and a fix's blast radius — without changing anything"
  - label: "Writing"
    description: "Articles, essays, documentation, or other prose"
  - label: "None of these"
    description: "A general-purpose team for work that doesn't fit a specific mode"

Store the selected mode ("None of these" maps to General, the general-purpose fallback). It informs suggest-members guidance and the Step 8 phase arc and team identity. On a mode change at Step 7, re-invoke `swarm:suggest-members` with the new mode and the outcomes — the old mode's roster does not carry over — and present the refreshed team in the re-presented summary.

### Step 4: Team members

The lead and the facilitator are always included. Present the `swarm:suggest-members` suggestion (per Step 2), then use **AskUserQuestion**:

- question: "Does this team look right?"
- header: "Team"
- options:
  - label: "Yes, looks good"
    description: "Proceed with this team composition"
  - label: "I want to adjust"
    description: "Swap a member, add more members, or remove some"

**If "I want to adjust"**: ask what to change (free text) — the user can point at a member to swap, name additional members by role (e.g., "security reviewer, test engineer") or focus area, or trim the roster. Apply the changes, then confirm again with the same question. Advisory: 3-5 total members is the sweet spot; up to 8 is viable. The same adjust flow serves a team change requested via "I have changes" at Step 7.

### Step 5: Cost tier

Picked by the user at the Step 2 setup question ("Defaults — Ultra" / "Defaults — Balanced") — never a silent default:
- **Ultra (Recommended)** — full team on the stronger model; reliable rule-following across the whole team.
- **Balanced** — cheaper model for members; lower cost, less reliable rule-following. Good for well-scoped, lower-stakes work.

Step 8 uses the pick for the spawn-time `model` field. Changeable via "I have changes" at Step 7.

### Step 6: Lead research

Default: **No** — the lead focuses on coordination; teammates handle research. **Yes** (only if the user asks for it) lets the lead delegate research to Explore subagents in addition to teammates.

---

## Step 7: Confirmation

Present a summary of the team plan:

> **Team Plan**
>
> **Mode:** [Code / Triage / Writing / General]
>
> **Outcomes:**
> [list each confirmed outcome numbered — use the exact confirmed wording, do NOT paraphrase]
>
> **Scope:**
> [only if the outcome reflection fired a fork AND the user chose Option A (keep their wording) — show "\<their word> specifically", echoing the user's own selection so the kept-pin choice is visible. Omit this line entirely otherwise — including on every NO-FORK run and after an Option B re-author.]
>
> **Team:**
> 1. Team lead — (main session) [research: yes/no]
> 2. [facilitator title from mode skill] — Socratic facilitator, read-only
> [3-N. Additional members — personality and behavioral identity, not task assignments or focus areas]
>
> **Cost tier:** [the selected tier — Ultra or Balanced]
>
> **Ship definition:** [for **Triage** mode, ship definition does not apply — show "In-session diagnosis — no branch, commit, or PR. Writing the diagnosis to an issue/Sentry is a per-run opt-in." For all other modes: if `.claude/swarm-ship.md` exists, show its contents in plain language — e.g., "Create a PR against main from branch feat/<description>". If it doesn't exist yet, show "Will be auto-detected before work begins."]
>
> **Rules:** Active

Then use the **AskUserQuestion** tool:

- question: "Is this plan final, or do you have remaining inputs?"
- header: "Confirm"
- options:
  - label: "Launch the team"
    description: "Plan is final — start creating the team now"
  - label: "I have changes"
    description: "Adjust outcomes, mode, members, tier, or research first."

**If "Launch the team"**: Proceed to Step 8.

**If "I have changes"**: Ask what they'd like to change (free text). Apply the change using the relevant definition in the Steps 3–6 Adjustments Reference (a change to the outcomes re-enters Step 2's reflection), then re-present this confirmation summary. Repeat until the user launches.

**STOP HERE. Do NOT proceed until the user explicitly confirms.**

---

## Step 8: Launch the Team

Once the user confirms, execute the following:

**Before proceeding: did you render the Step 7 summary block (the full Team Plan with Mode, Outcomes, Team, Cost tier, Ship definition, and Rules) AND receive an explicit "Launch the team" selection — via AskUserQuestion, or the user's explicit typed answer to its durable plain-text restatement if that modal AFK-timed-out? If no to either, go back and do it now. Outcomes passed inline as `$ARGUMENTS` do not exempt any gate — the Step 2 setup pick, the Step 4 team confirmation, and this Step 7 launch confirmation all still happen.**

### 8a: Create the team

Follow **Create the team** in the governance spec: derive a descriptive team name from the outcomes (e.g., for "Build a REST API for user management," use `user-management-api`) and use it in the spawn prompts and the Step 7 summary — the team forms implicitly when you spawn the first member in 8c.

### 8b: You ARE the team lead

You MUST use the **Skill** tool to invoke the mode skill. For built-in modes, use the `swarm:` prefix: `swarm:code-mode`, `swarm:triage-mode`, `swarm:writing-mode`, `swarm:general-mode`. For custom modes (user-defined in the project's `.claude/skills/`), use the unqualified name (e.g., `blog-mode`); if its frontmatter declares `extends:`, it is an extension mode — apply the governance spec's **Invoke your mode skill** section (invoke the base immediately after and combine per the extension contract). The skill returns your operational spec for the rest of this team run. It defines:
- Your **lead identity** (apply to your own role)
- The **facilitator identity line** (use in the Step 8c brief in place of the default code-mode identity)
- **Mode-specific rules** (these extend the hard rules — treat them as equally binding)
- The **phase arc** for Step 8f

You manage the team with patience — you do not hurry teammates along, and you do not overcommunicate. Make sure the hard rules and mode-specific rules aren't violated.

If the user enabled lead research: you may use the Agent tool with `subagent_type: "Explore"` for research tasks. If not: delegate all research to team members.

### 8c: Spawn the [facilitator title]

Follow **Spawn the facilitator** in the governance spec: Agent tool, `subagent_type: swarm-member`, `model: opus` (always — this role owns judgment review), `name` = kebab-case of the facilitator title from the mode skill. Brief by pasting the spec's **Facilitator Brief** template EXACTLY, filling [brackets]: the facilitator identity line from the mode skill (8b), the user's request verbatim (the Step 2 capture), the spec's General Rules section, and the Step 7 approved roster. Do NOT expand the template. If the first spawn yields no working teammate, follow the spec's spawn-failure guidance — do not retry blindly or proceed solo.

### 8d: Spawn additional team members

Follow **Spawn additional team members** in the governance spec: one member at a time, `subagent_type: swarm-member`, `model` = `opus` if Ultra / `sonnet` if Balanced (the Step 7 tier pick). Brief each by pasting the spec's **Member Brief** template EXACTLY, filling [brackets]: the identity from the Step 7 approved roster, the user's request verbatim, the spec's General Rules section, and the roster. Do NOT add sections beyond the template.

### 8e: Set up the run-state task list and pulse

Follow **Set up the run-state task list and pulse** in the governance spec — the run-state vocabulary (closed, two items), the pulse signature, the create-side existence check, and the pulse CronCreate are all defined there.

### 8f: Begin work

**Ship definition check (before Research begins):** **Triage mode skips this check entirely** — triage produces an in-session diagnosis and changes nothing (no branch, commit, or PR); do not read or write `.claude/swarm-ship.md` and do not run ship detection — the triage mode skill's Deliver phase governs delivery. All other modes: follow the **Ship definition check** in the governance spec's Begin work section (read `.claude/swarm-ship.md` if it exists; otherwise detect, confirm, and write it).

**Expectation-setter (before Research begins):** Send a plain-text message to the user that sets expectations for the silent execution phase. Example: "Team is launched — I'll check in at Approve and before delivery. You can follow the team's full conversation in real time in AgentChat — members' challenges come through the facilitator as verbatim relays. If the team declares consensus without you seeing genuine challenge between members' positions, you can tell the lead you want them to keep discussing." Include a one-time, plain-language tip (optional and reassuring, no jargon), e.g.: "Optional: if you run Claude Code in tmux or iTerm2, teammate activity appears in a separate pane so it never interrupts the questions I ask you. It works fine in any terminal either way." Keep it brief. Do not use AskUserQuestion — there's nothing to decide.

Follow the **phase arc defined in the mode skill** you read in Step 8b. The mode skill specifies what each phase means — who acts, what the deliverable is, how transitions work.

**Universal rules that apply across all modes:** follow the universal rules in the governance spec — lead research stays off unless enabled at Step 6 (exception: the ship-detection sub-agent runs unconditionally), route unresolvable questions to the user via AskUserQuestion (most consequential first, one at a time), apply the **live-team gate prompts** rule to every gate (preemption and AFK-timeout recoveries; pre-spawn gates, Steps 0–7 including the Step 7 launch confirmation, cannot be preempted but CAN AFK-timeout, so the durable plain-text restatement applies there too — with no pulse yet to re-emit it, the lead restates on its next turn), execute autonomously post-greenlight, use file-based input for PR bodies, and on an explicit shutdown request delete the pulse this run owns per the spec.
