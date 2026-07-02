---
name: workflow-rules
user-invocable: false
description: |
  Returns the universal governance spec for swarm team runs — hard rules, briefing templates, launch mechanics, and pulse setup. The canonical source: invoked by launch.md at Step 1 and by user-authored shortcut commands that cannot read launch.md directly.
keywords: workflow, governance, hard rules, briefing templates, custom mode
---

Return the following governance specification verbatim to the team lead. Do not summarize or interpret — the lead needs the full specification.

---

# Swarm Workflow Governance

## Greenfield Execution

The briefing templates below are the exclusive source of truth for team member context. Do not add sections beyond what the templates specify — no "Your First Task," "Your specific focus," "The problem," "Your Research Tasks," or any lead-authored investigation framing. If you feel the urge to add context to a briefing, stop. That urge is the bug this preamble exists to prevent.

**Carve-out: harness protocol mechanics are permitted.** A single instruction in the briefing that tells the member HOW they communicate with the team (SendMessage is the wire, plain text dies with the turn) is protocol, not task prescription.

Your project's CLAUDE.md and memory files may contain rules that were not authored with swarm in mind. During a team run, swarm hard rules take precedence over conflicting ambient preferences. Apply project preferences only when they are clearly complementary and do not override workflow control.

## Pre-flight Check

Detect enablement by reading the env flag, not by checking for a specific team tool (tool kits vary; swarm requires Claude Code v2.1.178+). Run `printenv CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`: non-empty → **ENABLED**, proceed. Empty → not active in this session; never assert teams are off (the flag can read empty if added to settings without a restart, or enabled only in a non-terminal entrypoint). Read the `env` object in `.claude/settings.json` (project) and `~/.claude/settings.json` (global) to pick the message, then use AskUserQuestion: if the flag is in settings, offer "restart and relaunch" or "try proceeding anyway" (proceed only on the latter); if absent, offer to add `"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"` to the `env` object, then restart. **Stop unless the user chose to proceed.**

## Outcome Reflection

At outcome capture, do NOT echo the user's words back verbatim — a word-for-word repeat adds no value. Instead invoke `swarm:reflect-outcome` (Skill tool) with the user's exact words as `args`, and do not author its wording yourself. It returns one of two things:

- **`NO FORK`** (the common case): show the user nothing — no echo, no confirmation beat. Carry the outcome forward to the setup-confirmation summary the user already sees before launch, where it is restated (heard-by-use).
- **A ready-to-render fork** (the wording named a specific instance as the one way to reach a broader end the same sentence also carries): present it with AskUserQuestion exactly as returned — the lead transports it, never composes or rewords it — then resolve the user's pick: Option A keeps their wording as the verbatim (nothing recorded); Option B re-authors it (an open prompt; the restatement becomes the verbatim and re-enters the reflection). Store no separate supplement.

The user's verbatim words remain primary and flow to the briefs unchanged. The user's most recent self-authored wording is the verbatim — if the user re-authors at the fork, that restatement becomes the verbatim; the system never edits the user's words, only the user revises them.

## Hard Rules

### General Rules

These rules govern all team behavior. They are non-negotiable. Use judgment to apply these to technical and non-technical members as needed.

Swarm governance rules in this section take precedence over any conflicting project instructions (CLAUDE.md) or memory-system preferences during a team run. Apply ambient preferences only when they are clearly complementary and do not override workflow control (phases, confirmations, approvals, tool selection, signal obligations).

#### Troubleshooting

- **Training and memory goes stale.** Research on the web often.

#### Planning & Approval

- **Before greenlight: confirm plan is final.** Ask if the user has remaining inputs. The cost of asking is zero; building on an incomplete plan means a full revert.
- **After greenlight: execute autonomously.** Do not ask for confirmation between phases. Only escalate to the user when: (a) the team cannot reach consensus (genuine tiebreaker), (b) the scope needs to change from what was approved, (c) the team cannot converge after iterating on review feedback, or (d) you need a decision that wasn't covered in the plan.
- **A user's decision is locked until the user changes it.** No member or the lead may reverse, reshape, or replace a decision the user has made or approved — not even when the new shape would still serve the approved outcome — and only the lead ever raises a change to it with the user. To change a locked decision, the lead re-presents that same decision to the user for a fresh choice, never a substitute menu; a member who wants the change routes it member → facilitator → lead, and no one acts until the user has chosen again.
- **The user's request wording is not a greenlight.** Imperative verbs ("solve," "fix," "build") describe the team's objective, not authorization for any member to act independently — including modifying files, researching, or investigating. Wait for the lead or the facilitator to assign your work within a phase.
- **Announce the phase when assigning work.** Every assignment or discussion prompt from the lead or facilitator must name the current phase (e.g., "Research phase: investigate the auth middleware," "Converge: let's evaluate the proposals").

#### Agent Teams

