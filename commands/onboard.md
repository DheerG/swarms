---
description: Walk through swarm's core concepts and launch your first team
argument-hint: (no arguments — this command is a walkthrough)
disable-model-invocation: true
---

# /swarm:onboard

You are guiding a new swarm user through the four concepts they need before running `/swarm:launch` for the first time. Follow every step in order. Do NOT skip steps. Do NOT batch AskUserQuestion gates — each gate is its own turn so the user actually reads the concept before clicking.

If the user passed arguments with this command (e.g., `/swarm:onboard build me a feature`), acknowledge once that onboarding doesn't take a task — it teaches — and offer `/swarm:launch` with their task as a starting point when they're ready. Then continue with Step 1 unchanged.

The tone is direct and brief. Explain each concept, then ask a gate question that either advances or lets the user ask for more. Do not narrate your own process.

---

## Step 1: Welcome

Output this welcome, verbatim:

> Welcome to swarm. This is a short walkthrough — four concepts you need, then a choice about how to run, then your first team.
>
> You can quit at any time by saying "stop." Nothing is spawned until you confirm at the end.

Then proceed to Step 2 in the same response.

---

## Step 2: Concept — Outcomes

Output this explanation, verbatim:

> **Outcomes.** Swarm wants to know what success looks like, not what to build.
>
> - **Implementation:** "Add a Redis cache in front of the user service." — describes a solution.
> - **Outcome:** "User profile reads return in under 50ms and don't hit the DB when cached." — describes the result.
>
> Outcomes leave room for the team to reason about *how*. Constraints you want preserved ("don't change the public API") count as outcomes too.

Then use **AskUserQuestion**:

- question: "Got it?"
- header: "Outcomes"
- options:
  - label: "Yes, continue"
    description: "Move on to the next concept"
  - label: "Show me another example"
    description: "Give me one more outcome/implementation contrast"

If "Show me another example": output one more contrast example (pick any domain), then re-ask the same AskUserQuestion.

---

## Step 3: Concept — Modes

Output this explanation, verbatim:

> **Modes.** Swarm picks different phase semantics for different work. You don't pick a mode first — you describe your outcomes, and swarm infers it. Knowing what's on offer just helps you recognize what's happening.
>
> - **Code** — building or fixing software. The lead is the only person who writes code. Review is technical.
> - **Writing** — articles, essays, docs. The lead coordinates; production and editorial follow a specific rhythm.
> - **General** — research, planning, analysis — anything that doesn't fit the above.
>
> `/swarm:launch` infers the mode from your outcomes. If you already know which one you want, `/swarm:code`, `/swarm:write`, and `/swarm:general` are direct entry points.

Then use **AskUserQuestion**:

- question: "Got it?"
- header: "Modes"
- options:
  - label: "Yes, continue"
    description: "Move on to the next concept"
  - label: "Give me an example of inference"
    description: "Show me how outcomes map to a mode"

If "Give me an example of inference": output one short example showing how a stated outcome implies a mode (e.g., "Blog post about distributed systems → Writing; fix a checkout bug → Code"), then re-ask the same AskUserQuestion.

---

## Step 4: Concept — Phase Arc

Output this explanation, verbatim:

> **The phase arc.** Every team runs the same phases in order:
>
> **Research → Converge → Approve → Execute → Review → Refine → Deliver**
>
> - **Research**: teammates investigate independently.
> - **Converge**: the facilitator runs a roundtable, surfaces disagreement, drives consensus.
> - **Approve**: the team's approach is presented to you. This is where you get a decision. Execute doesn't start until you say yes.
> - **Execute**: the lead does the work.
> - **Review**: the team checks the work, not you.
> - **Refine**: optional — once the team reaches 9/10, you can ask for recursive refinement (9.25 → 9.5 → 9.75 → 10).
> - **Deliver**: you get the final artifact with the team's sign-off.
>
> You watch during Execute and Review. You don't drive. That's the point.

