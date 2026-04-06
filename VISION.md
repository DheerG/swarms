# Vision

Swarm is a Claude Code plugin that launches agent teams through an interactive command. Instead of writing a lengthy prompt every time you need a team of AI agents working together, you run `/swarm:launch`, answer three questions, and the plugin handles team creation, role assignment, rule enforcement, and coordination.

This document describes the design philosophy and where the project is heading.

## The Core Insight

A coding change that also updates documentation shouldn't require two separate teams. It's one piece of work with members who have different expertise.

That realization shaped everything: the plugin has one command. It's domain-agnostic. The user describes what they're trying to achieve and picks the right people for the job. A backend engineer, a technical writer, and a customer success lead can all be on the same team. The command defines the process. The members define the expertise.

## Principles

### Prompts, Not Frameworks

The consumer of every command is a language model, not a compiler. A self-contained prompt read in one pass outperforms a framework that assembles itself from parts at runtime. Every layer of indirection is a point where the model loses the thread. Commands are flat markdown files with everything inline. No imports, no inheritance, no runtime composition.

### Compression

More context makes language models worse, not better. Agent definitions are one sentence. Skills are a few lines. Rules are terse. If a behavioral fix needs a paragraph, the behavior hasn't been found yet. Start with the smallest thing that works. Grow it through use.

### The Biggest Piece Justifiable

Fragmentation produces fragment-shaped work. Give the team the largest, most complete unit of work possible. One team for one initiative, even when that initiative spans coding, writing, and operations. Breaking work into atomic pieces causes discontinuity in thinking.

### Outcomes Over Implementations

Work is described as what the world looks like when it's done, not what to build. Outcomes are brief, state-based, and leave room for the team to reason about how. Constraints on what should not change are first-class outcomes too.

## The Phase Arc

Every team follows the same rhythm:

1. **Setup**: pre-flight checks, interactive Q&A for outcomes and team composition
2. **Research**: teammates investigate independently from their perspective
3. **Converge**: the team aligns on an approach through structured discussion. If someone raises a concern, it gets investigated before moving on.
4. **Approve**: present the agreed approach to the user before work begins
5. **Execute**: the designated person produces the work
6. **Validate**: check the output against criteria the team agreed on
7. **Review**: teammates evaluate. If concerns arise, return to convergence.
8. **Deliver**: present completed work to the user before shipping

These phases happen in this order. How each one works varies by context: convergence might be a roundtable or a structured Q&A session, validation might be a test suite or an editorial review. The phases are the skeleton. The team fills in the rest.

## Composable Pieces

Five things change from one team to the next:

1. **Rules**: split into two tiers. Rules that apply to everyone, and rules that apply only to the lead. When briefing members, use judgment about which general rules are relevant to their role.
2. **Roles**: every team has a lead, a facilitator, a quality enforcer, and specialists. Who produces the work depends on the task. Sometimes it's the lead. Sometimes it's a dedicated specialist. The quality enforcer owns the validation rubric: enforcing existing standards when they exist, constructing the rubric during convergence when they don't.
3. **Convergence mechanism**: the requirement is that the team aligns before anyone starts producing. How that alignment happens depends on the work.
4. **Workflow details**: what research looks like, what execution means, how review runs.
5. **Validation rubric**: how the team knows it's done.

## Validation

Some types of work have well-known validation criteria. Code has test suites and review thresholds. Writing has editorial standards. But not every task fits a known category.

When the team doesn't have a pre-built rubric, they define one during convergence: before execution starts, the group agrees on what "done" looks like. This way every team has validation criteria, whether the domain is familiar or brand new.

## General-Purpose Teams vs Purpose-Built Pipelines

One question determines which to use: does this task need different people, or a different process?

**Different people**: use the general-purpose command. The Q&A assembles the right mix of expertise. The phase arc handles coordination.

**Different process**: build a purpose-built pipeline. Some workflows are specialized enough that they need their own phases, their own review model, their own production stages. These emerge from repeated practice in a domain, not from upfront planning. They get their own command when the process is proven.

Most work fits the general-purpose path.

## Evolution

**v0.1.0**: one command, ad-hoc team assembly, rules embedded inline. The shared structure is implicit in the command itself.

**Next**: validation becomes task-type-aware so different kinds of output get checked by the right criteria within the same team. Member suggestions get smarter about recommending across disciplines when the outcomes call for it.

**Later**: purpose-built pipelines for workflows that have been practiced enough to earn their own command. A reference template for the phase arc so new commands stay consistent. A generator skill for scaffolding new team types.

**Extraction principle**: formalize patterns only after observing them across multiple implementations. Build the second type, study both, write the shared template fresh. Observe and rewrite, don't refactor in place.

## What We Tried and Discarded

- **One plugin per domain**: cross-domain work can't share members across plugin boundaries
- **Domain-specific commands**: cross-domain tasks need members from multiple disciplines on the same team
- **Phased framework with runtime composition**: indirection costs outweigh abstraction benefits when the consumer is a language model
- **Separate rules files**: security boundaries make external file loading fragile across project directories
- **First-run setup scripts**: friction before value
- **Multi-paragraph agent definitions**: one-sentence definitions outperform longer ones