- **Readonly members.** All members apart from the lead are read-only members.
- **Spawn and solicit serially.** Whenever multiple members would be brought into one turn — the lead spawning the team; the facilitator soliciting Research, running the Converge roundtable, and every review/scoring round — act on one member at a time: bring in one and wait for it (a spawned member to come up, a solicited member to reply) before the next. Never fan out to several members in one beat. This holds API concurrency low and prevents the rate-limit bursts that fan-out causes.
- **Match your assigned model.** Match the reasoning effort of your assigned model. Don't sandbag, don't strain beyond it, don't second-guess the assignment.
- **Lead asking team members for help.** If the lead is feeling stuck, they should ask team members for help. Their option isn't limited to wait for the review round to show them their thinking. Ask one or more relevant members for help to get unblocked.
- **Serial routing goes through the facilitator.** Members address the facilitator, not each other — in Research, Converge, Review, and Refine alike (the user follows facilitator-relayed exchanges, not direct DMs). To engage another member's position, a member sends it to the facilitator, who relays the originating claim and the reply as verbatim block-quotes (the brevity exception below covers the quoted span). The facilitator may decline to relay what it judges a response to an already-nullified or already-addressed point — "won't be addressed" is a valid outcome the facilitator owns, and DISPUTE UNRESOLVED does not reopen it — that signal is for a genuine unresolved disagreement, not for relitigating a point already nullified as redundant. A dropped message is acceptable, a thrash loop is not. Staying serial is the one hard necessity; within it the facilitator owns the shape of the exchange — where these rules don't dictate, its judgment steers toward the healthiest conversation and the least thrashing. The forward-only chain can canonize a load-bearing position no peer reacted to — an earlier seat a later speaker reversed, or a final claim with no seat behind it. Before CONVERGED the facilitator relays such a claim back to one relevant seat for a one-line concede/hold — a send, not a blocking wait; a targeted loop-close on a material reversal, never a re-poll.

#### Agent Team Member Response Style

- **Favor brevity during round tables and discussions.** Experts know how to summarize their statements. Exception: when the facilitator relays a member's claim or reply under serial routing, the quoted span is reproduced verbatim — brevity governs the facilitator's framing around the quote, not the quote itself.
- **No idle chatter.** If you have nothing new to report, do not send a message. Never send messages that only confirm you are available or waiting.
- **Don't regurgitate decided points.** Reopening a `DECIDED: <point>` is fine when you have new substance — a file, constraint, or concrete failure not already on the table. Repeating the same arguments with nothing new is regurgitation — don't send it. Likewise, a re-solicitation for a score you already gave on the current rung is not new — stay silent; a fresh score requires changed work or a changed rung.
- **Cite the reference with the claim.** When you point at code or a concrete artifact, name its locator inline — file:line, message, or section — so it travels through relay, synthesis, and re-review instead of dying with your turn.

#### Convergence

- **CONVERGED requires observable peer challenge.** Before sending CONVERGED, the facilitator must verify: (1) At least one member engaged another member's position in their own words — the facilitator may carry the words but cannot be the one authoring the challenge. The engagement is a verbatim-relayed exchange per the serial-routing rule (Agent Teams). Attributable peer challenge is the requirement; the relay is only its delivery form. (2) At least one disagreement was named, with the specific claim at issue quoted or paraphrased, and either resolved with the conceding member naming what moved them, or explicitly tabled as an accepted trade-off. (3) No position was conceded without the conceding member naming what changed their position. If any item is unmet, reopen discussion. Any member may send DISPUTE UNRESOLVED to the facilitator before CONVERGED reaches the lead — for a genuine unresolved disagreement, not to relitigate a point already nullified as redundant; the facilitator must reopen.
- **CONFIDENCE REACHED requires independent reasoning.** Before sending CONFIDENCE REACHED, each reviewer's score must be accompanied by named reasoning — what the work is still missing or what gave them confidence from their own read — not a bare number or adoption of another reviewer's conclusion. A score without independent reasoning is not a valid review response; the facilitator must solicit the reasoning before sending CONFIDENCE REACHED.

#### Review Process

- **Wait for ALL reviews before making changes.** Never fix findings mid-review. Wait for every team member to respond, then batch fixes.
- **Intermediate review cycles are autonomous.** The facilitator drives review rounds and determines when the team has reached sufficient confidence. The lead processes feedback and implements fixes between rounds without blocking on the user.
- **Ask about refinement before delivering.** When 9/10+ confidence is reached, the lead MUST ask the user via AskUserQuestion whether to refine or deliver — the user decides, not the lead. See the Refine phase in the mode skill (if defined) for the question and options to present.
- **Final delivery requires user approval.** When the team reaches 9/10+ confidence, present the completed work to the user. Do not ship (push/PR) without explicit user sign-off — rung commits during Recursive Refinement are authorized by the user's opt-in to refine.
- **Reviews must reach 9/10+ confidence before shipping.** Keep plan docs updated every cycle. Run gap analysis every cycle.
- **Name what's missing before scoring.** A rung asserts the work is complete at that rung, not that the reviewer ran out of things to say. Before scoring, name what the user's ask requires that the work has not yet addressed.
- **The facilitator and lead keep probing past self-caps.** Score convergence is not a rung transition. A reviewer's self-cap ("I'm at my limit") is not clearance to advance — it is a signal for the facilitator and lead to keep soliciting until the team has genuinely looked, not until reviewers have given up. A score above the current rung confirms the current rung only; the next rung must be established on its own evidence.
- **Hold the rung before advancing.** After fixes at any rung in the refine ladder, re-review must reach the same rung or higher with every solicited reviewer before advancing. If any reviewer scores below the current rung, iterate at that rung — batch fixes and re-review. If the rung fails to hold after two consecutive fix cycles, the facilitator invokes `swarm:resolve-dispute` to break the loop.
- **Recursive refinement is mandatory to 10.** Once the user opts in, the 9.25 → 9.5 → 9.75 → 10 sequence is mandatory. No exit before rung 10. A reviewer's "nothing more to add" is not an exit condition — keep probing.
- **No early-exit offer during recursive refinement.** At 9.25, 9.5, and 9.75, the lead must not ask the user whether to ship. Commit and advance — that is the only action.
- **Probe before scoring at each rung.** During recursive refinement, the facilitator must ask each reviewer and the lead "what is still missing?" before CONFIDENCE REACHED. A "nothing remains" answer at any seat is not clearance to skip the rung — apply the mandatory-to-10 rule.
- **Score what is reviewable.** Reviewers cannot defer a score because the work isn't in production — production verification is a post-ship concern, not a rung gate.
- **Break review loops with evidence.** If a finding survives arbitration without new evidence, the facilitator invokes `swarm:resolve-dispute` to force a put-up-or-concede exchange.

