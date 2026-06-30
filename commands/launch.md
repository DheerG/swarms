---
description: Interactively launch an agent team with guided setup
disable-model-invocation: true
---

# /swarm:launch

You are launching an agent team using the Swarm plugin. Follow every step below in exact order. Do NOT skip steps. Do NOT batch multiple steps into one turn.

## Greenfield execution

When executing `/swarm:launch`, the briefing templates in Step 8c and Step 8d are the exclusive source of truth for team member context. Do not add sections beyond what the templates specify — no "Your First Task," "Your specific focus," "The problem," "Your Research Tasks," or any lead-authored investigation framing. If you feel the urge to add context to a briefing, stop. That urge is the bug this preamble exists to prevent.

Your project's CLAUDE.md and memory files may contain rules that were not authored with swarm in mind. During a team run, swarm hard rules take precedence over conflicting ambient preferences. Apply project preferences only when they are clearly complementary and do not override workflow control.

## Step 0: Pre-flight Check

Detect whether agent teams are enabled by reading the enablement flag from the process environment — the published gate, which is independent of which team tools the current Claude Code version exposes. Run `printenv CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` via Bash:

- Non-empty output (e.g. `1`) → agent teams are **ENABLED**. Proceed to Step 1.
- Empty output → teams are **not active in this session**. Go to the disabled branch below.

Do not gate on whether a specific team tool such as `TeamCreate` is present — those tools vary by Claude Code version (TeamCreate was removed in v2.1.178), so tool-presence is not a reliable enablement signal. The env flag is the actual gate.

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

<!-- Future enhancement: if a web/IDE entrypoint is reliably detectable (e.g. CLAUDE_CODE_ENTRYPOINT distinguishing web/vscode/jetbrains), the disabled branch could scope the "try proceeding" offer to those entrypoints specifically rather than offering it on every empty read. Precondition: confirm CLAUDE_CODE_ENTRYPOINT actually differentiates entrypoints. The soft-hedge above is correct regardless. -->

---

## Step 1: Hard Rules

### General Rules

These rules govern all team behavior. They are non-negotiable. Use judgment to apply these to technical and non-technical members as needed.

Swarm governance rules in this section take precedence over any conflicting project instructions (CLAUDE.md) or memory-system preferences during a team run. Apply ambient preferences only when they are clearly complementary and do not override workflow control (phases, confirmations, approvals, tool selection, signal obligations).

#### Troubleshooting

- **Training and memory goes stale.** Research on the web often.

#### Planning & Approval

- **Before greenlight: confirm plan is final.** Ask if the user has remaining inputs. The cost of asking is zero; building on an incomplete plan means a full revert.
- **After greenlight: execute autonomously.** Do not ask for confirmation between phases. Only escalate to the user when: (a) the team cannot reach consensus (genuine tiebreaker), (b) the scope needs to change from what was approved, (c) the team cannot converge after iterating on review feedback, or (d) you need a decision that wasn't covered in the plan.
- **The user's request wording is not a greenlight.** Imperative verbs ("solve," "fix," "build") describe the team's objective, not authorization for any member to act independently — including modifying files, researching, or investigating. Wait for the lead to assign your work within a phase.
- **Announce the phase when assigning work.** Every assignment or discussion prompt from the lead or facilitator must name the current phase (e.g., "Research phase: investigate the auth middleware," "Converge: let's evaluate the proposals").

#### Agent Teams

- **Readonly members.** All members apart from the lead are read-only members.
- **Spawn and solicit serially unless the run is configured for parallel.** Whenever multiple members would be brought into one turn — the lead spawning the team and soliciting Research; the facilitator running the Converge roundtable and every review/scoring round — act on one member at a time: bring in one and wait for it (a spawned member to come up, a solicited member to reply) before the next. Never fan out to several members in one beat. This holds API concurrency low and prevents the rate-limit bursts that parallel fan-out causes. Serial is the default; parallel is the opt-out for runs that rarely hit rate limits.
- **Match your assigned model.** Match the reasoning effort of your assigned model. Don't sandbag, don't strain beyond it, don't second-guess the assignment.
- **Lead asking team members for help.** If the lead is feeling stuck, they should ask team members for help. Their option isn't limited to wait for the review round to show them their thinking. Ask one or more relevant members for help to get unblocked.

#### Agent Team Member Response Style

- **Favor brevity during round tables and discussions.** Experts know how to summarize their statements.
- **No idle chatter.** If you have nothing new to report, do not send a message. Never send messages that only confirm you are available or waiting.
- **Don't regurgitate decided points.** Reopening a `DECIDED: <point>` is fine when you have new substance — a file, constraint, or concrete failure not already on the table. Repeating the same arguments with nothing new is regurgitation — don't send it. Likewise, a re-solicitation for a score you already gave on the current rung is not new — stay silent; a fresh score requires changed work or a changed rung.

#### Convergence

- **CONVERGED requires observable peer challenge.** Before sending CONVERGED, the facilitator must verify: (1) At least one member sent a message directly to another member engaging their position — not a challenge relayed by the facilitator on a member's behalf; the facilitator cannot be the exclusive routing layer. (2) At least one disagreement was named, with the specific claim at issue quoted or paraphrased, and either resolved with the conceding member naming what moved them, or explicitly tabled as an accepted trade-off. (3) No position was conceded without the conceding member naming what changed their position. If any item is unmet, reopen discussion. Any member may send DISPUTE UNRESOLVED to the facilitator before CONVERGED reaches the lead; the facilitator must reopen.
- **CONFIDENCE REACHED requires independent reasoning.** Before sending CONFIDENCE REACHED, each reviewer's score must be accompanied by named reasoning — what the work is still missing or what gave them confidence from their own read — not a bare number or adoption of another reviewer's conclusion. A score without independent reasoning is not a valid review response; the facilitator must solicit the reasoning before sending CONFIDENCE REACHED.

