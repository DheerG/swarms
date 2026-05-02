#!/usr/bin/env bash
# Swarm one-shot installer — runnable from anywhere, installs into the current project.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/arthrod/swarms/main/scripts/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/arthrod/swarms/main/scripts/install.sh | bash -s -- /path/to/project
#
# Env overrides:
#   SWARM_SOURCE          Marketplace source (default: arthrod/swarms)
#   SWARM_PLUGIN_NAME     Plugin name (default: swarm)
#   SWARM_MARKETPLACE     Marketplace alias (default: swarms)
#   SWARM_ENABLE_TEAMS    "1" to add CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 to ~/.claude/settings.json
#   SWARM_SCOPE           Install scope: project | user (default: project)
#
# What it does:
#   1. Verifies the `claude` CLI is available.
#   2. cd's into the target project directory (arg $1, else $PWD).
#   3. Runs `claude plugin marketplace add` and `claude plugin install`.
#   4. Optionally enables the experimental agent-teams flag in user settings.

set -euo pipefail

SWARM_SOURCE="${SWARM_SOURCE:-arthrod/swarms}"
SWARM_PLUGIN_NAME="${SWARM_PLUGIN_NAME:-swarm}"
SWARM_MARKETPLACE="${SWARM_MARKETPLACE:-swarms}"
SWARM_SCOPE="${SWARM_SCOPE:-project}"
SWARM_ENABLE_TEAMS="${SWARM_ENABLE_TEAMS:-0}"

TARGET_DIR="${1:-$PWD}"

err() { printf 'swarm-install: %s\n' "$*" >&2; }
info() { printf 'swarm-install: %s\n' "$*"; }

if ! command -v claude >/dev/null 2>&1; then
  err "the 'claude' CLI is not on PATH."
  err "install Claude Code first: https://docs.claude.com/en/docs/claude-code"
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  err "target directory does not exist: $TARGET_DIR"
  exit 1
fi

cd "$TARGET_DIR"
info "installing into project: $(pwd)"

if [ "$SWARM_SCOPE" = "project" ] && [ ! -d ".git" ]; then
  err "warning: $(pwd) is not a git repository. Project-scope install will create .claude/ here anyway."
fi

info "adding marketplace: $SWARM_SOURCE (alias: $SWARM_MARKETPLACE)"
claude plugin marketplace add "$SWARM_SOURCE"

info "installing plugin: ${SWARM_PLUGIN_NAME}@${SWARM_MARKETPLACE} (scope: $SWARM_SCOPE)"
claude plugin install "${SWARM_PLUGIN_NAME}@${SWARM_MARKETPLACE}" --scope "$SWARM_SCOPE"

if [ "$SWARM_ENABLE_TEAMS" = "1" ]; then
  SETTINGS="$HOME/.claude/settings.json"
  mkdir -p "$HOME/.claude"
  if [ ! -f "$SETTINGS" ]; then
    printf '{\n  "env": {\n    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"\n  }\n}\n' > "$SETTINGS"
    info "wrote experimental agent-teams flag to $SETTINGS"
  elif command -v jq >/dev/null 2>&1; then
    TMP="$(mktemp)"
    jq '.env = (.env // {}) | .env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"' "$SETTINGS" > "$TMP" \
      && mv "$TMP" "$SETTINGS"
    info "merged experimental agent-teams flag into $SETTINGS"
  else
    err "warning: jq not found; cannot merge agent-teams flag into existing $SETTINGS."
    err "add manually: { \"env\": { \"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS\": \"1\" } }"
  fi
fi

cat <<'EOF'

swarm-install: done.

Next:
  - Open Claude Code in this project and run: /swarm:onboard
  - Or jump straight in: /swarm:launch

If agent teams aren't enabled yet, /swarm:launch will offer to enable them for you.
EOF