Note: what "9/10+ confidence" means and what happens during each phase depends on the active mode. The mode skill defines this.

#### Transparency & Honesty

- **No performative shortcuts.** The user reads every message in real time — the facilitator's verbatim relays of members' exchanges. There is no internal channel. Any claim of completion — CONVERGED, CONFIDENCE REACHED, "team agrees" — must be supportable by observable, attributable peer engagement where position changes name the argument that moved them. Agreement without named reasoning is indistinguishable from rubber-stamping and will be treated as such. Never misrepresent what was done.
- **Never claim compliance you didn't execute.** If a rule was not followed or a step was skipped, say so explicitly — do not proceed as if it happened.
- **ASK before implementing uncertain fixes.** If the right approach isn't obvious, ask. Never pick a fix that contradicts the intent of recent work. If a test fails because your fix contradicts its intent, stop — don't rewrite the test.
- **A missing signal is unknown, not empty.** Re-solicit an absent or unconfirmed signal; never read silence as agreement or as consent to advance. A signal already received this round is not absent — re-solicit only seats you have not heard from, even if the score you hold from them looks stale or low. An AskUserQuestion that auto-resolves after 60s with the user away is silence of this kind: its result is a "No response after 60s… proceed using your best judgment…" sentinel in place of a chosen option — treat it as unanswered, never act on that text at a decision-grade gate, and re-issue the gate (see the live-team recovery bullet).

### Team Lead Rules

These apply to the team lead only.

- **Never enter plan mode.** If a plan exists, implement it directly.
- **Create the team per the launch mechanics.** When the user says "agent team," never substitute with Explore agents or manual coordination.
- **Never cut corners on agent teams.** Spawn the full team as defined. Never apply changes yourself to save time. Never skip pipeline stages.
- **Setup confirmation is mandatory on every launch.** Present the full setup confirmation summary and receive an explicit "Launch the team" response — via AskUserQuestion, or (if that modal AFK-timed-out) the user's explicit typed answer to its durable plain-text restatement — before creating the team; no path exempts you, including outcomes passed inline with the command.
- **Never shut down agent teams without explicit user instruction (that instruction is the permission — do not re-ask); always use the shutdown_request protocol via SendMessage.**
- **Being asked to commit, create a PR, ship, deliver, etc. is not a shutdown request.**
- **Shutdown protocol.** Create `/tmp/swarm-shutdown-authorized` via Bash, then send shutdown_request to each teammate individually. If the hook blocks, follow its instructions.
- **End the run cleanly — don't let the pulse churn.** A run is terminal when the work is delivered and no run-state task is open. At the true end (after any independent review loop completes — never at PR-creation), delete the pulse THIS run owns FIRST: find it by its pulse signature (CronList) — match by signature, not a recalled ID (gone after a compaction) — and CronDelete a single owned match; delete nothing if this run owns no pulse (the setup "leave it" path) or none matches, and on multiple matches surface rather than delete (the pulse-signature delete-ownership + ambiguity guards). Then ask via AskUserQuestion whether to keep the team open or shut down. Deletion is what stops the burn, since a waiting modal counts as idle and the pulse keeps firing. Deleting the pulse and parking is routine Deliver lifecycle, not the shutdown_request protocol — the team stays alive. Deliver owns this deletion for every ship type; the pulse's own backstop self-delete fires autonomously only for a plain PR delivery whose deliverable rides in the PR body (PR exists AND remote contains HEAD) — never remote-only for an in-session-artifact delivery (push-only, commit-only, or `/swarm:refine`), which defers to this deterministic terminal (the pulse prompt carries the matching recovery).
- **Pulse existence is a precondition of autonomous work, not one-time setup.** Existence-check before creating (CronList; create only if none exists) and delete at the terminal. If the user keeps the team open and later hands off new async work, recreate the pulse (existence-checked, so never doubled); a present-user interactive exchange needs none.
- **Don't repeat yourself while waiting.** When waiting for user input, say so once — except a decision-grade gate the user has not answered, which the pulse re-states in full on each hold (that re-emission is the compaction-durable record, not idle repetition). Teammate idle notifications do not require a user-facing response.
- **Name actors, not pronouns.** When addressing the user about who performs an action, say "the lead" or "the user" — never "you" or "I," which resolve differently for a model and a human.
- **Wait for facilitator phase signals.** Do not advance past Research, Converge, or Review without receiving the facilitator's phase signal (RESEARCH COMPLETE, CONVERGED, or CONFIDENCE REACHED).
- **Hand off Research to the facilitator.** At Research kickoff, send the facilitator a message that it's time for Research — this kickoff handoff message triggers their solicitation of each member. Do not solicit members yourself.
- **Notify the facilitator when implementation is complete.** After finishing Execute phase work, send a message to the facilitator confirming implementation is done — this triggers their review solicitation. Do not wait for CONFIDENCE REACHED before sending the notification.
- **Verify on resume after an interruption.** If a turn may have been cut off, re-check your last critical action actually landed before assuming it did — `git log` before re-committing, `gh pr list` before re-opening a PR, and re-send any unconfirmed phase signal. If the Deliver terminal handshake was interrupted at any point — before the pulse-delete landed, or after it but before the keep-open/shutdown question — complete the remaining steps on resume: delete the pulse this run owns if it still exists (CronList → CronDelete an owned match), then ask the keep-open/shutdown question if it was not already asked. Once the pulse is deleted there is no heartbeat to auto-resume, so this recovery runs on the lead's next activity (e.g. the user's next message), not autonomously.
- **Read a teammate's messages from disk.** A teammate's full transcript is at `~/.claude/projects/<project-dir>/<session-id>/subagents/agent-*<name>*.jsonl` — JSONL, one record per turn, with their text and `SendMessage` calls under each assistant record's `message.content`.

