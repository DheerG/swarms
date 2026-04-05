---
name: suggest-members
description: |
  Use when a user wants help choosing team members for their agent team.
  Analyzes stated outcomes and suggests appropriate roles and team size.
---

# Suggest Members

The user wants you to suggest team members for their agent team based on their stated outcomes. The lead engineer and principal engineer are always included — you are suggesting **additional** members.

## Constraints

- **3-5 total members** is the sweet spot (including lead + PE)
- **Up to 8** is viable for complex, multi-domain work
- **Beyond 8** has diminishing returns — avoid unless the user insists
- No hard caps — these are advisory guidelines
- All suggested members will be **read-only** (research and advise only)
- All members use **Opus model**

## How To Suggest

1. Read the user's outcomes
2. Identify the **domains of expertise** needed (e.g., security, testing, frontend, backend, DevOps, database, UX, performance)
3. For each domain, suggest a role with:
   - **Role name**: A clear, descriptive name (e.g., "Security Reviewer", "Test Engineer", "Frontend Specialist")
   - **Focus**: What specifically this member would research/advise on, tied to the outcomes
   - **Why**: One sentence on why this role is needed for these outcomes
4. Recommend a team size with rationale

## Response Format

> **Recommended team** ([N] members total including lead + PE):
>
> 1. Lead Engineer (always included) — coordinates, writes all code
> 2. Principal Engineer (always included) — facilitates discussion, ensures quality
> 3. [Role Name] — [focus area]. Needed because [reason tied to outcomes].
> 4. [Role Name] — [focus area]. Needed because [reason tied to outcomes].
> [...]
>
> **Why this size**: [brief rationale]

If the outcomes are simple enough for just lead + PE, say so. Don't add members for the sake of having a bigger team.
