---
description: Add a code-review rule to a directory's .claude/review-rules.md
argument-hint: [--dry-run] [initial rule text]
disable-model-invocation: true
---

# /swarm:code-review-rule

Companion to `/swarm:code-review`. This command **authors** a single rule into `.claude/review-rules.md` at a chosen directory in the current working tree. It writes in the invoking repo (cwd-relative) — there is no target repo, no swarm launch, no team. The `code-review-mode` Forbidden list does not apply: this is an authoring tool.

## User-Provided Context

$ARGUMENTS

## Constraints

- **Per-rule target:** one sentence, ≤ ~120 characters.
- **Per-rule soft cap:** two sentences or >120 characters. Exceed → the command offers a condensed alternative; user picks condensed or original.
- **Per-rule hard cap:** three sentences. Exceed → the command refuses and asks the user to rewrite.
- **Per-file warn (rule count):** 15 rules — the command prompts for confirmation before writing. Gives 15 rules of headroom before the first warning.
- **Per-file hard stop (rule count):** 30 rules — the command refuses to append and asks the user to consolidate existing rules first.
- **Per-file warn (line count):** 100 lines — the command notes "file is N lines; files over 100 lines are harder for reviewers to apply" before writing.
- **Per-file soft stop (line count):** 200 lines — the command prompts for confirmation via AskUserQuestion before writing.
- **Canonical phrasing patterns:** `never X`, `must X`, `prefer X over Y`, `avoid Y`. The command nudges drafts that don't start with a directive verb toward one of these forms.
- **Hedging flag:** drafts containing `generally`, `when possible`, `try to`, `might want to`, `when it makes sense`, `if you can`, or similar hedging tokens → the command surfaces a nudge suggesting an imperative rewrite. The nudge is visible, not a refusal.
- **Dated entries:** every rule is prefixed with an HTML comment — `<!-- added YYYY-MM-DD -->` — visible in raw markdown, invisible when rendered. Serves as a staleness audit signal for anyone grepping the raw file; reviewers do not surface it.

## Workflow

### 1. Pre-flight: require a local git working tree.

Run `git rev-parse --is-inside-work-tree 2>/dev/null`. If the command fails or returns anything other than `true`, stop with:

> "`/swarm:code-review-rule` writes to the local filesystem, so it must run inside the target repo's working tree. `cd` into your repo and re-run. (This is a deliberate asymmetry with `/swarm:code-review`, which is read-only and can run from anywhere.)"

The asymmetry with the read-side command is honest — reading remote PRs via `gh api` is fine; writing files requires a local checkout.

### 2. Parse `$ARGUMENTS`.

If `$ARGUMENTS` begins with `--dry-run`, set dry-run mode and strip the flag. The remaining text (if any) is the user's initial rule draft.

### 3. Collect the rule text.

If `$ARGUMENTS` had initial rule text (after stripping `--dry-run`), use it as the draft. Otherwise ask via plain text:

> "What's the rule? One sentence works best. Canonical patterns: 'never X' / 'must X' / 'prefer X over Y' / 'avoid Y'."

Wait for the user's reply.

### 4. Validate and trim.

Apply checks in order. The phrasing-nudge pass (step 4.2) is the load-bearing value of this command — ambiguity in rule phrasing makes reviewers drop findings, so the rewrite suggestion is not optional even when the draft parses fine. Validation runs before the directory prompt so the user's input isn't wasted when the draft fails a hard cap.

1. **Sentence count.** Rough heuristic: count `.`, `?`, `!` terminators, excluding common abbreviations (`e.g.`, `i.e.`, etc.). If > 3 sentences, tell the user the hard cap is three sentences and ask them to rewrite. Return to step 3.
2. **Phrasing + hedging pass.** Check two things:
   - Does the rule open with a canonical directive verb (`never`, `must`, `prefer`, `avoid`, `always`, `don't`, `ensure`, `require`, `do not`)? If not, propose an imperative rewrite.
   - Does the rule contain hedging tokens (`generally`, `in general`, `when possible`, `try to`, `might want to`, `when it makes sense`, `if you can`, `if applicable`, `probably`, `ideally`, `somewhat`, `should try`, `where appropriate`, `where feasible`, `where practical`, `as much as possible`)? If so, propose a rewrite that removes the hedge and commits to an imperative.
   - If either check fires, use AskUserQuestion: question "Reviewers may treat this phrasing as low-priority. Use the imperative rewrite?", options "Use rewrite (show rewrite text in the description)" / "Keep original (show original in the description)." Prefer the rewrite in the recommended position (first option).
