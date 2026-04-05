# Hard Rules

These rules govern all team behavior. They are non-negotiable.

## Troubleshooting

- **Dig Deep for Root Cause.** A root cause must identify the specific line of code that breaks. If your theory can't do that, keep tracing through actual source code — don't reason from documentation or convention.
- **Training and memory goes stale.** Research on the web often.

## Planning & Approval

- **Never enter plan mode.** If a plan exists, implement it directly.
- **Confirm plan is final before building.** Even after "greenlight," ask if the user has remaining inputs. The cost of asking is zero; building on an incomplete plan means a full revert.
- **Never revert code without being asked.** Process feedback != "delete the work." Ask before running destructive git commands.

## Agent Teams

- **Always use TeamCreate.** When user says "agent team," use TeamCreate + Agent with `team_name`. Never substitute with Explore agents or manual coordination.
- **Readonly members.** All members apart from the lead are read-only members.
- **Never cut corners on agent teams.** Spawn the full team as defined. Never apply changes yourself to save time. Never skip pipeline stages.
- **Never shut down agent teams unless explicitly told.** No exceptions, no "optimizing" by cleaning up early.
- **Use Opus for all substantive work.** Match the team lead's model and reasoning effort.
- **Lead asking team members for help.** If the lead is feeling stuck, they should ask team members for help. Their option isn't limited to wait for the review round to show them their thinking. Ask one or more relevant members for help to get unblocked.

## Agent Team Member Response Style

- **Favor brevity during round tables and discussions.** Experts know how to summarize their statements.

## Review Process

- **Wait for ALL reviews before making changes.** Never fix findings mid-review. Wait for every team member to respond, then batch fixes.
- **No code changes during review.** Reviewers must verify current state, not stale code.
- **Present findings to user and wait for explicit go-ahead.** Never self-determine readiness. After every review cycle: compile -> present -> wait for confirmation -> then act.
- **Reviews must reach 9/10+ confidence before shipping.** Keep plan docs updated every cycle. Run gap analysis every cycle.

## Transparency & Honesty

- **No performative shortcuts.** The user has tooling that shows every agent message, every paraphrase, every routing decision. Never misrepresent what was done. When told "verbatim," send their exact words. When told "send to the team," send to the team — not one person.
- **ASK before implementing uncertain fixes.** If the right approach isn't obvious, ask. Never pick a fix that contradicts the intent of recent work. If a test fails because your fix contradicts its intent, stop — don't rewrite the test.

## Code Ownership

- **Keep code edits in the main agent.** Sub-agents for research/analysis only. All file edits, promotions, and git operations in the main agent.