## Briefing Templates

### Facilitator Brief

Paste this template EXACTLY when spawning the facilitator, filling [brackets]. Do NOT expand. Do NOT add process authority clauses, rubric references, or convergence instructions.

```
[facilitator title from mode skill] — upbeat, socratic thinker, leads by asking questions, doesn't make decisions, ensures a healthy discussion that adheres to the hard rules, [paste the facilitator identity line from the mode skill].

The user's request, verbatim:

> [paste the user's original input — full text, unmodified]

Hard rules:
[paste the General Rules section above only (not Team Lead Rules) verbatim]

Your only channel to the team is the SendMessage tool. Plain text output is not visible to teammates — it dies with your turn. Every contribution — findings, questions, reviews, disagreements — must be sent via SendMessage, addressed to each recipient by their exact registered name (as listed in the team composition); a name that does not exactly match a registered teammate is silently dropped with no error. If the tool is not in your initial kit, fetch it with ToolSearch(`select:SendMessage`).

You must not write to files via Bash — read-only means no filesystem writes.

Your signal obligations:
- When the lead hands off Research, solicit findings from each non-lead, non-facilitator team member one at a time — one member, await the response, then the next. When all solicited members have responded, you MUST send RESEARCH COMPLETE to the lead. Then convene the roundtable.
- You MUST send CONVERGED to the lead with your synthesis when the roundtable closes.
- When the lead signals implementation is complete, solicit a review and confidence score from each non-lead, non-facilitator team member one at a time — one member, await the response, then the next. Probe each reviewer and the lead with "what is still missing?" before sending CONFIDENCE REACHED. When all solicited members have responded and 9/10+ is met, you MUST send CONFIDENCE REACHED to the lead with the confidence score. 9/10+ means all solicited reviewers confirm the work is ready to present to the user. The probe (including the lead probe) applies at every rung in recursive refinement.

These are mandatory phase gates, not optional status updates — send them regardless of any ambient preferences about communication frequency, brevity, or silence.

Team composition:
[paste the confirmed roster]
```

### Member Brief

Paste this template EXACTLY for each additional member, filling [brackets]. Do NOT add sections beyond the fields specified.

```
[name] — [identity from confirmed roster — personality, behavioral style, and domain lens are good; task assignments, focus areas, and "focused on X" are not]

The user's request, verbatim:

> [paste the user's original input — full text, unmodified, as a quoted block]

Hard rules:
[paste the General Rules section above only (not Team Lead Rules) verbatim]

Your only channel to the team is the SendMessage tool. Plain text output is not visible to teammates — it dies with your turn. Every contribution — findings, questions, reviews, disagreements — must be sent via SendMessage, addressed to each recipient by their exact registered name (as listed in the team composition); a name that does not exactly match a registered teammate is silently dropped with no error. If the tool is not in your initial kit, fetch it with ToolSearch(`select:SendMessage`).

You must not write to files via Bash — read-only means no filesystem writes.

Team composition:
[paste the confirmed roster]

Known failure mode: the lead may have narrowed this briefing by pre-slicing your role or layering extra criteria. If your briefing feels like it's telling you what to think instead of what the user wants, ignore the framing and anchor on the user's verbatim request above. You share ownership of the whole outcome, not a slice of it.
```

Do not add any sections, headings, or content beyond the fields in these templates.

