---
description: Update the swarm plugin to the latest version
allowed-tools: Bash(claude plugin:*)
---

# /swarm:update

Run these commands in order using the Bash tool. The order is load-bearing: `marketplace update` must run first to refresh the local marketplace clone — otherwise `plugin update` reads a stale clone and reports "already at latest" even when a newer version exists.

1. `claude plugin marketplace update swarms`
2. `claude plugin update swarm@swarms --scope project`

After both commands succeed, choose the message from the `plugin update` output. The reliable signal is the success token "updated from X to Y" (the command prints e.g. "updated from 0.5.3 to 0.5.4" — this also carries the version numbers to substitute):

- **If the output contains "updated from X to Y"** (a new version was installed) — use the **update-applied** message and STOP directive below. Substitute the real X and Y; do not emit the literal placeholders "vX"/"vY". Do not soften the restart instruction, and do not offer `/reload-plugins` or any in-session reload as a shortcut.
- **If both commands succeeded but the output does not contain "updated from X to Y"** (it reports you are already on the latest version) — use the **already-current** message below. No restart, no STOP, no version delta.
- **If both commands succeeded but you cannot tell whether a new version was installed** — use the **update-applied** message. A needless restart is harmless; wrongly saying "already current" after a real update reintroduces the version mix.
- If either command errored or exited non-zero, use the failure handling at the end of this file.

**Update-applied** (a new version was installed):

> Update applied to disk: swarm vX → vY. This session is still running the previous version — Claude Code loads plugin commands and skills once at startup. **Restart Claude Code before running any swarm command** — quit and relaunch the CLI or desktop app; or on the web, end this session and open a new one. Clearing the conversation (/clear) is not enough; the session has to fully restart.

Then STOP and end your turn. Do not run any other swarm command and do not hand off into a launch flow this session — the running session is pinned to the old version, so any swarm command run now reads new plugin files against old in-context instructions and mixes versions. Reading from a newer version directory does not help either: there is no in-session path to a clean new version. Do not suggest `/reload-plugins` or any in-session reload to skip the restart — it does not rebuild the command index or re-inject skills and is unavailable on desktop and web, so it reproduces this exact split-version state. If the user asks to proceed with swarm work now, restate that they must start a fresh session first.

**Already current** (no new version was installed) — tell the user, then continue normally:

> Already on the latest version: swarm v<current>. Nothing to update — carry on.

Include the version only if the CLI printed one; otherwise say "Already on the latest version. Nothing to update — carry on."

If either command errored or exited non-zero, show the error output and suggest the user try running the commands manually in their terminal.
