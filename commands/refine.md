---
description: Run recursive refinement on the current branch and PR
argument-hint: <outcomes>
disable-model-invocation: true
---

# /swarm:refine

Recursive refinement on an existing branch and pull request. Skips Research/Converge/Approve/Execute — the team enters at Review, then Refine, then Deliver.

Pass outcomes inline (`/swarm:refine <outcomes>`) or run without arguments to be prompted.

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` for Step 0 (pre-flight), Step 1 (hard rules), and Steps 8a–8e (team creation, member spawning, pulse setup). This command replaces Steps 2–7 and overrides Step 8f.

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

2. **Outcomes.** If User-Provided Context is non-empty, use as outcomes. Otherwise ask the outcomes question (plain text, not AskUserQuestion). Echo the outcomes back verbatim — copy-paste, no condensation, no paraphrase — and use AskUserQuestion with options "Yes, that's what I meant" / "Let me add to this" / "Help me frame these as outcomes". If "Let me add to this", ask what they'd like to add (plain text), append it, and re-echo until confirmed. If "Help me frame these as outcomes", you MUST use the **Skill** tool to invoke `swarm:refine-outcomes` (passing the user's stated outcomes as `args`) — do NOT perform this step yourself; preserve the user's original words alongside the refined outcomes; then present both the original words and the refined outcomes to the user via AskUserQuestion ("Do these refined outcomes capture what you meant?" / "Let me adjust") before returning to Step 3 — a user who asked for framing help has no way to catch a bad interpretation otherwise.

3. **Confirmation.** Present the team plan summary as a blockquote (matching launch.md Step 7's format):

   > **Team Plan**
   >
   > **Mode:** Code
   >
   > **Outcomes:**
   > [confirmed outcomes verbatim]
   >
   > **Branch under review:** [current branch]
   >
   > **Diff base:** [PR base if found, otherwise the resolved default branch — e.g., `main`, `master`, `develop`]
   >
   > **PR:** [PR URL if found, otherwise `(no open PR detected)`]
   >
   > **Changes:** [the one-line diff stat captured in Step 1, e.g., `12 files changed, 340 insertions(+), 45 deletions(-)`]
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
   > **Ship definition:** [contents of `.claude/swarm-ship.md` if present, otherwise auto-detect per launch.md Step 8f rules]
   >
   > **Rules:** Active

   If the diff base is the default-branch fallback (no PR detected), add a distinct bold line below the summary so it is not missed: **Note:** no PR detected — diff base falls back to the repo's default branch (`<resolved-default>`). Verify before launch.

   Then AskUserQuestion: question "Is this plan final, or do you have remaining inputs?", header "Confirm", options "Launch the team" / "I have changes". Step 7 is mandatory.

   If the user picks "I have changes," surface the recoverability scope before re-prompting: the diff base (`<base>`) is inferred from the open PR or falls back to the repo's default branch and cannot be changed from this prompt. To use a different base, open a PR with the correct base branch or check out a different branch. Outcomes can be re-stated by re-entering Step 2; roster and tier are fixed for `/swarm:refine` and not adjustable.

4. **Launch.** Follow launch.md Step 8a (TeamCreate), Step 8b (invoke `swarm:code-mode`), Steps 8c–8d (spawn the four members named in the roster above), Step 8e (pulse). The `swarm:code-mode` skill returns the full Code-mode spec — for this command, **apply only the Refine and Deliver phase definitions from that spec; ignore the Research, Converge, Approve, Execute, and Review phase definitions, which are superseded by the inline arc in Step 5 below.** When pasting the user's input into briefings — the `[paste the user's original $ARGUMENTS or Step 2 input — full text, unmodified]` slot in the launch.md 8c/8d templates — substitute with: confirmed outcomes verbatim, then a `---` divider line, then `Branch under review: <branch>`, then raw `gh pr view` output (or `(no open PR detected)`), then a `---` divider line, then raw `git diff <base>...HEAD` output. **Paste raw output only — no lead-authored framing, commentary, or summary around the captures.** Do not add sections beyond the briefing template.

   After spawning, send the user a plain-text expectation-setter so they aren't dropped into silence (mirrors launch.md Step 8f). Example: "Team is launched — reviewers will inspect the diff and PR against the outcomes, and I'll check in when the first review round is in." If you reference any optional companion tooling (e.g., AgentChat for live agent-to-agent conversation), hedge it as optional ("if you have it installed") so first-time users don't think they're missing something essential. Keep it brief, use plain language, and do not use AskUserQuestion. Avoid internal scoring vocabulary like "rung 9" — first-time users have not seen it before.

5. **Phase arc (replaces launch.md Step 8f).**

   - **Review.** No Research, Converge, Approve, or Execute. The diff and PR context are already in the briefings. The lead's first message to the facilitator is the Review kickoff and serves as the implementation-complete equivalent in the launch.md 8c brief — facilitators looking for an "implementation complete" signal should treat this as the trigger. Send: "Review phase: the work to review is the diff and PR already in your briefing — this is the implementation-complete signal. Solicit reviews against the outcomes." The facilitator then solicits a review and confidence score from each non-lead, non-facilitator reviewer individually, probes each reviewer and the lead with "what is still missing?" before sending CONFIDENCE REACHED. If reviewers raise concerns, the lead fixes and the team re-reviews; the loop is autonomous.
   - **Refine.** Follows the Refine phase definition returned by `swarm:code-mode` at Step 8b verbatim. The "lead implements, team re-reviews" loop within Refine applies — only the lead writes code.
   - **Deliver.** Follows the Deliver phase definition returned by `swarm:code-mode` at Step 8b verbatim with three overrides specific to this command: (a) do not create a new feature branch — the work is already on the current branch; (b) if a PR already exists for this branch, do not open a duplicate — push commits to the existing PR; (c) after pushing, present a brief in-session summary to the user — the outcomes addressed, the rungs completed (e.g., 9 → 9.25 → 9.5 → 9.75 → 10), the key fixes per rung, and the PR URL. Do not post a comment on the GitHub PR unless the user requests it; the in-session summary is for the user's session, not the PR thread. If no PR exists and the ship definition calls for one, follow the file-based PR body pattern from the Deliver phase definition (the in-session summary still applies after the PR is opened).
