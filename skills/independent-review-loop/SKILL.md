---
name: independent-review-loop
user-invocable: false
description: |
  Independent review loop run before delivery in code work. An independent reviewer (Codex, or fresh Codex-style subagents) reads the whole PR against the approved outcome; the lead fixes in-scope functional findings and re-reviews until none remain. The bug-surface counterpart to recursive refinement (which drives completeness). Invoked by the team lead from the unified pre-ship gate (code-mode and /swarm:refine) after the PR exists.
keywords: independent review, codex review, review loop, pre-delivery review, bug surface, edge cases
---

Operational spec for the **team lead**. This skill runs an independent review pass at delivery: a reviewer that fails differently from the author reads the whole PR against the approved outcome, the lead fixes what is in scope, and the loop repeats until the reviewer finds no more in-scope functional issues. It is the automated form of "ship, then loop the PR through Codex until it stops finding edge cases" — with the lead acting as the operator who keeps findings on-scope.

It is the **bug-surface** counterpart to recursive refinement: recursive refinement (the 9.25→10 rung ladder) drives the work to the full scope of the outcome (completeness); this loop drives out functional defects via an *independent* reviewer (correctness). They are distinct passes; this never replaces the ladder.

Only the lead runs this. Reviewers (Codex, or fresh subagents) are read-only; the lead is the sole writer, same as every other phase.

## When this runs

Invoked from the **unified pre-ship gate** in code-mode's Refine/Deliver (and `/swarm:refine`) — the gate the lead presents once the team reaches 9/10+, offering: *recursive review + independent review* / *independent review loop only* / *ship as is*. This skill runs for the first two options (after the recursive ladder completes, when both were chosen; or on its own when only the independent loop was chosen).

It runs **after the PR has been created** (PR-then-loop): the loop reviews the existing PR's diff and pushes each round's fixes to that PR. Because the PR exists, the diff base is always resolvable from it.

## Engine choice (Codex or Swarm fallback)

When invoked, select the reviewer engine with **AskUserQuestion** (header "Reviewer"). Detect Codex once: `command -v codex` (exit 0 = present). Offer **both engines every time** — `command -v codex` only sets the **order/default** and a neutral note. No affordability language, ever. ("No loop" is not offered here — that is the gate's "ship as is.")

- **Codex present** → 1) "Codex" 2) "Swarm fallback".
- **Codex absent** → 1) "Swarm fallback" 2) "Codex *(requires Codex CLI)*".

Descriptions (neutral): Codex = "An independent model (Codex) reviews the whole PR; fails differently from the code's author." Swarm fallback = "A fresh Claude reviewer in a Codex style — sharp, but shares the author's model blind spots; always available, no Codex needed."

If the user picks Codex while it is absent/unauthed, surface Codex's own message + how to enable (`codex login`, or install per Codex's docs) once, then offer the Swarm fallback or stopping — never hang. While this gate is live and teammates exist, apply the launch.md live-team gate rules (ask teammates to hold; re-ask once if the modal is preempted).

## The loop (identical control flow on both engines)

The PR already exists, so the diff base is the PR base: `gh pr view --json baseRefName`. (Edge case: a ship definition that creates no PR — e.g. commit-only — has no PR base; fall back to the repo default branch via `git symbolic-ref refs/remotes/origin/HEAD --short` stripped of `origin/`, and if that is unset, ask the user for the base or skip the loop. Do NOT error.) Then each round:

1. **Review the WHOLE PR diff, every round** — the full `git diff <base>...HEAD`, never just the delta since the last fix. New findings hide behind old fixes; only a whole-PR pass surfaces them.
2. **Collect findings** in Codex's native shape (see Output format).
3. **The lead triages each finding against the approved outcome** — the lead is the codified "operator once in a while":
   - Bears on the outcome and is a real functional defect → **fix it** (lead writes the change).
   - Out of scope (new feature, adjacent refactor, gold-plating, pre-existing issue, style) OR genuinely ambiguous → **do not fix; add to the out-of-scope pile.** When unsure, surface — never silently drop and never silently fix.
