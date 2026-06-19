---
name: reflect-outcome
user-invocable: false
description: |
  Detects when a stated outcome names a specific instance — a mechanism-as-means or a single named product — where a category was meant, and returns a neutral fork for the lead to show the user, or nothing. Invoked by launch commands at outcome capture, in place of the verbatim echo.
---

The user stated an outcome in their own words. Read it for ONE structural pattern — **a specific instance named as the way to reach a broader end the same sentence also carries.** Fire ONLY when BOTH are present: (1) a named mechanism, product, or instance, AND (2) a wider goal — stated in the sentence, or, for a proper noun, the obvious class it instances — that the named thing is merely one way to serve. The named thing being *narrower than that wider goal* is the discriminator; with no wider end in view, do not fire.

- **Mechanism-as-means:** "force a resume *so it can nudge* a forgotten prospect" → "nudge" is one way to reach the wider stated goal "resurface a forgotten prospect" → FIRE. Contrast "add a retry queue for failed webhooks" → "retry queue" IS the whole ask, no wider goal it under-serves → **stay SILENT**.
- **Proper-noun-specific-instance:** "integrate with Salesforce to sync deals" → "Salesforce" is one instance of the obvious class (a CRM) → FIRE ("Salesforce specifically, or any CRM?"). A named thing with no broader class it narrows stays SILENT.

The shape is: the wording picks ONE point inside a wider target it also names (or a wider class it obviously instances), which can silently collapse the team onto that point and orphan the alternatives. You detect that *divergence within the sentence*, not predict that foreclosure will happen; the cheap, incumbent-first dismiss is what makes firing safe. A bare concrete noun with no wider end it under-serves does NOT fire — that over-firing is the alarm-fatigue failure this must avoid.

Read the WORDING only. Do not read the codebase. Do not grade quality. Do not hunt for missing detail — over-specification is the failure here, not under-specification.

**Common case — nothing pinned:** return exactly `NO FORK`. The lead shows the user nothing and carries the outcome forward as-is. Do not hedge, apologize, or manufacture a concern; a clean pass is a first-class result. Fire only on a citable pinning word that is actually in the user's text — no citable word, no fork.

**A pinned instance is present (either shape):** return a ready-to-render AskUserQuestion object the lead shows verbatim and does not author. Build it to this grammar:
- **Subject** is the team or the reading, never the user — "the team would read this as…", never "you didn't specify…".
- **Forward-looking:** name the consequence the user can veto, not a deficiency they must defend.
- **Pivot on the user's OWN word**, quoted, as a means/ends substitution — introduce no noun they didn't write.
- **Only remedy is to pick a reading** — never to add more detail.

Shape (draft NO goal anywhere — not in the stem, not in either label; the open pole asserts only that other ways exist, naming none):
- `question`: *"'\<their word>' reads as the way to do this — the team builds only what the wording pins. Did you mean \<their word> specifically, or is it one option among others?"*
- `header`: "Outcome"
- `options` (exactly two — incumbent first, both first-person in the user's own voice):
  - *"Yes — \<their word> specifically is what I want."* — that specific one, exactly as worded
  - *"I'm open to other ways to do this — \<their word> was just how I put it."* — \<their word> was one example, not the requirement

**Neutrality bar — all four must hold, or return `NO FORK` instead:** (1) introduce no noun the user didn't write; (2) assert no quality grade; (3) the user's verbatim still briefs the team without your words leaking in; (4) the user keeps an unforced choice to leave the wording exactly as-is.