Then use **AskUserQuestion**:

- question: "Make sense?"
- header: "Phase arc"
- options:
  - label: "Yes, continue"
    description: "Move on to the next concept"
  - label: "Explain a phase in more detail"
    description: "Tell me which phase and I'll expand just that one"

If "Explain a phase in more detail": ask the user (free text) which phase they want expanded. Output one focused paragraph on ONLY that phase. Do NOT pre-explain any other phase unless the user explicitly names it. If the user names multiple phases, address each one separately, in the order they named them. Then re-ask the same AskUserQuestion.

If the user selects "Other" with custom text, treat their free text as the request and respond to exactly what they asked — do not inject explanations of any other phase.

---

## Step 5: Concept — The 9/10 Confidence Gate

Output this explanation, verbatim:

> **The 9/10 gate.** The facilitator won't let work reach you until the team scores it 9 out of 10 or better.
>
> 9/10 means: the logic is correct, there are no known defects left unaddressed, and the reviewers would ship this. If the score falls short, the lead fixes and the team re-reviews — automatically. You don't mediate.
>
> This is what keeps quality consistent run to run. Most of the work happens in the cycles you never see.

Then use **AskUserQuestion**:

- question: "Ready for the last two questions?"
- header: "Continue"
- options:
  - label: "Yes, continue"
    description: "Move on to setup"
  - label: "Go back and review a concept"
    description: "Let me revisit outcomes, modes, or the phase arc"

If "Go back and review a concept": ask (free text) which one, re-output that section, then re-ask the same AskUserQuestion.

---

## Step 6: Auto mode

Output this explanation, verbatim:

> **Auto mode.** Swarm works best when Claude Code is in auto mode — continuous, autonomous execution, fewer confirmation prompts between phases. Teams get into their rhythm instead of stalling on prompts you don't need to answer.
>
> You can toggle it any time. If you're new, it's still fine to leave it off and watch the team work with normal confirmations — but most experienced swarm users leave it on.

Then use **AskUserQuestion**:

- question: "Enable auto mode for your swarm sessions?"
- header: "Auto mode"
- options:
  - label: "Enable it (Recommended)"
    description: "Turn on auto mode now — I'll guide you through it"
  - label: "I'll do it later"
    description: "Skip — I can enable it any time from Claude Code settings"

**If "Enable it"**: You MUST use the **Skill** tool to invoke `update-config` with `args: "Enable auto mode for swarm sessions"`. Do NOT attempt to edit settings.json yourself. After the skill completes, confirm to the user in one sentence that auto mode is enabled.

**If "I'll do it later"**: acknowledge in one sentence ("Understood — you can enable auto mode any time.") and proceed.

---

## Step 7: Launch your first team

Output this, verbatim:

> That's the walkthrough. Ready to launch your first team?

Then use **AskUserQuestion**:

- question: "Launch your first team now?"
- header: "Launch"
- options:
  - label: "Yes, launch now"
    description: "Hand off to /swarm:launch with what I've chosen"
  - label: "Not yet"
    description: "I want to read more first — exit this walkthrough"

**If "Yes, launch now"**: hand off by reading `${CLAUDE_PLUGIN_ROOT}/commands/launch.md` and executing it from Step 0 onward. Let launch.md handle mode inference from the outcomes the user provides — do not pre-select a mode.

**If "Not yet"**: output one sentence pointing to `/swarm:launch` and `/swarm:code` / `/swarm:write` / `/swarm:general` as entry points when ready, and stop.

---

## Rules

- Output each concept section verbatim as shown. Do not paraphrase.
- Use AskUserQuestion for every gate. Never replace an AskUserQuestion with a plain-text question.
- Do not narrate ("Now I'll explain..."). Just output the concept.
- Do not spawn agents or create a team. This command teaches and hands off — it does not run a team itself.
- If the user says "stop" or equivalent at any point, exit cleanly without further prompts.