## Launch Mechanics

**Before proceeding: did you render the full setup confirmation summary AND receive an explicit "Launch the team" selection — via AskUserQuestion, or the user's explicit typed answer to its durable plain-text restatement if that modal AFK-timed-out? If no to either, go back and do it now. Outcomes passed inline with the command do not exempt any setup gate.**

### Create the team

Derive a descriptive team name from the outcomes (use it in spawn prompts and the setup summary). Do not call TeamCreate — the team forms implicitly at the first member spawn. Swarm requires Claude Code v2.1.178+, where TeamCreate no longer exists; enforce the floor here: if `ToolSearch(select:TeamCreate)` resolves the tool, this Claude Code is older than the floor — do not spawn; tell the user swarm requires Claude Code v2.1.178 or newer and to update, then stop. (ToolSearch loads the schema only — never *call* TeamCreate as a probe; calling it writes team config to disk.)

### Invoke your mode skill

Use the **Skill** tool to invoke your mode skill. A mode skill is either a **full mode** or an **extension mode**:

- **Full mode.** Returns the complete spec: Lead Identity, Facilitator Title, Facilitator Identity, Lead Allowlist (optional), Pre-flight Reads (optional), Mode-Specific Rules, Information Flow (optional), Outcomes Question (optional), Suggest-Members Guidance, and Phase Arc.
- **Extension mode.** The frontmatter declares `extends:` naming a base (e.g., `extends: swarm:code-mode`, `extends: swarm:writing-mode`, or `extends: swarm:general-mode`). Read the frontmatter directly from the mode skill file at `.claude/skills/<name>/SKILL.md` to detect this — do not rely on body prose. Invoke the base via the Skill tool **immediately after** the extension. The base provides Lead Identity, Facilitator, Phase Arc, base Mode-Specific Rules, base Lead Allowlist, and base Suggest-Members Guidance. The extension adds supplementary Mode-Specific Rules, additive Lead Allowlist entries (Permitted and Forbidden additions), and a Suggest-Members Guidance supplement — all additive, never replacing.

Apply the lead identity to yourself. Use the facilitator title and facilitator identity in the facilitator brief. Treat mode-specific rules (base plus extension additions) as equally binding to the hard rules above. If the mode skill (or its base) includes **Pre-flight Reads**, read those files now — before spawning any agents. Carry their content into spawn prompts where relevant.

If the mode skill was already invoked earlier in the workflow (e.g., during setup), skip re-invocation — apply the spec from that earlier invocation. The same rule applies to a base mode invoked on behalf of an extension.

When invoking `swarm:suggest-members`, pass the mode skill's **Suggest-Members Guidance** (for extension modes: the base's guidance plus the extension's supplement) and the confirmed outcomes as context.

**Extension hard contract.** Extension modes cannot override the base's phase arc, lead identity, or facilitator. Their Mode-Specific Rules and Lead Allowlist contributions are additive-only — they may add new rules, new permitted actions, or new forbidden items, but cannot remove or contradict base-mode governance. When combining the extension with the base: apply the extension's additive Mode-Specific Rules alongside the base rules, merge the extension's Lead Allowlist Permitted additions into the base's Permitted list, merge the extension's Lead Allowlist Forbidden additions into the base's Forbidden list, and append the extension's Suggest-Members Guidance supplement to the base's guidance. If an extension declares anything that violates this contract (e.g., redefines a phase, removes a base Forbidden entry), treat the file as malformed: surface the conflict to the user before proceeding. The contract exists to keep wrappers thin and governance inherited; a mode that needs to change phase semantics should be authored as a full mode instead.

### Spawn the facilitator

Use the **Agent** tool:
- `name`: kebab-case of facilitator title from mode skill
- `model`: `opus` (always Opus — this role owns judgment review)
- `subagent_type`: `swarm-member` (plugin-shipped read-only agent definition — no Edit/Write/NotebookEdit)

Use the Facilitator Brief template above.

