---
description: Launch a code-review agent team for a GitHub PR
argument-hint: <PR number | URL | owner/repo#N>
disable-model-invocation: true
---

# /swarm:code-review

Read `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` for Step 0 (pre-flight), Step 1 (hard rules), and Step 8 (launch). This command replaces Steps 2–7.

**Lead research is ON by default for this mode.** The lead fetches the PR and triages its surface area before spawning the team.

## Settings

- **Mode:** CodeReview (mode skill: `swarm:code-review-mode`)
- **Outcomes question:** skipped — the PR identifier IS the outcome
- **Defaults:** Balanced shape, lead research enabled, suggest-members driven by the mode skill's Suggest-Members Guidance + PR triage
- **Setup gate:** skipped — users who want to override defaults can select "I have changes" at the Pre-flight confirmation

## User-Provided Context

$ARGUMENTS

## Pre-flight (runs before the Workflow below)

### 0. Verify `gh` is available.

Run `command -v gh`. If it returns non-zero, tell the user "`gh` CLI is required for `/swarm:code-review`. Install from https://cli.github.com and run `gh auth login`, then retry." Stop.

### 1. Parse `$ARGUMENTS`.

The identifier is one of:

| Shape | Example | How to parse |
|---|---|---|
| Bare positive integer | `1935` | PR number; needs repo resolution |
| GitHub URL (with or without `https://`, with or without trailing `/files` or `/`) | `https://github.com/OWNER/REPO/pull/N`, `github.com/OWNER/REPO/pull/N/files` | Strip scheme+host, split path on `/`, take segments `[owner, repo, "pull", N]`, ignore trailing segments |
| `owner/repo#N` | `SkipupAI/skipup#1935` | Split on `#`; left is `owner/repo`, right is N |

Unparseable = not a positive integer, not a URL containing `/pull/<positive-integer>`, not matching `owner/repo#<positive-integer>`. If unparseable or empty, ask the user once via plain text: "Which PR? (number, URL, or owner/repo#N)". Do not use AskUserQuestion (it cannot accept typed free-form input).

### 2. Resolve the repo (only when the user gave a bare number).

1. Run `git remote get-url upstream 2>/dev/null` and `git remote get-url origin 2>/dev/null` in cwd.
2. Normalize each remote URL:
   - Strip trailing `.git`.
   - If it starts with `git@github.com:`, replace with `https://github.com/`.
   - If the normalized URL starts with `https://github.com/`, extract `owner/repo` from the path.
   - Otherwise, discard — it's not a GitHub remote.
3. Selection:
   - If both `upstream` and `origin` resolve to the **same** GitHub repo: use it (either is fine; prefer `upstream`).
   - If both resolve to **different** GitHub repos: ask the user via plain text: "`upstream` is `<owner>/<repo>`, `origin` is `<owner>/<repo>`. Which repo contains PR #N?". Wait for their reply.
   - If only one resolves to a GitHub remote, use it.
   - If neither resolves (not a git repo, or no GitHub remote), ask the user via plain text: "Which repo contains PR #N? (format: `owner/repo`)". Wait for their reply.

Plain-text prompts here are intentional — AskUserQuestion does not accept free-form typed input; its "Other" option is only available alongside preset options, not as a standalone input field.

### 3. Fetch the PR.

- `gh pr view <N> --repo <owner/repo> --json title,author,state,body,additions,deletions,changedFiles,baseRefName,headRefName,url`
- `gh pr diff <N> --repo <owner/repo>` — fetch the full diff once here. Count its lines from the already-fetched output (no second `gh` call). If it exceeds ~2000 lines, derive the file list from the diff's `diff --git` headers instead of making a second `gh pr diff --name-only` call.

If either `gh` call fails (not authenticated, PR not found, forbidden), surface the stderr to the user and stop. Do not spawn a team against a broken fetch.

### 4. Triage the diff (lead-side).

From both the PR metadata and the diff content (not just the file list), characterize:

- **Languages touched** — file extensions, with counts.
- **Subsystems touched** — top-level directory groups.
- **AI surfaces** — scan the diff content for LLM SDK imports (`openai`, `anthropic`, `langchain`, Bedrock, Vertex, etc.), prompt-template strings, tool schemas, agent scaffolding. File-list grep alone is not sufficient — a Ruby file importing an LLM SDK or a Go file with prompt strings is invisible from filenames.
- **Security surface** — auth, permissions, crypto, raw SQL, secrets, Dockerfiles, CI workflows, dependency manifests.
- **Size signal** — additions, deletions, file count (informational — the mode skill's Suggest-Members Guidance decides how to use it).

Store this characterization as the input summary for `swarm:suggest-members`.

### 5. Collect codebase review rules from the target repo.

The target repo may carry codebase-specific and path-specific review standards authored by the codebase owner. The convention is `.claude/review-rules.md` at any directory level in the target repo — universal rules at the root, path-scoped rules nested at subdirectories.

1. **Enumerate candidate directories.** For each changed file in the PR, take each of its ancestor directories from repo root to the file's parent. Example: a PR touching `apps/web/Button.tsx` and `apps/shared/api.ts` yields candidates `./`, `apps/`, `apps/web/`, `apps/shared/`. Deduplicate, sort root-first.

   **Candidate cap.** If the deduplicated list exceeds **20 unique directories**, skip the rules walk entirely. Record lead-side that the PR is too wide for path-specific rules; proceed without any. This prevents `gh api` call floods on monorepo-wide PRs. The reviewer still has the PR content; only path-scoped rules are skipped. (Depth alone is not a disqualifier — standard repo layouts like `src/components/Button/index.tsx` or `internal/pkg/auth/handler.go` are deep by design.)

2. **Fetch each candidate rule file.** Strip any trailing `/` from candidate dir paths before URL construction (avoids a `//` in the path). For each unique directory `<dir>`, run:
   - Root directory (empty or `.`): `gh api "repos/<owner>/<repo>/contents/.claude/review-rules.md?ref=<baseRefName>"`
   - Any other directory: `gh api "repos/<owner>/<repo>/contents/<dir>/.claude/review-rules.md?ref=<baseRefName>"`

   The API returns base64-encoded content; decode.

3. **Handle fetch outcomes.**
   - 404 → skip silently (no rules file at that path).
   - 422 (invalid ref) → follow the non-404 path below; likely transient or repo-state issue.
   - Network timeout → follow the non-404 path below.
   - Any other non-404 error (rate limit, auth, outage) → record lead-side for audit (not surfaced in briefings, not surfaced to the user), proceed without that file. Never block the review on a rules fetch failure.

4. **Deduplicate and enforce size cap.** Order results root-first by path. Total rule-content budget across all collected files: ~1000 lines. If exceeded, truncate greedily from largest file to smallest until the total is within budget — each truncation marked with `[rule file truncated at line N — full file at <dir>/.claude/review-rules.md]`. If a single file exceeds the cap on its own, truncate it to the full budget and omit all remaining files entirely (their presence is noted lead-side for audit). This bounds context and nudges authors who wrote one giant file to split into per-path files.

5. **Store the ordered rule-file list** for inclusion in the resolved User-Provided Context at Workflow step 4. If no rule files were found, store nothing — the rules section will be omitted entirely (silent no-op).

### 6. Confirm once.

Use AskUserQuestion (header "Launch", question "Reviewing PR #N in owner/repo — '<title>'. Proceed?", options "Launch the team" / "I have changes"). This replaces Step 2's outcomes question AND Step 7's confirmation for the default path — if the user picks "Launch the team," skip Step 7. If "I have changes," fall through to the full Step 7 confirmation loop.

If codebase review rules were found in step 5, the confirmation line should note it briefly — e.g., "Reviewing PR #N in owner/repo — 'title'. 3 rule file(s) found. Proceed?" This keeps the user aware that their rules are about to be applied without adding a separate gate.

## Workflow

1. **Outcomes.** Captured by Pre-flight. The outcome string is `Review PR #<N> in <owner/repo>: <title>`. Do not re-ask.

2. **Read the mode skill (early) and invoke suggest-members.** You MUST use the **Skill** tool to invoke `swarm:code-review-mode` now and retain its content — this is both the operational spec you'll re-use at Step 8b AND the source of the Suggest-Members Guidance you need here. `swarm:suggest-members` falls through to Code-mode defaults for labels it doesn't recognize, so pass it the guidance text explicitly rather than relying on label lookup.

   Invoke `swarm:suggest-members` with combined `args`: (a) mode label `code-review-mode`, (b) the Pre-flight triage summary (languages, subsystems, AI surfaces, security surface, size signal), and (c) the **full Suggest-Members Guidance section** from the mode skill spec, pasted verbatim.

   Apply Balanced shape and lead research enabled. If the user picked "I have changes" at Pre-flight step 5, follow launch.md Steps 4–6 instead.

3. **Confirmation.** If the user picked "Launch the team" at Pre-flight step 5, skip Step 7 — the confirmation has already been given. Otherwise follow launch.md Step 7, with the "Outcomes" line set to the outcome string and the "User's original context" line set to the resolved User-Provided Context (see step 4 below for what "resolved" means).

4. **Launch.** Follow launch.md Step 8.

   **Resolve User-Provided Context for the briefings.** The `$ARGUMENTS` the user typed (e.g., `1935`) is the raw PR identifier. The Pre-flight fetch has expanded the user's intent into full PR context. In Step 8c and 8d briefings, the verbatim block's content ("paste the user's original `$ARGUMENTS` or Step 2 input — full text, unmodified") is the **resolved User-Provided Context**, a single quoted block composed as:

   ```
   <raw $ARGUMENTS exactly as the user typed it>

   [Pre-flight fetched PR context:]
   PR: <owner/repo>#<N> — <title>
   Author: <author>
   Base: <baseRefName> ← Head: <headRefName>
   State: <state>
   Size: +<additions> −<deletions> across <changedFiles> files
   URL: <url>

   PR body (omit this section if the PR body is empty or whitespace-only):
   <body>

   Applicable review rules (from target repo's .claude/review-rules.md at each applicable path):
   [./]
   <root rules file content>

   [apps/web/]
   <apps/web rules file content>

   [apps/shared/]
   <apps/shared rules file content>

   Diff (<total-line-count> lines):
   <full diff if ≤ ~2000 lines, otherwise the file list derived from `diff --git` headers followed by a note: "Diff is large; members fetch per-area with `gh pr diff <N> --repo <owner/repo>` and scope to their domain.">
   ```

   If no rule files were collected in Pre-flight step 5, omit the "Applicable review rules" section entirely — do not emit an empty header or a "no rules" placeholder.

   This is a literal expansion of `$ARGUMENTS` into its semantically-complete form for this mode. No new briefing sections are added; the pre-flight output fills the existing verbatim block.

   At Step 8b, re-use the `swarm:code-review-mode` spec the lead retained at Workflow step 2 rather than invoking the skill again.