3. **Length check.** If > 1 sentence or > ~120 characters, compose a condensed version that preserves the semantic core. Use AskUserQuestion: question "Your rule is long (N sentences / M chars) — use the condensed version?", options "Use condensed (show condensed text in description)" / "Keep original (show original in description)." If the condensed version would change meaning, surface that in the description.

### 5. Ask for the target directory.

Use a plain text prompt (not AskUserQuestion — it cannot accept typed free-form input):

> "Which directory should this rule apply to? Path relative to repo root, or `.` for universal. Default: `<current cwd relative to git-root>`."

If the user replies with empty text, use the default. Resolve the target directory path; confirm it exists. If it doesn't, ask again.

### 6. Check the file state.

Compute target path: `<target-directory>/.claude/review-rules.md`.

- If the file exists, count rules (lines starting with `-` or `*` at indent level 0) AND count total file lines.
  - **Rule-count checks:**
    - If count ≥ 30: refuse. Tell the user: "`<path>` already has N rules (hard cap 30). Consolidate or split into a nested path before adding more." Stop.
    - If count ≥ 15: use AskUserQuestion: "`<path>` has N rules — append anyway?", options "Yes, append" / "Cancel." If Cancel, stop.
  - **Line-count checks:**
    - If lines ≥ 200: use AskUserQuestion: "`<path>` is N lines — files over 200 lines are hard for reviewers to apply. Append anyway?", options "Yes, append" / "Cancel." If Cancel, stop.
    - If lines ≥ 100 (and < 200): print a warning inline ("file is N lines; files over 100 lines are harder for reviewers to apply") but proceed without a prompt.
- Read the existing file and check whether the new rule is textually or semantically similar to any existing rule (overlap of key nouns/verbs is a good signal). If so, surface the similar rule and ask via AskUserQuestion: "This looks similar to an existing rule: '<existing text>'. Append anyway?", options "Yes, append" / "Cancel."
- **`.gitignore` check.** Run `git check-ignore -q <path>` on the target file path. If the exit status is 0 (path is ignored), print a warning: "`<path>` is excluded by `.gitignore` — the rule file won't be tracked by git. Consider updating `.gitignore` if you want rules committed." Do not refuse; the user may have intentional reasons.

### 7. Write (or dry-run output).

Today's date: use the system date in `YYYY-MM-DD` format. Each rule is written as:

```
<!-- added YYYY-MM-DD -->
- <rule text>
```

The HTML comment is invisible in rendered markdown but visible in raw file view — so it doesn't bloat the context reviewers see during `/swarm:code-review`, but anyone auditing rule rot can `grep` for dates.

If dry-run mode:

> Print: "Dry run — would append the following to `<path>`:"
> Print the two lines (date comment + rule).
> Print: "Rule would land at line N after write."
> Done. Do not create directories, do not write.

Otherwise:

1. `mkdir -p <target-directory>/.claude` (creates the directory if absent; assumes a POSIX-compatible shell — Git Bash, WSL, or Unix).
2. If `<path>` does not exist, create it with a header line `# Code-Review Rules` and a blank line, then the two rule lines.
3. If `<path>` exists, append a blank line (if not already present at EOF) followed by the two rule lines.

### 8. Confirm and remind about git.

Print:

> "Wrote rule to `<path>` at line N."
> Print the rule text (without the date comment, which is for raw-file audits only).
> "Commit when ready — this tool does not stage or commit."

(The step 1 pre-flight guarantees we're inside a git repo, so the commit reminder always fires.)

## Notes

- **Do not read or analyze other files in the repo.** This command only touches `<target-directory>/.claude/review-rules.md`.
- **Do not open a swarm team, invoke mode skills, or read launch.md.** This is a single-file authoring tool; swarm governance doesn't apply.
- **One rule per invocation.** Users who want to add multiple rules re-run the command.
- **HTML date comments are invisible in GitHub's rendered markdown view.** They're only visible in raw file view, via `grep`, or locally — so the date signal doesn't pollute PR-preview screenshots but is fully available to anyone auditing rule rot.
