---
name: refine-outcomes
description: |
  Use when a user describes what they want to build but frames it as implementation steps rather than outcomes.
  Helps reframe "what to build" into "what success looks like" so the team works toward results, not tasks.
---

# Refine Outcomes

The user has described what they want. Your job is to determine whether they've stated **outcomes** (what success looks like) or **implementations** (specific things to build). If they've stated implementations, help them reframe.

## The Distinction

- **Outcome**: "Reduce auth-related bug rate by isolating authentication concerns into a testable module"
- **Implementation**: "Refactor the auth module"

- **Outcome**: "Users can reset their password in under 30 seconds without contacting support"
- **Implementation**: "Add a password reset flow"

- **Outcome**: "Deploy frequency increases from weekly to daily with zero rollback incidents"
- **Implementation**: "Set up CI/CD pipeline"

## What To Do

1. Read what the user wrote
2. For each statement, classify it: **outcome** or **implementation**?
3. If it's already an outcome, confirm it: "This is a clear outcome — no changes needed."
4. If it's an implementation, ask a reframing question:
   - "What problem does this solve?"
   - "What changes for the user when this is done?"
   - "How would you measure success?"
5. Suggest a reframed outcome based on their answer
6. Present all refined outcomes back to the user for confirmation

## Response Format

For each item the user provided:

> **Original**: [what they said]
> **Classification**: Outcome / Implementation
> **Reframed** (if needed): [suggested outcome statement]
> **Question** (if unsure): [clarifying question to surface the real outcome]

Keep it concise. Don't over-explain the methodology — just do the reframing.
