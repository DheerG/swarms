---
description: Update the swarm plugin to the latest version
allowed-tools: Bash(claude plugin:*)
---

# /swarm:update

Run these commands in order using the Bash tool. The order is load-bearing: `marketplace update` must run first to refresh the local marketplace clone — otherwise `plugin update` reads a stale clone and reports "already at latest" even when a newer version exists.

1. `claude plugin marketplace update swarms`
2. `claude plugin update swarm@swarms --scope project`

After both commands succeed, tell the user: "Updated. New commands and skills are available immediately."

If either command fails, show the error output and suggest the user try running the commands manually in their terminal.