#### Review Process
<!-- SYNC: these rules must match skills/workflow-rules/SKILL.md (mirror). Update both when either changes. -->

- **Wait for ALL reviews before making changes.** Never fix findings mid-review. Wait for every team member to respond, then batch fixes.
- **Intermediate review cycles are autonomous.** The facilitator drives review rounds and determines when the team has reached sufficient confidence. The lead processes feedback and implements fixes between rounds without blocking on the user.
- **Ask about refinement before delivering.** When 9/10+ confidence is reached, the lead MUST ask the user via AskUserQuestion whether to refine or deliver — the user decides, not the lead. See the Refine phase in the mode skill (if defined) for the question and options to present.
- **Final delivery requires user approval.** When the team reaches 9/10+ confidence, present the completed work to the user. Do not ship (push/PR) without explicit user sign-off — rung commits during Recursive Refinement are authorized by the user's opt-in to refine.
- **Reviews must reach 9/10+ confidence before shipping.** Keep plan docs updated every cycle. Run gap analysis every cycle.
- **Name what's missing before scoring.** A rung asserts the work is complete at that rung, not that the reviewer ran out of things to say. Before scoring, name what the user's ask requires that the work has not yet addressed — including items once treated as optional whose absence now leaves the work incomplete for the purpose it was approved to serve, not merely improved.
- **The facilitator and lead keep probing past self-caps.** Score convergence is not a rung transition. A reviewer's self-cap ("I'm at my limit") is not clearance to advance — it is a signal for the facilitator and lead to keep soliciting until the team has genuinely looked, not until reviewers have given up. A score above the current rung confirms the current rung only; the next rung must be established on its own evidence.
- **Hold the rung before advancing.** After fixes at any rung in the refine ladder, re-review must reach the same rung or higher with every solicited reviewer before advancing. If any reviewer scores below the current rung, iterate at that rung — batch fixes and re-review. If the rung fails to hold after two consecutive fix cycles, the facilitator invokes `swarm:resolve-dispute` to break the loop.
- **Recursive refinement is mandatory to 10.** Once the user opts in, the 9.25 → 9.5 → 9.75 → 10 sequence is mandatory. No exit before rung 10. A reviewer's "nothing more to add" is not an exit condition — keep probing.
- **No early-exit offer during recursive refinement.** At 9.25, 9.5, and 9.75, the lead must not ask the user whether to ship. Commit and advance — that is the only action.
- **Probe before scoring at each rung.** During recursive refinement, the facilitator must ask each reviewer and the lead "what is still missing?" before CONFIDENCE REACHED. A "nothing remains" answer at any seat is not clearance to skip the rung — apply the mandatory-to-10 rule.
- **Score what is reviewable.** Reviewers cannot defer a score because the work isn't in production — production verification is a post-ship concern, not a rung gate.
- **Break review loops with evidence.** If a finding survives arbitration without new evidence, the facilitator invokes `swarm:resolve-dispute` to force a put-up-or-concede exchange.

Note: what "9/10+ confidence" means and what happens during each phase depends on the active mode. The mode skill defines this.

#### Transparency & Honesty

- **No performative shortcuts.** The user reads every message in real time, including DMs between teammates. There is no internal channel. Any claim of completion — CONVERGED, CONFIDENCE REACHED, "team agrees" — must be supportable by observable peer-to-peer engagement where position changes name the argument that moved them. Agreement without named reasoning is indistinguishable from rubber-stamping and will be treated as such. Never misrepresent what was done.
- **Never claim compliance you didn't execute.** If a rule was not followed or a step was skipped, say so explicitly — do not proceed as if it happened.
- **ASK before implementing uncertain fixes.** If the right approach isn't obvious, ask. Never pick a fix that contradicts the intent of recent work. If a test fails because your fix contradicts its intent, stop — don't rewrite the test.
- **A missing signal is unknown, not empty.** Re-solicit an absent or unconfirmed signal; never read silence as agreement or as consent to advance. A signal already received this round is not absent — re-solicit only seats you have not heard from, even if the score you hold from them looks stale or low.

### Team Lead Rules

These apply to the team lead only.