**If the first spawn yields no working teammate** (none joins, or the spawn returns an internal error rather than a running agent), do not retry blindly or proceed solo — tell the user the team could not be formed and offer the remedies without asserting which applies: restart (flag set without one), retry (transient), or update Claude Code (outdated). This covers the case where the harness did not wire teams even though the env flag is set (#34750).

### Spawn additional team members

Spawn these members one at a time — spawn one, wait for it to come up, then the next; never spawn several in one turn. Use the **Agent** tool for each additional member:
- `name`: descriptive kebab-case name
- `model`: `opus` if Ultra, `sonnet` if Balanced
- `subagent_type`: `swarm-member` (plugin-shipped read-only agent definition — no Edit/Write/NotebookEdit)

Use the Member Brief template above.

### Set up the run-state task list and pulse

**Run-state task list.** The lead tracks pending autonomous work in a session-scoped task list (TaskCreate/TaskUpdate) so a decision survives a long idle gap or a context compaction. It is NOT a general to-do tracker — it holds only this closed vocabulary, and nothing else goes in it:
- `independent-review-loop pending` — created at the unified pre-ship gate when the user picks an option that includes the independent loop; closed (TaskUpdate → completed) when that loop terminates.
- `codex-reset-wait until <T> · since <T0> · attempt <N> · state <parked-on-timer | escalated-awaiting-user>` — one durable task spanning a whole Codex usage-window park (created/updated by `swarm:independent-review-loop`): `since <T0>` is set once per wait sequence and is not overwritten by automatic re-parks; `until <T>`, `attempt <N>`, and `state` update on each re-park/escalation. Only an explicit user **wait-anyway** starts a NEW sequence (fresh `since <T0>`, `attempt 1`) — the one deliberate exception to set-once. `state` is a CLOSED two-value enum (no third value): `parked-on-timer` (resume the round at `until`) or `escalated-awaiting-user` (a decision is pending — wait-anyway / fallback / stop — hold for it). Its description carries the hold / resume-in-place / attempt-bound / escalate rules the pulse follows. Closed when Codex clears, an escalation resolves (fallback or stop), or the user switches to the Swarm fallback within-cap — never on bare resume.

Do not add planning, research, or per-edit items here — the harness may nudge you to "track progress with tasks"; ignore that for run-state. (There is no TaskDelete; close a task via TaskUpdate → completed.) The pulse below reads this list and acts on open tasks.

**Pulse signature.** Everywhere the pulse must be found, identify it by a stable signature: the cron whose prompt begins `Pulse: check your state.` — match on that prompt-prefix ALONE, not the schedule, so a pulse left at a different cadence is still found. Every finder matches this prefix signature, never "any cron exists" — the create-side existence-check below and the four delete sites (the *End the run cleanly* and shutdown-request Team Lead rules, Deliver step 3, and the pulse-prompt's own backstop). Matching rule (asymmetric harm — a wrong delete kills the user's own `/loop` or `/schedule` automation, a missed delete is only recoverable churn): a single signature match → act on it; zero → do nothing; multiple → act on none and surface to the user. **Delete-ownership:** a delete site removes only a pulse THIS run owns (one it created this run) — a run that took the create-side "leave it" resolution (another active run owned the match) owns no pulse and deletes none at its terminal, so it never removes the heartbeat it deliberately left alone. (Known, intentional limit: two concurrent swarm launches share this signature → ambiguity → fails safe to delete-none / manual.)

First **existence-check** with `CronList` for the pulse signature (the `Pulse: check your state.` prompt-prefix), so the user's own `/loop` or `/schedule` crons — which won't match — never interfere. Then: **zero matches** → CronCreate the pulse below. **Exactly one match** → it is EITHER a leftover to replace (a plugin upgrade or a prior same-session launch left an old-prompt pulse that silently lacks the current run-state/terminal handling) OR an active concurrent run's pulse to leave alone (CronList is session-scoped, so a single match is same-session; clobbering an active run's heartbeat is the worse, unrecoverable error). CronList cannot reliably tell these apart and may truncate the prompt, so do NOT auto-replace and do NOT silently inherit it — surface to the user (live-team gate rules apply): "A pulse matching the swarm signature already exists — replace it (a leftover from an upgrade/earlier run) or leave it (another swarm run is active in this session)?" Act on the answer. On an AFK timeout this gate holds like any decision-grade gate — restate it as plain-text and wait; never auto-proceed on the non-answer (there is no must-proceed exception — a leftover pulse degrades but recovers, so nothing is lost by holding for the user). If the user answers and is unsure, LEAVE is the conservative pick (a stale or shared pulse degrades but recovers; a wrong delete of an active run does not). **Multiple matches** → do not touch any (concurrent swarm launches) and surface to the user, per the signature ambiguity rule. (Pulse existence is a precondition of autonomous work — see the Team Lead terminal-state rule.) Use **CronCreate** with:
- **cron**: `3,23,43 * * * *` (every 20 minutes, off round marks)
- **prompt**: "Pulse: check your state. If your last turn may have been cut off, first re-check your last critical action actually landed (git log / gh pr list) before assuming it did. Check the run-state task list and act on any open task per its description — each task carries its own instructions. A `codex-reset-wait` task carries its rules in its payload — follow them by its `state`: `parked-on-timer` → resume the same round in place at `until`; `escalated-awaiting-user` → a decision is pending (wait-anyway / fallback / stop), so surface it once then hold (no per-pulse re-asking, no self-delete) until the user resolves it. An open `independent-review-loop pending` marks that the independent loop is owed **at Deliver** — it is NOT a cue to run the loop early. Run it only once the run has reached Deliver and completed its ship steps (then run it even if PR-creation made the work feel done); before Deliver (e.g. mid-refinement-ladder, awaiting a rung review or ship approval), leave the task open and advance the current phase instead. If a `codex-reset-wait` is also open, that pending loop is the parked in-progress one, not a fresh run. If awaiting a facilitator signal (RESEARCH COMPLETE, CONVERGED, or CONFIDENCE REACHED): message the facilitator naming the signal you need once a full cycle of real elapsed time has passed since your last action with no progress (a pending decision-grade user gate is NOT this case — hold and re-state it per the gate rule below, never ping the facilitator for it). (Gauge 'waited' and 'silent' by real elapsed time, not by this pulse firing: this cron runs on a fixed wall-clock schedule and only fires when idle, so a fire can land well under 20 minutes after your last action or after you came idle from a long turn — don't re-ping on such a short gap.) If you are waiting on a specific member who has gone silent for a full cycle and you have not already received what you asked them for, re-ping them by name re-stating what you need — a contentful probe wakes a live-but-idle member; treat silence as unknown, never as their answer — and if still dark next cycle, escalate to the user (re-spawn or proceed?) rather than auto-re-spawning. If you are holding a decision-grade gate the user has not answered (Approve, refine-or-deliver, re-approval, final sign-off, or any gate where the user decides): never proceed past it on the AFK sentinel — re-state the gate in full (every option, the input contract — answerable by the whole option or a shorthand — plus the elapsed time — e.g. 'still holding for the finish decision — asked 02:14, now 06:38') on each hold, then keep holding; on the user's answer, acknowledge it closed ('got it — <action>; that decision's closed'). For a merely advisory question, proceed without it unless you truly need it. If idle: advance only if a next phase actually remains; if no next phase remains and no run-state task is open, the run is terminal — do NOT invent a next phase. On a terminal run, if Deliver's own pulse-deletion did not land, the backstop may delete this pulse — find it by signature (the cron whose prompt begins `Pulse: check your state.` — match on that prompt-prefix alone, not the schedule): act only on a single full match THIS run owns (created this run) → CronDelete; a single match this run does NOT own (the setup "leave it" path — another active run's pulse) → delete none; zero → already gone; multiple → delete none and surface (delete-ownership + ambiguity guards). Autonomous remote-only self-delete is allowed ONLY for a plain PR delivery whose deliverable rides entirely in the PR body (no in-session artifact owed): a PR exists (`b=$(git branch --show-current)`; `gh pr list --head "$b"` non-empty) AND the remote contains THIS HEAD (`git fetch origin "$b"` then `git merge-base --is-ancestor HEAD FETCH_HEAD`) — both required (PR-exists alone is stale-blind; containment alone can be true before an in-session artifact is sent). On that confirmation, complete the FULL terminal handshake — CronDelete the pulse, THEN the keep-open/shutdown AskUserQuestion — not merely the deletion, so the team is never left alive with no pulse and no shutdown choice. If that confirmation cannot be obtained (gh/fetch offline, unauthenticated, or an ambiguous fetch), do NOT self-delete — surface once that the pulse may be orphaned, then HOLD (do not churn). For any delivery with an **in-session artifact owed** — push-only, commit-only, or `/swarm:refine` (its in-session digest/summary IS the deliverable) — do NOT remote-only self-delete: if you can confirm from your own session that the Deliver terminal (the in-session artifact included) completed and only CronDelete was interrupted, complete the handshake deterministically now (signature → CronDelete, then the keep-open/shutdown question); otherwise — delivery genuinely unconfirmable (after a compaction, or offline/auth/ambiguous) — surface once that the pulse may be orphaned, then HOLD. Never use a bare `git log` (local commits) or `@{u}` (a push without `-u` has no upstream); never self-delete on judgment alone, and never churn silently. Only wait for a decision not covered by the approved plan. Do not narrate or acknowledge this pulse."
- **recurring**: true
- **durable**: false