4. **Surface the out-of-scope pile to the user** (plain text) at the end of the loop, or immediately if a pile item is consequential (a real defect you're declining because it exceeds the approved outcome) — that is the rare operator escalation the user asked for. The diff may legitimately grow toward outcome-completeness (e.g., fixing an off-diff caller the outcome requires); that growth is bounded by the outcome, grounded in `git diff --stat <base>...HEAD`, and surfaced — not silent scope expansion.
5. **Commit AND push this round's fixes to the PR, then re-run.** The review reads the *committed* `git diff <base>...HEAD`, so the lead must commit each round's fixes (e.g., `review: round N — <summary>`) and push them to the PR branch before re-running — otherwise the reviewer re-reads stale committed state, the loop never converges, and every just-fixed finding reappears unchanged and is misread as oscillation. Pushing each round also keeps the PR reflecting the work as it hardens. After committing and pushing, re-run the review on the whole diff.

**Termination (engine-neutral — identical on both paths)** — stop when a whole-PR review returns **no in-scope functional findings** (the `[P#]` findings list is empty after the lead's triage). Both Codex and the swarm-native reviewers emit the same finding format, so the terminator never depends on an engine-specific field; on the Codex path an `overall_correctness: patch is correct` verdict, when present, is a convenience corroborator only, not the stop signal. Expect this to take many rounds — 8–10 rounds of genuinely different findings is normal and runs fully autonomously; do not stop early because a round was quiet if the next whole-PR pass would surface more. Run the loop to its natural end.

**Backstop** — a hard cap of **15 rounds** (a fixed constant, not a config knob) guards against a non-converging loop. Reaching it does NOT silently abort: escalate to the user (continue / stop here / take over). An **oscillating** finding — the *same finding*, matched by its title + `file:line` (never by `[P#]`, which is severity and is shared across unrelated findings), resurfacing after ≥2 fix attempts — is a disagreement, not a grind: stop auto-fixing it and resolve it via `swarm:resolve-dispute` if the team is live, otherwise surface both positions to the user. (This is the existing "break review loops with evidence" rule.)

**Auditability** — the lead is both loop-driver and fixer, so keep it honest: surface the reviewer's verbatim output to the user each round (at minimum at termination), so the user — not the self-interested driver — is the backstop on "are we actually done."

## The steer (one string, both engines — this is the over-reach guard)

Send the reviewer exactly this (substituting the approved outcome verbatim and the resolved base):

> The outcome this change is meant to achieve:
> «approved outcome, verbatim»
>
> Review the ENTIRE change on this branch relative to `«base»` — the full PR diff (`git diff «base»...HEAD`), not just the latest edits. Report only material, FUNCTIONAL findings that bear on that outcome: incorrect logic, defects, broken or unhandled edge cases, and regressions in code this change touches.
>
> Do NOT report: style, naming, or formatting; low-value cleanup; pre-existing issues this change did not introduce; speculation you cannot tie to a concrete failing input or condition; or choices the author clearly made intentionally. A finding must be discrete, actionable, and something the author would fix if they knew.
>
> Prioritize each finding [P0]–[P3]. **No code suggestions** — for each finding, explain in prose what breaks, the exact conditions that trigger it, and the consequence.

Telling the reviewer the outcome and asking only for functional findings is the steer that keeps the loop on-scope — the input-side guard, paired with the lead's triage on the output side.

## Codex path

Codex is the preferred reviewer because it is a genuinely different model and fails differently from the code's author. Run it via **Bash** (the lead can run shell; `/codex:*` slash commands are not model-callable, so do not rely on them):

- Invoke with the steer as a **custom review prompt passed on STDIN** — never as a double-quoted shell argument. The steer contains backticks (e.g. `` `git diff …` ``, `` `codex login` ``); inside double quotes bash runs them as command substitution and corrupts the prompt. Both `codex review` and `codex exec review` accept the prompt from stdin via the `-` positional, so write the steer to a temp file (or a single-quoted heredoc) and pipe it: `printf '%s' "$steer" | codex exec review -`. (Codex's `review` flags `--base`/`--uncommitted`/`--commit` are mutually exclusive with a custom prompt, so the steer rides as the stdin prompt and itself names the `git diff «base»...HEAD` scope; codex still applies its built-in review rubric as the system prompt.)
- Capture stdout, stderr, and the exit code explicitly — `codex exec` exits non-zero on a fatal error, which is the degradation path below. If the invocation errors, check `codex exec review --help` / `codex review --help` and adapt — do not hardcode against version drift. The pass is read-only; if codex's default sandbox blocks the `git` the steer relies on, surface that and degrade rather than hang (runtime-validate).
- Depend only on the **`codex` binary**, never on the codex plugin, its install path, or its companion script.
- **Auth/errors degrade, never hang:** the first failing call → surface Codex's verbatim error + `codex login`, then offer the Swarm fallback or stopping.
- **Codex's own Stop review-gate** (`/codex:setup --enable-review-gate`) is a separate, unbounded per-turn loop that will collide with this one. Warn the user once in prose to disable it for this run; do not read or modify the user's Codex config.

## Swarm fallback

When Codex is absent — or the user picks it deliberately — run the same loop with **fresh, ephemeral, read-only reviewer subagents** spawned via the Agent tool (`subagent_type: swarm-member`), not the standing team. Fresh per round: each reviewer gets only the diff + outcome + steer, with no Converge/Approve history — this approximates an outside reviewer and avoids the "I already looked, looks fine" fatigue of re-soliciting standing members. Spawn **serially by default** (one reviewer at a time — the swarm serial-default / parallel-opt-out toggle applies unchanged); use distinct lenses across reviewers (e.g. correctness & logic, edge cases & failure modes, regressions in touched code). They return findings only; the lead triages and fixes exactly as on the Codex path.

Each reviewer's identity is a **Codex-style reviewer** (adapt this as the subagent's identity, not as extra brief sections):

> a code reviewer in the style of Codex — terse, analytical, matter-of-fact, zero flattery or praise. Flags only discrete, actionable, functional defects introduced by the change that the author would fix if they knew; states the exact conditions that trigger each bug and the provably-affected code; never speculates and never nitpicks style. Reviews the whole PR against the stated outcome and reports findings in the prescribed format with no code suggestions.

Honest limit, worth stating to the user: a fresh Codex-style Claude reviewer is sharp and adversarial but shares the model-level blind spots of the team that wrote the code — it buys *stance*, not the independence Codex's different model gives. That is why Codex is offered first when present.

## Output format (both engines — Codex's native shape)

Findings are rendered as:

```
«1–3 sentence overall summary of the themes»

Full review comments:

- [P1] «imperative finding title» — path/to/file.ext:120-128
  «one prose paragraph: what breaks, the exact conditions that trigger it, the consequence, and what to do — no code blocks»

- [P2] «next finding title» — path/to/other.ext:40-44
  «…»
```

`[P#]` is a presentation/severity label only. It is neither the action gate (what the lead fixes is decided solely by the in-scope/out-of-scope triage above, anchored on the outcome) nor the oscillation key (recurrence is matched by finding identity — title + `file:line`).

## What this skill reuses (do not rebuild)

The round structure, batch-fix-then-re-review discipline ("wait for all of a round's findings before fixing"), escalation, `swarm:resolve-dispute`, and the serial-default/parallel-opt-out cadence are all existing swarm machinery — this skill only adds the independent reviewer, the outcome steer, the triage gate, the termination/backstop, and the output contract. No new phase, no new hard rules, no changes to the team-member briefing templates.

---

*The reviewer rubric, priority tags ([P0]–[P3]), finding format, and steer are adapted from OpenAI Codex (`codex-rs`, Apache-2.0), with one deliberate deviation: Codex permits short `suggestion` blocks; swarm requires prose-only findings with no code suggestions.*
