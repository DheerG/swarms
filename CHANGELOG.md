# Changelog

## [0.4.0] - 2026-05-01

### Added
- `/swarm:refine` — standalone command that runs recursive refinement on the current branch and pull request against user-stated outcomes. Skips Research/Converge/Approve/Execute and enters at Review → Refine → Deliver. Fixed reviewer roster (Principal Engineer facilitator + Correctness Reviewer, Outcomes Reviewer, Regression Reviewer). Pre-flight reads the current branch, PR (via `gh pr view`), and diff (`git diff <base>...HEAD`) and embeds them in member briefings as raw context. Defaults to Code mode, Balanced shape.

## [0.1.0] - 2026-04-05

### Added
- `/swarm:launch` — interactive agent team setup command with Q&A flow
- `/swarm:refine-outcomes` — helps reframe implementations as outcome statements
- `/swarm:suggest-members` — recommends team composition based on outcomes
- Principal Engineer agent definition (Socratic facilitator, read-only)
- Default hard rules covering troubleshooting, planning, agent teams, review, transparency, and code ownership
- Pre-flight check for agent teams enablement
- First-run setup with persistent user-customizable rules
- Plugin manifest, MIT license, README with ubiquitous language glossary