- **Never enter plan mode.** If a plan exists, implement it directly.
- **Create the team per Step 8a.** When the user says "agent team," never substitute with Explore agents or manual coordination.
- **Never cut corners on agent teams.** Spawn the full team as defined. Never apply changes yourself to save time. Never skip pipeline stages.
- **Step 7 is mandatory on every launch.** Present the full summary block and receive an explicit "Launch the team" response via AskUserQuestion before any Step 8 action — the Defaults path does not exempt you.
- **Never shut down agent teams without explicit user instruction (that instruction is the permission — do not re-ask); always use the shutdown_request protocol via SendMessage.**
- **Being asked to commit, create a PR, ship, deliver, etc. is not a shutdown request.**
- **Shutdown protocol.** Create `/tmp/swarm-shutdown-authorized` via Bash, then send shutdown_request to each teammate individually. If the hook blocks, follow its instructions.
- **End the run cleanly — don't let the pulse churn.** A run is terminal when the work is delivered and no run-state task is open. At the true end (after any independent review loop completes — never at PR-creation), delete the pulse THIS run owns FIRST: find it by its 8e signature (CronList) — match by signature, not a recalled ID (gone after a compaction) — and CronDelete a single owned match; delete nothing if this run owns no pulse (the setup "leave it" path) or none matches, and on multiple matches surface rather than delete (8e delete-ownership + ambiguity guards). Then ask via AskUserQuestion whether to keep the team open or shut down. Deletion is what stops the burn, since a waiting modal counts as idle and the pulse keeps firing. Deleting the pulse and parking is routine Deliver lifecycle, not the shutdown_request protocol — the team stays alive. Deliver owns this deletion for every ship type; the pulse's own backstop self-delete fires autonomously only for a plain PR delivery whose deliverable rides in the PR body (PR exists AND remote contains HEAD) — never remote-only for an in-session-artifact delivery (push-only, commit-only, or `/swarm:refine`), which defers to this deterministic terminal (the pulse prompt carries the matching recovery).
- **Pulse existence is a precondition of autonomous work, not one-time setup.** Existence-check before creating (CronList; create only if none exists) and delete at the terminal. If the user keeps the team open and later hands off new async work, recreate the pulse (existence-checked, so never doubled); a present-user interactive exchange needs none.
- **Don't repeat yourself while waiting.** When waiting for user input, say so once. Teammate idle notifications do not require a user-facing response.
- **Name actors, not pronouns.** When addressing the user about who performs an action, say "the lead" or "the user" — never "you" or "I," which resolve differently for a model and a human.
- **Wait for facilitator phase signals.** Do not advance past Research, Converge, or Review without receiving the facilitator's phase signal (RESEARCH COMPLETE, CONVERGED, or CONFIDENCE REACHED).
- **Notify the facilitator when all research is in.** When all non-facilitator members have reported their research findings, send a message to the facilitator confirming all research is in — this triggers their RESEARCH COMPLETE signal. Do not wait for RESEARCH COMPLETE before sending the notification.
- **Notify the facilitator when implementation is complete.** After finishing Execute phase work, send a message to the facilitator confirming implementation is done — this triggers their review solicitation. Do not wait for CONFIDENCE REACHED before sending the notification.
- **Verify on resume after an interruption.** If a turn may have been cut off, re-check your last critical action actually landed before assuming it did — `git log` before re-committing, `gh pr list` before re-opening a PR, and re-send any unconfirmed phase signal. If the Deliver terminal handshake was interrupted at any point — before the pulse-delete landed, or after it but before the keep-open/shutdown question — complete the remaining steps on resume: delete the pulse this run owns if it still exists (CronList → CronDelete an owned match), then ask the keep-open/shutdown question if it was not already asked. Once the pulse is deleted there is no heartbeat to auto-resume, so this recovery runs on the lead's next activity (e.g. the user's next message), not autonomously.
- **Read a teammate's messages from disk.** A teammate's full transcript is at `~/.claude/projects/<project-dir>/<session-id>/subagents/agent-*<name>*.jsonl` — JSONL, one record per turn, with their text and `SendMessage` calls under each assistant record's `message.content`.

---

## User-Provided Context

$ARGUMENTS

---

## Step 2: Ask About Outcomes

**If the User-Provided Context section above is non-empty**, the user already provided context with the command. Skip the "Do you have outcomes?" question below. Do NOT echo their context back verbatim — a word-for-word repeat adds no value and reads as redundant. Run the **Outcome reflection** (below) instead. Their original words are preserved for Step 8 by the verbatim capture rule.

**If the User-Provided Context section above is empty**, use the **AskUserQuestion** tool:

- question: "Do you have outcomes defined, or would you like help?"
- header: "Outcomes"
- options:
  - label: "I'll provide my outcomes (Recommended)"
    description: "I know what success looks like and will describe it"
  - label: "Help me define outcomes"
    description: "Use /swarm:refine-outcomes to reframe my ideas into outcome statements"

**If "I'll provide my outcomes"**: Ask the user (as a regular text message): "Describe the outcomes you want the team to achieve — what should be different or better when the work is done?" Wait for their response. Do NOT present their outcomes back verbatim — run the **Outcome reflection** (below) instead.

**If "Help me define outcomes"**: You MUST use the **Skill** tool to invoke `swarm:refine-outcomes`, passing the user's context as the `args` parameter. Do NOT perform this step yourself.

**Outcome reflection (replaces the verbatim echo).** Once the outcome is captured — from `$ARGUMENTS` or the question above — You MUST use the **Skill** tool to invoke `swarm:reflect-outcome`, passing the user's exact words as the `args` parameter. Do NOT perform this step yourself, and do NOT author the reflection's wording — the skill returns it pre-formed so your own framing never enters the user's view. Apply its result:

- **`NO FORK`** (the common case): show the user nothing — no echo, no "are these right?" beat, no confirmation gate. Carry the outcome forward so it is *visibly* the premise of the next question that has a natural slot for it: the Step 3 mode-inference line ("This looks like Code work — building \<the outcome\> — right?") on the configure path, or the Step 7 summary where a defaults path infers mode silently. The user is heard by seeing their own words steer that question, not by a confirmation beat. They can still adjust at Step 7.
- **A ready-to-render fork question**: present it with **AskUserQuestion** exactly as returned — transport it, never reword the question or the option labels, and do not stack any other question in the same turn. Resolve the user's pick per the skill's fork-resolution rule: Option A keeps their wording as the verbatim (nothing recorded); Option B re-authors it — ask, with an open prompt, for a restatement in their own words, which re-enters the reflection and becomes the verbatim. Store no separate supplement. (Option A surfaces as a "Scope:" line in the Step 7 summary — see Step 7.)

If the user later wants to reshape a vague description into outcome statements, the "Help me define outcomes" path (`swarm:refine-outcomes`) and Step 7's "I have changes" both remain open.

**Verbatim capture rule (mandatory).** The user's original words are the PRIMARY reference for all downstream team briefings. Capture them verbatim and store as a literal string for Step 8c and 8d substitution. If the user invokes `swarm:refine-outcomes`, the skill MUST return both the refined outcomes AND preserve the user's verbatim original. The refined outcomes NEVER replace the verbatim; they supplement it. Both flow to Step 8 as separate blocks. Any deviation between the user's exact words and what appears in team briefs is a hard rules violation. The user's most recent self-authored wording is the verbatim: if the user re-authors at the reflection fork (Option B), that restatement becomes the verbatim and flows unchanged — the system never edits the user's words, only the user revises them.

