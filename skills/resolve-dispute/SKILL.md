---
name: resolve-dispute
description: |
  Resolves a review finding that has survived arbitration without new evidence.
  Invoke when the same finding re-surfaces after PE arbitration, or when the
  review loop is circular. Forces a single put-up-or-concede exchange, then
  marks the outcome DECIDED.
---

A review finding is stuck. Structure its resolution in three steps.

**Step 1 — Frame the dispute.**
Identify and state aloud:
- The disputed finding (one sentence)
- Who holds it
- The PE's prior arbitration ruling (one sentence)

**Step 2 — Send the reviewer this message, substituting `[finding]` with the actual finding:**

> Your finding — [finding] — was arbitrated. To keep it open, you must provide ONE of:
> (a) A concrete failure scenario: specific inputs or conditions that produce wrong behavior
> (b) A source citation: file, line number, and what it shows
> (c) A direct counterexample to the arbitration reasoning
>
> One response. No response counts as concession. After that, the PE rules and the finding is DECIDED.

**Step 3 — Rule and tag.**

After the reviewer responds:
- Evidence present → PE evaluates it on the merits and rules. Tag the finding DECIDED regardless of outcome.
- No evidence → PE tags DECIDED, asks the reviewer to re-score.
- No response → PE tags DECIDED.

DECIDED findings cannot be re-raised without new substance. This enforces the existing "Don't regurgitate decided points" rule.

**What this skill must not do:**
- Override a finding backed by real evidence
- Auto-resolve — the PE still decides after hearing the evidence
- Apply to first-round disagreements — use normal arbitration first
- Suppress legitimate concerns — evidence always reopens the door