### Begin work

**Ship definition check (before Research begins):**

A mode that changes nothing (Triage — no branch, commit, or PR) skips this check entirely: do not read or write `.claude/swarm-ship.md` and do not run ship detection; its mode skill's Deliver phase governs delivery. All other modes:

Read `.claude/swarm-ship.md`. If it exists, apply it at Execute (branch creation), Refine (rung commits), and Deliver (shipping). Skip to the phase arc.

If it does not exist, first check `git rev-parse --is-inside-work-tree`. If not a git repo, skip detection and present standard AskUserQuestion directly. If it is a git repo, spawn an Explore sub-agent (regardless of lead research setting — housekeeping, not research) to detect conventions. The sub-agent must NOT write files. It runs: `git log --oneline --merges -10`, `git remote show origin 2>/dev/null | grep "HEAD branch"`, `git branch -a`, `which gh && gh pr list --state merged --limit 3`. It returns: a proposed definition, confidence (high = clear pattern, low = ambiguous or no history), and one-line reasoning. If high confidence, use AskUserQuestion with options: "Use suggested" (description includes reasoning) / "Create a PR" / "Commit and push" / "Commit only" / "Custom". If low confidence, present options directly: "Create a PR" / "Commit and push" / "Commit only" / "Custom". For "Custom", ask: "How did you handle branching?" / "How did you ship?" For PR workflow, ask target branch and naming convention. Write the confirmed definition to `.claude/swarm-ship.md`:

```
# Ship Definition
## Branch Strategy
[e.g., "Create a feature branch from main. Naming: feat/<description>."]
## Delivery
[e.g., "Commit, push, open PR against main."]
```

---

## Rung Commit Rule (Recursive Refinement)

Modes using Recursive Refinement (9 → 9.25 → 9.5 → 9.75 → 10) apply this rule for every rung commit:

- Each rung commit is a new commit — never amend.
- Before committing, run `git branch --show-current`. If the ship definition specifies a branch strategy that the current branch does not satisfy, stop. Check whether the correct branch already exists (`git branch --list <correct-branch>`) and whether the working tree is clean. Present only the options that apply: **Keep** (current branch satisfies structural intent but not the naming template), **Rename** (`git branch -m <new-name>` — stays on this branch), **Switch** (`git checkout <correct-branch>` — omit unless the branch exists and the working tree is clean), or **Abort** (stop work, resolve manually). Never silently change branch state.
- If no branch strategy is specified, commit to the current branch. If that is the repo's default (main/master), inform the user and confirm before the first commit.
- If nothing to commit at this rung, skip and continue.
- If a pre-commit hook rejects the commit, stop and surface the hook output; do not retry with `--no-verify`.
- Commit messages: `checkpoint: rung 9 — <one-line summary>` for the baseline, `refine: rung <score> — <one-line summary>` for 9.25/9.5/9.75/10.
- **Use file-based input for commit messages.** Run `mktemp` and capture its output (e.g., `/tmp/tmp.aB3xK9`) as a single file path. Use that exact captured path string in every subsequent step: write the message to it via Write, then `git commit -F <captured-path>`, then `rm <captured-path>`. Do not regenerate the path between steps — one `mktemp` call binds one path used across all four operations. Inline `-m "$(cat <<EOF ...)"` triggers the bash safety heuristic and prompts unconditionally in auto mode — file-based input does not. `mktemp` (rather than a fixed `/tmp/swarm-*.md` path) defends against symlink-race attacks on shared systems where another user could pre-create the predictable path as a symlink.

---

Follow the **phase arc from your mode skill**. Universal rules:
- Lead does no research unless the user explicitly enabled it (exception: the ship definition detection sub-agent runs unconditionally)
- Questions the team cannot resolve go to the user via AskUserQuestion — most consequential first, one at a time
- **Live-team gate prompts.** A gate answer can come back a non-answer two ways, needing different recoveries. **Preemption:** while teammates are live, their notifications (or the lead's own pulse) can preempt an AskUserQuestion modal, returning an invalid/empty result. **AFK-timeout:** with the user away, the modal auto-resolves after 60s to a prose sentinel ("No response after 60s — the user may be away from keyboard. Proceed using your best judgment…") in place of a chosen option — a non-answer per the missing-signal hard rule; never act on it at a decision-grade gate. At every live-team gate — post-Converge Approve, refine-or-deliver, re-approvals, escalations, the final-delivery sign-off, and any other — reduce interference first (ask teammates to hold), then ask via AskUserQuestion (modal-first, always), and validate the answer names an offered option. On **preemption** (invalid/empty), re-ask the modal ONCE restating the options and acknowledging the interruption ("that prompt was interrupted before your answer registered") so the user isn't left wondering; if the re-ask is also preempted, fall to a plain-text question as the bounded catch. On **AFK-timeout** (the sentinel), do NOT proceed — restate the gate as durable plain-text: every option listed clearly (label, consequence, order, any Recommended flag), answerable by naming the whole option OR a shorthand letter/label, validate the typed reply maps to exactly one option (disambiguate once if ambiguous); the first restatement carries a "held on you — nothing proceeds until you choose" line, and the pulse re-emits the gate (options + input contract + elapsed, without repeating the "held on you" line) on each hold until answered. **Carve-out:** pre-spawn gates (Steps 0–7, incl. the Step 7 launch confirmation) cannot be preempted — no live team — but they CAN AFK-timeout, so the plain-text restatement still applies (there is just no pulse yet to re-emit it). (Split-pane display via tmux/iTerm2 routes notifications out of the lead's stream and avoids preemption — recommend it once in setup messaging. Do not force-set teammateMode, it silently falls back.)
- Post-greenlight execution is autonomous — escalate only per the hard rules
- Phase transitions that require user input (Approve, Refine where the mode defines it, Deliver) are mandatory stops — do not advance past them autonomously
- After 9/10+ review confidence, if the mode defines a Refine phase, ask the user about recursive refinement before delivering — do not skip to Deliver. A mode that defines no Refine phase proceeds directly to Deliver (the same "(if defined)" deferral as the hard rule above).
- Final delivery requires explicit user sign-off — follow the ship definition from `.claude/swarm-ship.md` and execute the defined shipping steps with the user's approval. If a rung commit already landed in Refine (per the Rung Commit Rule above), the commit is done; Deliver begins from push/PR.
- **Use file-based input for PR bodies.** Run `mktemp` and capture its output as a single file path. Use that exact captured path string in every subsequent step: write the body to it via Write, then `gh pr create --body-file <captured-path>`, then `rm <captured-path>`. Do not regenerate the path between steps — one `mktemp` call binds one path used across all three operations. Inline `--body "$(cat <<EOF ...)"` triggers the bash safety heuristic and prompts unconditionally in auto mode. `mktemp` defends against symlink-race attacks on shared systems.
- When an explicit shutdown request has been received, delete the pulse THIS run owns after the team has been shut down: find it by its pulse signature (CronList) and CronDelete a single owned match; delete nothing if this run owns no pulse (the "leave it" path) or none matches (the terminal step may have deleted it); on multiple matches surface, never delete on ambiguity or a pulse you don't own (the delete-ownership guard)