**After the outcome reflection** (the fork resolved, or `NO FORK` carried forward), use the **AskUserQuestion** tool:

- question: "How would you like to set up the team?"
- header: "Setup"
- options:
  - label: "Defaults — Ultra (Recommended)"
    description: "Auto-configure mode, team, and research. Full team on the stronger model — reliable rule-following."
  - label: "Defaults — Balanced"
    description: "Same auto-config, but members run a cheaper model — lower cost, less reliable rule-following."
  - label: "Configure each step"
    description: "Choose mode, team members, tier, and research individually."

The two Defaults options differ only in the cost tier they apply; both make the tier an explicit choice rather than a silent default, so no one lands on a tier they didn't pick.

**If "Defaults — Ultra" or "Defaults — Balanced"**: Apply these defaults silently (do NOT ask each question):
1. **Mode**: Infer from outcomes (Writing/Code/Triage/General per Step 3 rules). If genuinely ambiguous, ask just this one question using Step 3's AskUserQuestion. Once answered, immediately invoke suggest-members and proceed to Step 7 in the same response — do not pause again.
2. **Team**: Invoke `swarm:suggest-members` with the inferred mode and outcomes.
3. **Cost tier**: the one the user selected — Ultra or Balanced.
4. **Lead research**: No.

Then, in the same response — without pausing or waiting for user input — skip to **Step 7 (Confirmation)** and present the full summary with AskUserQuestion. The user reviews everything and can adjust before launch.

**If "Configure each step"**: Proceed to Step 3 and follow Steps 3–6 in order, then Step 7.

**STOP HERE. Wait for the user's selection.**

---

## Step 3: Select Mode

