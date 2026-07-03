---
description: Run recursive refinement on the current branch and PR
argument-hint: <outcomes>
disable-model-invocation: true
---

# /swarm:refine

Recursive refinement on an existing branch and pull request. Skips Research/Converge/Approve/Execute — the team enters at Review, then Refine, then Deliver.

Pass outcomes inline (`/swarm:refine <outcomes>`) or run without arguments to be prompted.

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` for Step 0 (pre-flight), Step 1 (invoke `swarm:workflow-rules` — the governance spec), Steps 8a–8e (team creation, member spawning, pulse setup), and the **Universal rules that apply across all modes** in Step 8f — especially the governance spec's **Live-team gate prompts** rule (the AFK-timeout / durable plain-text-restatement recovery), which governs this command's decision gates (Finish, ship-approval) too. This command replaces Steps 2–7 and overrides Step 8f's phase arc — not those universal rules.

**No lead research unless enabled.** The pre-flight reads below are housekeeping, not research — they run unconditionally (analogous to launch.md's ship-definition detection). All other research is delegated to teammates.

## Settings

- **Mode:** Code
- **Outcomes question:** "What outcomes was this branch/PR supposed to achieve? (Describe what was meant to be working differently or better — the team will refine the work against these outcomes.)"
- **Cost tier:** Ultra
- **Lead research:** No
- **Roster (fixed):** Principal Engineer (facilitator), Correctness Reviewer, Outcomes Reviewer, Regression Reviewer

## User-Provided Context

$ARGUMENTS

## Workflow

1. **Pre-flight reads.** Run via Bash, capture each output as a raw string. Use the exact abort messages below — they are the user's only signal that something is wrong, so consistency matters across invocations.

   - `git rev-parse --is-inside-work-tree` — if not in a git repo, abort with: `Not in a git repository. /swarm:refine works on a branch and pull request.`
   - `git branch --show-current` — capture. If empty (detached HEAD), abort with: `Cannot run /swarm:refine in detached HEAD state. Run "git checkout <branch-name>" to switch to a branch first.` If equal to the repo's default branch (resolved via `git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null` then stripping `origin/`), abort with: `Cannot refine the default branch directly. Switch to a feature branch.`
   - `gh pr view --json title,body,baseRefName,url 2>/dev/null` — capture PR data if present. Extract `baseRefName` for the diff base. If no PR exists, fall back to the repo's default branch resolved earlier via `git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null` (stripped of `origin/`) — `master`, `develop`, or whatever the repo actually uses. Do not hardcode `main`. If `git symbolic-ref` itself returns nothing (no `origin/HEAD` set), abort with: `Cannot determine the default branch — origin/HEAD is not set. Run "git remote set-head origin -a" or open a PR with the correct base before re-running /swarm:refine.` Surface the fallback (whichever branch was resolved) explicitly in the Step 7 confirmation summary so the user can correct the base before launch.
   - `git diff <base>...HEAD` — capture. If empty (HEAD == base), abort with: `No changes detected between <branch> and <base>. Nothing to refine. If this is unexpected, verify the diff base is correct.` (substitute the actual branch and base names).
   - `git diff --stat <base>...HEAD | tail -1` — capture the one-line diff stat (e.g., `12 files changed, 340 insertions(+), 45 deletions(-)`) for the Step 3 confirmation summary. If the diff is empty this is moot — the empty-diff abort above fires first.

2. **Outcomes.** If User-Provided Context is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Do NOT echo the outcomes back verbatim — run the outcome reflection instead: You MUST use the **Skill** tool to invoke `swarm:reflect-outcome` with the user's exact words as `args`, and do not author its wording yourself. If it returns `NO FORK` (the common case), show nothing — no echo, no confirmation beat — and carry the outcome into the Step 3 plan-confirmation summary, which already displays the outcomes verbatim (that is where the user sees their words carried forward). If it returns a ready-to-render fork, present it with AskUserQuestion exactly as returned per the governance spec's transport contract (the fork is sealed at exactly two options) — then resolve the user's pick per the skill (Option A keeps the wording; Option B re-authors into a new verbatim, which loops back through this Step 2 reflection). Store no separate supplement. The user's verbatim words are captured for the briefs (launch.md verbatim-capture rule).

3. **Confirmation.** Render the **Plan gate** (refine variant) from the governance spec's Gate Presentation catalog with AskUserQuestion. Both modal carriers project from that entry:

   - **Question digest slots** (order fixed by the catalog — delta first): the diff base (the correctness pivot at this gate — silently inferred, not changeable from this prompt); the PR state (the PR URL, or `(no open PR detected)`); when the diff base is the default-branch fallback (no PR detected), this warning inline: `no PR detected — diff base falls back to the repo's default branch (<resolved-default>). Verify before launch.`; the compressed outcomes line (outcomes are adjustable at this gate via Step 2 re-entry); the scope line only if the reflection fork kept a pin (Option A — "\<their word> specifically"; omit entirely otherwise); the branch under review; the one-line diff stat captured in Step 1.
   - **Preview** (same markdown on both options — the fixed fields live here, not in the digest, because they cannot change at this gate):

   > **Team Plan**
   >
   > **Mode:** Code
   >
   > **Outcomes:**
   > [confirmed outcomes verbatim]
   >
   > **Team:**
   > 1. Team lead — (main session) [research: no]
   > 2. Principal Engineer — Socratic facilitator, read-only
   > 3. Correctness Reviewer — verifies logic correctness, edge cases, test coverage
   > 4. Outcomes Reviewer — verifies the work delivers the stated outcomes
   > 5. Regression Reviewer — verifies adjacent code and in-repo automation are not broken
   >
   > **Cost tier:** Ultra
   >
   > **Phase arc:** Review → Refine → Deliver
   >
   > **Ship definition:** [contents of `.claude/swarm-ship.md` if present, otherwise auto-detect per the governance spec's ship definition check]
   >
   > **Rules:** Active

   The digest one-liners (diff base, PR state, branch, diff stat) live in the question text at their only fidelity — do not restate them in the preview. Step 7 is mandatory.

   If the user picks "I have changes," surface the recoverability scope before re-prompting: the diff base (`<base>`) is inferred from the open PR or falls back to the repo's default branch and cannot be changed from this prompt. To use a different base, open a PR with the correct base branch or check out a different branch. Outcomes can be re-stated by re-entering Step 2; roster and tier are fixed for `/swarm:refine` and not adjustable.

4. **Launch.** Follow launch.md Step 8a (create the team — implicit at first spawn), Step 8b (invoke `swarm:code-mode`), Steps 8c–8d (spawn the four members named in the roster above), Step 8e (pulse). The `swarm:code-mode` skill returns the full Code-mode spec — for this command, **apply only the Refine and Deliver phase definitions from that spec; ignore the Research, Converge, Approve, Execute, and Review phase definitions, which are superseded by the inline arc in Step 5 below.** When pasting the user's input into briefings — the `[paste the user's original input — full text, unmodified]` slot in the governance spec's briefing templates (used at launch.md 8c/8d) — substitute with: confirmed outcomes verbatim, then a `---` divider line, then `Branch under review: <branch>`, then raw `gh pr view` output (or `(no open PR detected)`), then a `---` divider line, then raw `git diff <base>...HEAD` output. **Paste raw output only — no lead-authored framing, commentary, or summary around the captures.** Do not add sections beyond the briefing template.

   After spawning, send the user a plain-text expectation-setter so they aren't dropped into silence (mirrors launch.md Step 8f). Example: "Team is launched — reviewers will inspect the diff and PR against the outcomes, and I'll check in when the first review round is in." If you reference any optional companion tooling (e.g., AgentChat for live agent-to-agent conversation), hedge it as optional ("if you have it installed") so first-time users don't think they're missing something essential. Keep it brief, use plain language, and do not use AskUserQuestion. Avoid internal scoring vocabulary like "rung 9" — first-time users have not seen it before.

5. **Phase arc (replaces launch.md Step 8f).**

   - **Review.** No Research, Converge, Approve, or Execute. The diff and PR context are already in the briefings. The lead's first message to the facilitator is the Review kickoff and serves as the implementation-complete equivalent in the launch.md 8c brief — facilitators looking for an "implementation complete" signal should treat this as the trigger. Send: "Review phase: the work to review is the diff and PR already in your briefing — this is the implementation-complete signal. Solicit reviews against the outcomes." The facilitator then solicits a review and confidence score from each non-lead, non-facilitator reviewer one at a time (one reviewer, await the response, then the next), probes each reviewer and the lead with "what is still missing?" before sending CONFIDENCE REACHED. If reviewers raise concerns, the lead fixes and the team re-reviews; the loop is autonomous.
   - **Refine.** Follows the Refine phase definition returned by `swarm:code-mode` at Step 8b verbatim. The "lead implements, team re-reviews" loop within Refine applies — only the lead writes code.
   - **Deliver.** Follows the Deliver phase definition returned by `swarm:code-mode` at Step 8b verbatim with five overrides specific to this command: (a) do not create a new feature branch — the work is already on the current branch; (b) if a PR already exists for this branch, do not open a duplicate — push commits to the existing PR; (c) after the ship steps and the independent review loop, present a brief in-session summary to the user — the outcomes addressed, the rungs completed (e.g., 9 → 9.25 → 9.5 → 9.75 → 10), the key fixes per rung, and the PR URL. Do not post a comment on the GitHub PR unless the user requests it; the in-session summary is for the user's session, not the PR thread. If no PR exists and the ship definition calls for one, follow the file-based PR body pattern from the Deliver phase definition (the in-session summary still applies after the PR is opened); (d) the unified pre-ship gate and the `swarm:independent-review-loop` invocation from the Deliver definition apply here too; the independent review loop resolves its review scope **after the ship steps** — the PR if one now exists (the branch's pre-existing PR, or one just opened in Deliver), otherwise the branch against its resolved base — and commits each round's fixes (pushing to that PR per the ship definition) before the in-session summary; (e) order the inherited terminal step LAST — sequence Deliver as ship → independent review loop → in-session summary → terminal handshake (CronList→CronDelete the pulse, then the keep-open/shut-down question). For `/swarm:refine` the in-session summary IS the delivery artifact (no PR comment by default), so it must be presented before the keep-open/shutdown question — otherwise a "shut down" answer at the handshake would lose the summary.