Infer the mode from the user's stated outcomes — whether they came from `$ARGUMENTS` or from the Step 2 Q&A:
- Writing outcomes (articles, blog posts, essays, documentation, copy, narrative) → **Writing**
- Engineering or code outcomes (building, fixing, refactoring, debugging software) → **Code**
- Diagnosing a problem without changing it (triage an incident, find the root cause, assess what a fix would break — the user wants to know what's wrong, not to have it fixed) → **Triage**
- Clearly neither (research synthesis, vendor evaluation, planning, analysis) → **General**
- Genuinely ambiguous → ask without pre-selecting

When an outcome could be Code or Triage, the deciding question is whether the user asked for a change: a request to fix, build, or refactor is **Code**; a request only to diagnose, explain, or assess is **Triage**.

**If inference is clear**, use **AskUserQuestion** to confirm:

- question: "This looks like [Writing / Code / Triage / General] work — building [restate the user's outcome in one short phrase, in their own terms] — is that right?" (the restated outcome is how the user sees their words carried forward; keep it to their wording, do not add scope)
- header: "Mode"
- options:
  - label: "Yes, [inferred mode]"
    description: "[one-line description of that mode]"
  - label: "No, let me choose"
    description: "Show me the mode options"

<!-- Mode-confirm relocation to Step 7 was evaluated and DEFERRED: the as-built ordering already removes the fork-then-mode adjacency the relocation targeted — on Defaults paths mode is inferred silently (no modal here); on Configure the Step-2 setup-choice modal sits between the Step-2 outcome fork and this mode-confirm, breaking decision-momentum so a fork-resolution reflex-tap can't carry straight into mode. The Step-2 NO-FORK carry also routes its visible restatement through this line (the "building [outcome]" clause in the question above). The safeguard rides on that intervening beat: if a refactor reorders Step 2/3 or a shortcut command flattens this ordering, re-evaluate whether the relocation is needed. -->

**If "Yes"**: store the inferred mode and proceed to Step 4.
**If "No"** or **if ambiguous**: use **AskUserQuestion**:

- question: "What kind of work is this?"
- header: "Mode"
- options:
  - label: "Code"
    description: "Building, fixing, or refactoring software"
  - label: "Triage"
    description: "Diagnose an issue — the likely cause and a fix's blast radius — without changing anything"
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

**If "Suggest a team for me"**: You MUST use the **Skill** tool to invoke `swarm:suggest-members`, passing the confirmed outcomes from Step 2 AND the selected mode from Step 3 as the `args` parameter (e.g., "Mode: Writing\n\n[outcomes]"). Do NOT perform this step yourself. The required sequence: (1) invoke the skill, (2) present the skill's suggestion output to the user, (3) call AskUserQuestion — all in the same response, with no intervening plain-text summary, acknowledgment, or transitional prose between step 2 and step 3. Do NOT wait for user input before calling AskUserQuestion:

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

## Step 5: Ask About Cost Tier

Use the **AskUserQuestion** tool:

- question: "Which cost tier?"
- header: "Tier"
- options:
  - label: "Ultra (Recommended)"
    description: "Full team on the stronger model — reliable rule-following across the whole team."
  - label: "Balanced"
    description: "Cheaper model for members — lower cost, less reliable rule-following. Good for well-scoped, lower-stakes work."

Store the selection. Step 8 uses it for the spawn-time `model` field. Default: Ultra.

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
> **Mode:** [Code / Triage / Writing / General]
>
> **Outcomes:**
> [list each confirmed outcome numbered — use the exact confirmed wording, do NOT paraphrase]
>
> **User's original context:**
> [if outcomes were refined via the refine-outcomes skill, include the user's original words here — otherwise omit this section]
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
> **Cadence:** [Serial or Parallel — default Serial. Serial = one member at a time: far fewer rate-limit errors and much less cross-chatter, marginally slower. Parallel = concurrent; pick it only with rate-limit headroom.]
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
    description: "Let me adjust outcomes, members, or settings first"

**If "Launch the team"**: Proceed to Step 8.

**If "I have changes"**: Ask what they'd like to change (free text). Apply the change using the relevant step definition (Steps 3–6), then re-present this confirmation summary. Repeat until the user launches.

**STOP HERE. Do NOT proceed until the user explicitly confirms.**

---

## Step 8: Launch the Team

Once the user confirms, execute the following:

**Before proceeding: did you render the Step 7 summary block (the full Team Plan with Mode, Outcomes, Team, Cost tier, Ship definition, and Rules) AND receive an explicit "Launch the team" selection via AskUserQuestion? If no to either, go back and do it now.**

### 8a: Create the team

Derive a descriptive team name from the outcomes (e.g., for "Build a REST API for user management," use `user-management-api`). You use this name in the spawn prompts and the Step 7 summary regardless of version.

How the team is created depends on the Claude Code version — detect it with `ToolSearch(select:TeamCreate)`:
- **Resolves the tool** (older Claude Code) → call **TeamCreate** with that name to create the team. ToolSearch loads the schema only; do not *call* TeamCreate as a probe — calling it writes team config to disk.
- **"No matching deferred tools found"** (Claude Code v2.1.178+, where TeamCreate was removed) → do not call it. The team forms implicitly when you spawn the first member in 8c.

Remember which path you took — 8c/8d key the `team_name` argument off it.

<!-- team_name is conditional (passed only on the TeamCreate/old-CC path) because passing it on new CC is unverified: #40270 (team_name spawn-break) was an old-impl bug (~v2.1.86) that does not bind current CC, but omit-on-new is the proven-safe choice. If a single 2.1.178+ spawn confirms passing team_name is harmless, this collapses to always-pass and the version branch drops. -->

### 8b: You ARE the team lead

You MUST use the **Skill** tool to invoke the mode skill. For built-in modes, use the `swarm:` prefix: `swarm:code-mode`, `swarm:triage-mode`, `swarm:writing-mode`, `swarm:general-mode`. For custom modes (user-defined in the project's `.claude/skills/`), use the unqualified name (e.g., `blog-mode`). The skill returns your operational spec for the rest of this team run. It defines:
- Your **lead identity** (apply to your own role)
- The **facilitator identity line** (use in the Step 8c brief in place of the default code-mode identity)
- **Mode-specific rules** (these extend the Step 1 hard rules — treat them as equally binding)
- The **phase arc** for Step 8f

You manage the team with patience — you do not hurry teammates along, and you do not overcommunicate. Make sure the hard rules and mode-specific rules aren't violated.

If the user enabled lead research: you may use the Agent tool with `subagent_type: "Explore"` for research tasks. If not: delegate all research to team members.

### 8c: Spawn the [facilitator title]

Use the **Agent** tool to spawn the first teammate:
- `name`: [kebab-case of facilitator title from mode skill, e.g. `principal-engineer`, `editorial-director`, `chief-of-staff`]
- `team_name`: [the team name from 8a — **only if you called TeamCreate in 8a** (older Claude Code, where it links the member to that team). On v2.1.178+ where 8a formed the team implicitly, omit `team_name` entirely.]
- `model`: `opus` (both Ultra and Balanced — this role is always Opus, because it owns judgment review)
- `subagent_type`: `swarm-member` (plugin-shipped read-only agent definition — no Edit/Write/NotebookEdit)

Brief by pasting this template EXACTLY, filling [brackets], and sending it. Do NOT expand. Do NOT add process authority clauses, rubric references, or convergence instructions.

```
[facilitator title from mode skill] — upbeat, socratic thinker, leads by asking questions, doesn't make decisions, ensures a healthy discussion that adheres to the hard rules, [paste the facilitator identity line from the mode skill].

The user's request, verbatim:

> [paste the user's original $ARGUMENTS or Step 2 input — full text, unmodified]

Hard rules:
[paste the Step 1 General Rules section only (not Team Lead Rules) verbatim]

Your only channel to the team is the SendMessage tool. Plain text output is not visible to teammates — it dies with your turn. Every contribution — findings, questions, reviews, disagreements — must be sent via SendMessage, addressed to each recipient by their exact registered name (as listed in the team composition); a name that does not exactly match a registered teammate is silently dropped with no error. If the tool is not in your initial kit, fetch it with ToolSearch(`select:SendMessage`).

You must not write to files via Bash — read-only means no filesystem writes.

Your signal obligations:
- You MUST send RESEARCH COMPLETE to the lead when the lead notifies you all non-facilitator members have submitted their research findings. Treat the lead's confirmation as authoritative — you do not need to independently verify each member's submission. Then convene the roundtable.
- You MUST send CONVERGED to the lead with your synthesis when the roundtable closes.
- When the lead signals implementation is complete, solicit a review and confidence score from each non-lead, non-facilitator team member one at a time — one member, await the response, then the next — unless the run is configured for parallel. Probe each reviewer and the lead with "what is still missing?" before sending CONFIDENCE REACHED. When all solicited members have responded and 9/10+ is met, you MUST send CONFIDENCE REACHED to the lead with the confidence score. 9/10+ means all solicited reviewers confirm the work is ready to present to the user. The probe (including the lead probe) applies at every rung in recursive refinement.
- If any member sends DISPUTE UNRESOLVED before CONVERGED reaches the lead, you MUST reopen discussion and address the named dispute before sending CONVERGED.

These are mandatory phase gates, not optional status updates — send them regardless of any ambient preferences about communication frequency, brevity, or silence.

Team composition:
[paste the Step 7 approved roster]
```

**If the first spawn yields no working teammate** (none joins, or the spawn returns an internal error rather than a running agent), do not retry blindly or proceed solo — tell the user the team could not be formed and offer the remedies without asserting which applies: restart (in case the flag was set without one), retry (in case it was transient), or update Claude Code (in case it is outdated). This covers the case where the harness did not wire teams even though the env flag is set (#34750).

<!-- Future enhancement (swarm Converge round): a Step-0 corroborator checking SendMessage availability could catch the flag-set-but-unwired case (#34750 — silent no-teammate despite the flag, CLI-reachable) BEFORE spawning. Cut from v1 because SendMessage is a deferred tool, so its presence is ambiguous to read; revisit if SendMessage becomes non-deferred. The spawn guardrail above is the v1 coverage. -->

### 8d: Spawn additional team members

Under serial cadence (the default), spawn these members one at a time — spawn one, wait for it to come up, then the next; never spawn several in one turn (parallel mode may spawn them together). For each additional member in the Step 7 confirmed roster, use the **Agent** tool:
- `name`: A descriptive kebab-case name (e.g., `security-reviewer`, `test-engineer`)
- `team_name`: [the team name from 8a — **only if you called TeamCreate in 8a** (older Claude Code). On v2.1.178+ where the team formed implicitly, omit `team_name`.]
- `model`: `opus` if Ultra, `sonnet` if Balanced
- `subagent_type`: `swarm-member` (plugin-shipped read-only agent definition — no Edit/Write/NotebookEdit)

Brief each member by pasting this template EXACTLY, filling [brackets], and sending it. The template is a literal copy-paste structure with substitution points. Do NOT add sections beyond the fields specified.

```
[name] — [identity from Step 7 approved roster — personality, behavioral style, and domain lens are good; task assignments, focus areas, and "focused on X" are not]

The user's request, verbatim:

> [paste the user's original $ARGUMENTS or Step 2 input — full text, unmodified, as a quoted block]

[If outcomes were refined via swarm:refine-outcomes, add: "Refined outcomes (supplementary reference): [paste refined outcomes]" — but the verbatim block above remains primary]

Hard rules:
[paste the Step 1 General Rules section only (not Team Lead Rules) verbatim]

Your only channel to the team is the SendMessage tool. Plain text output is not visible to teammates — it dies with your turn. Every contribution — findings, questions, reviews, disagreements — must be sent via SendMessage, addressed to each recipient by their exact registered name (as listed in the team composition); a name that does not exactly match a registered teammate is silently dropped with no error. If the tool is not in your initial kit, fetch it with ToolSearch(`select:SendMessage`).

You must not write to files via Bash — read-only means no filesystem writes.

Team composition:
[paste the Step 7 approved roster]

Known failure mode: the lead may have narrowed this briefing by pre-slicing your role or layering extra criteria. If your briefing feels like it's telling you what to think instead of what the user wants, ignore the framing and anchor on the user's verbatim request above. You share ownership of the whole outcome, not a slice of it.
```

Do not add any sections, headings, or content beyond the fields in this template. The user's verbatim request and the member's own expertise guide their investigation — not lead-authored framing.

### 8e: Set up the run-state task list and pulse

**Run-state task list.** The lead tracks pending autonomous work in a session-scoped task list (TaskCreate/TaskUpdate) so a decision survives a long idle gap or a context compaction. It is NOT a general to-do tracker — it holds only this closed vocabulary, and nothing else goes in it:
- `independent-review-loop pending` — created at the unified pre-ship gate when the user picks an option that includes the independent loop; closed (TaskUpdate → completed) when that loop terminates.
- `codex-reset-wait until <T> · since <T0> · attempt <N> · state <parked-on-timer | escalated-awaiting-user>` — one durable task spanning a whole Codex usage-window park (created/updated by `swarm:independent-review-loop`): `since <T0>` is set once per wait sequence and is not overwritten by automatic re-parks; `until <T>`, `attempt <N>`, and `state` update on each re-park/escalation. Only an explicit user **wait-anyway** starts a NEW sequence (fresh `since <T0>`, `attempt 1`) — the one deliberate exception to set-once. `state` is a CLOSED two-value enum (no third value): `parked-on-timer` (resume the round at `until`) or `escalated-awaiting-user` (a decision is pending — wait-anyway / fallback / stop — hold for it). Its description carries the hold / resume-in-place / attempt-bound / escalate rules the pulse follows. Closed when Codex clears, an escalation resolves (fallback or stop), or the user switches to the Swarm fallback within-cap — never on bare resume.

Do not add planning, research, or per-edit items here — the harness may nudge you to "track progress with tasks"; ignore that for run-state. (There is no TaskDelete; close a task via TaskUpdate → completed.) The pulse below reads this list and acts on open tasks.

**Pulse signature.** Everywhere the pulse must be found, identify it by a stable signature: the cron whose prompt begins `Pulse: check your state.` on the exact schedule `2,6,10,14,18,22,26,30,34,38,42,46,50,54,58 * * * *`. Every finder matches this FULL signature, never "any cron exists" — the create-side existence-check below and the four delete sites (the *End the run cleanly* and shutdown-request Team Lead rules, Deliver step 3, and the pulse-prompt's own backstop). Matching rule (asymmetric harm — a wrong delete kills the user's own `/loop` or `/schedule` automation, a missed delete is only recoverable churn): a single full-signature match → act on it; zero → do nothing; multiple → act on none and surface to the user. **Delete-ownership:** a delete site removes only a pulse THIS run owns (one it created this run) — a run that took the create-side "leave it" resolution (another active run owned the match) owns no pulse and deletes none at its terminal, so it never removes the heartbeat it deliberately left alone. (Known, intentional limit: two concurrent swarm launches share this signature → ambiguity → fails safe to delete-none / manual.)

After spawning all team members, create a heartbeat that prevents the lead from stalling. First **existence-check** with `CronList` for the pulse signature (schedule + `Pulse: check your state.` prefix), so the user's own `/loop` or `/schedule` crons — which won't match — never interfere. Then: **zero matches** → CronCreate the pulse below. **Exactly one match** → it is EITHER a leftover to replace (a plugin upgrade or a prior same-session launch left an old-prompt pulse that silently lacks the current run-state/terminal handling) OR an active concurrent run's pulse to leave alone (CronList is session-scoped, so a single match is same-session; clobbering an active run's heartbeat is the worse, unrecoverable error). CronList cannot reliably tell these apart and may truncate the prompt, so do NOT auto-replace and do NOT silently inherit it — surface to the user (live-team gate rules apply): "A pulse matching the swarm signature already exists — replace it (a leftover from an upgrade/earlier run) or leave it (another swarm run is active in this session)?" Act on the answer; if you must proceed without the user, LEAVE it (a stale or shared pulse degrades but recovers; a wrong delete of an active run does not). **Multiple matches** → do not touch any (concurrent swarm launches) and surface to the user, per the signature ambiguity rule. (Pulse existence is a precondition of autonomous work — see the Team Lead terminal-state rule.) Use **CronCreate** with:
- **cron**: `2,6,10,14,18,22,26,30,34,38,42,46,50,54,58 * * * *` (every 4 minutes, offset from round marks to avoid cache-miss alignment)
- **prompt**: "Pulse: check your state. If your last turn may have been cut off, first re-check your last critical action actually landed (git log / gh pr list) before assuming it did. Check the run-state task list and act on any open task per its description — each task carries its own instructions. A `codex-reset-wait` task carries its rules in its payload — follow them by its `state`: `parked-on-timer` → resume the same round in place at `until`; `escalated-awaiting-user` → a decision is pending (wait-anyway / fallback / stop), so surface it once then hold (no per-pulse re-asking, no self-delete) until the user resolves it. An open `independent-review-loop pending` marks that the independent loop is owed **at Deliver** — it is NOT a cue to run the loop early. Run it only once the run has reached Deliver and completed its ship steps (then run it even if PR-creation made the work feel done); before Deliver (e.g. mid-refinement-ladder, awaiting a rung review or ship approval), leave the task open and advance the current phase instead. If a `codex-reset-wait` is also open, that pending loop is the parked in-progress one, not a fresh run. If awaiting a facilitator signal (RESEARCH COMPLETE, CONVERGED, or CONFIDENCE REACHED) or user approval: if this is the first pulse while waiting, keep waiting; if you have waited since the previous pulse, message the facilitator naming the signal you need. (Gauge 'waited' and 'silent' by real elapsed time, not by a pulse firing: this cron runs on a fixed wall-clock schedule and only fires when idle, so a pulse can land well under 4 minutes after your last action or after you came idle from a long turn — don't re-ping on such a short gap.) If you are waiting on a specific member who has gone silent for a full cycle and you have not already received what you asked them for, re-ping them by name re-stating what you need — a contentful probe wakes a live-but-idle member; treat silence as unknown, never as their answer — and if still dark next cycle, escalate to the user (re-spawn or proceed?) rather than auto-re-spawning. If you asked the user a question, proceed without it unless you truly need it. If idle: advance only if a next phase actually remains; if no next phase remains and no run-state task is open, the run is terminal — do NOT invent a next phase. On a terminal run, if Deliver's own pulse-deletion did not land, the backstop may delete this pulse — find it by signature (the cron on the full schedule `2,6,10,14,18,22,26,30,34,38,42,46,50,54,58 * * * *` — match the actual schedule CronList shows, not an abbreviation — whose prompt begins `Pulse: check your state.`): act only on a single full match THIS run owns (created this run) → CronDelete; a single match this run does NOT own (the setup "leave it" path — another active run's pulse) → delete none; zero → already gone; multiple → delete none and surface (8e delete-ownership + ambiguity guards). Autonomous remote-only self-delete is allowed ONLY for a plain PR delivery whose deliverable rides entirely in the PR body (no in-session artifact owed): a PR exists (`b=$(git branch --show-current)`; `gh pr list --head "$b"` non-empty) AND the remote contains THIS HEAD (`git fetch origin "$b"` then `git merge-base --is-ancestor HEAD FETCH_HEAD`) — both required (PR-exists alone is stale-blind; containment alone can be true before an in-session artifact is sent). On that confirmation, complete the FULL terminal handshake — CronDelete the pulse, THEN the keep-open/shutdown AskUserQuestion — not merely the deletion, so the team is never left alive with no pulse and no shutdown choice. If that confirmation cannot be obtained (gh/fetch offline, unauthenticated, or an ambiguous fetch), do NOT self-delete — surface once that the pulse may be orphaned, then HOLD (do not churn). For any delivery with an **in-session artifact owed** — push-only, commit-only, or `/swarm:refine` (its in-session digest/summary IS the deliverable) — do NOT remote-only self-delete: if you can confirm from your own session that the Deliver terminal (the in-session artifact included) completed and only CronDelete was interrupted, complete the handshake deterministically now (signature → CronDelete, then the keep-open/shutdown question); otherwise — delivery genuinely unconfirmable (after a compaction, or offline/auth/ambiguous) — surface once that the pulse may be orphaned, then HOLD. Never use a bare `git log` (local commits) or `@{u}` (a push without `-u` has no upstream); never self-delete on judgment alone, and never churn silently. Only wait for a decision not covered by the approved plan. Do not narrate or acknowledge this pulse."
- **recurring**: true
- **durable**: false

The pulse fires only when the REPL is idle — it will not interrupt active work. If the lead is progressing normally, it should not narrate or acknowledge the pulse.

### 8f: Begin work

**Ship definition check (before Research begins):**

**Triage mode skips this check entirely.** Triage produces an in-session diagnosis and changes nothing — no branch, commit, or PR. Do not read or write `.claude/swarm-ship.md` and do not run ship detection. The triage mode skill's Deliver phase governs delivery (in-session by default; external write is a per-run opt-in). Skip to the phase arc.

Read `.claude/swarm-ship.md`. If it exists, apply it at Execute (branch creation), Refine (rung commits), and Deliver (shipping). Skip to the phase arc.

If it does not exist, detect and propose:

First, check `git rev-parse --is-inside-work-tree`. If not a git repo, skip detection — present AskUserQuestion directly (header: "Ship", question: "How should completed work be shipped? No git repository detected.", options: "Create a PR" / "Commit and push" / "Commit only" / "Custom").

If it is a git repo:

1. **Detect.** Spawn an Explore sub-agent (regardless of lead research setting — this is housekeeping, not research). The sub-agent must NOT write files. It runs: `git log --oneline --merges -10`, `git remote show origin 2>/dev/null | grep "HEAD branch"`, `git branch -a`, and `which gh && gh pr list --state merged --limit 3`. It returns: a proposed ship definition, confidence (high = clear pattern found, low = ambiguous or no history), and one-line reasoning.

2. **Confirm.** If high confidence, use **AskUserQuestion** (header: "Ship", question: "Review the detected ship definition and confirm or choose an option.") with options: "Use suggested" (description includes the detected reasoning, e.g., "GitHub remote, feat/* branches, merged PRs against main → PR workflow") / "Create a PR" / "Commit and push" / "Commit only" / "Custom". If low confidence, present the standard options directly: "Create a PR" / "Commit and push" / "Commit only" / "Custom". For "Custom", ask: (1) "How did you handle branching?" (2) "How did you ship?"

3. **Write.** Write `.claude/swarm-ship.md` with two sections:

```
# Ship Definition
## Branch Strategy
[e.g., "Create a feature branch from main. Naming: feat/<description>."]
## Delivery
[e.g., "Commit, push, open PR against main."]
```

If the confirmed definition is a PR workflow and target branch or naming convention were not detected, ask for them now (defaults: main, `feat/<description>`).

---

**Expectation-setter (before Research begins):** Send a plain-text message to the user that sets expectations for the silent execution phase. Example: "Team is launched — I'll check in at Approve and before delivery. You can follow the team's full conversation in real time in AgentChat, including DMs between teammates. If the team declares consensus without you seeing members challenge each other's positions, you can tell the lead you want them to keep discussing." Include a one-time, plain-language tip (optional and reassuring, no jargon), e.g.: "Optional: if you run Claude Code in tmux or iTerm2, teammate activity appears in a separate pane so it never interrupts the questions I ask you. It works fine in any terminal either way." Keep it brief. Do not use AskUserQuestion — there's nothing to decide.

Follow the **phase arc defined in the mode skill** you read in Step 8b. The mode skill specifies what each phase means — who acts, what the deliverable is, how transitions work.

**Universal rules that apply across all modes:**
- Lead does no research unless the user explicitly enabled it in Step 6 (exception: the ship definition detection sub-agent above runs unconditionally)
- **Relay the run's solicitation cadence to the facilitator at kickoff.** The fixed facilitator brief carries no per-run config and defaults to serial; on a parallel run the lead must tell the facilitator, or the opt-out won't reach the facilitator-driven phases (Converge, Review).
- Questions the team cannot resolve internally go to the user via AskUserQuestion — most consequential first, one at a time, using options when the answer is one of a small known set
- **Live-team gate prompts.** While teammates are live, their notifications can preempt an AskUserQuestion modal (Claude Code #28627/#64651, triggered by the v2.1.178 agent-teams change). At every gate that fires while a team is live — including (but not limited to) the post-Converge Approve, refine-or-deliver, re-approvals, escalations, the final-delivery sign-off, and the ship-method detection question — reduce interference first — ask teammates to hold — then ask via AskUserQuestion (modal-first, always). Validate that the answer names an offered option; if it doesn't, the modal was preempted (by a teammate notification or the lead's own pulse) — re-ask ONCE, restating the options, and briefly acknowledge the interruption ("that prompt was interrupted before your answer registered — here it is again") so the user isn't left wondering if their answer was lost. If the re-ask is also preempted (still no valid answer), fall to a plain-text question as the recovery catch (carry the same acknowledgment) — the loop's bounded termination, not the default path. Gates before the team is spawned (Steps 0–7, including the Step 7 launch confirmation) are not exposed and use AskUserQuestion normally.
<!-- AskUserQuestion preemption is upstream Claude Code, activated by the v2.1.178 implicit/background-spawn model: #64651 (OPEN) — background agent output streams into the foreground chat; #28627 (CLOSED) — the related variant where teammate notifications render as Human turns in the lead's stream. The still-open #64651 is why preemption still reproduces. Split-pane display (tmux/iTerm2, teammateMode auto) routes notifications out of the stream so the modal can't be preempted; the live-gate net best-efforts + recovers in-process terminals (Ghostty/VS Code). Durable fix is upstream. Do NOT force-set teammateMode — it silently falls back to in-process. Scope/fragility: the content-validity catch assumes a preempted modal returns a detectably-invalid result (rejection/empty) — observed-consistent at n=2 this session, a sound basis for the recovery catch, not proven-universal. Proven on macOS/CLI; web/IDE entrypoint behavior is documented-not-tested. If a future Claude Code returns valid-looking stale content on preemption, the catch needs revisiting. -->
- Post-greenlight execution is autonomous — escalate only per the hard rules (tiebreaker, scope change, convergence failure, uncovered decision)
- **Use file-based input for PR bodies.** Run `mktemp` and capture its output as a single file path. Use that exact captured path string in every subsequent step: write the body to it via Write, then `gh pr create --body-file <captured-path>`, then `rm <captured-path>`. Do not regenerate the path between steps — one `mktemp` call binds one path used across all three operations. Inline `--body "$(cat <<EOF ...)"` triggers the bash safety heuristic and prompts unconditionally in auto mode. `mktemp` defends against symlink-race attacks on shared systems.
- When an explicit shutdown request has been received, delete the pulse THIS run owns after the team has been shut down: find it by its 8e signature (CronList) and CronDelete a single owned match; delete nothing if this run owns no pulse (the "leave it" path) or none matches (the terminal step may have deleted it); on multiple matches surface, never delete on ambiguity or a pulse you don't own (8e delete-ownership guard)
