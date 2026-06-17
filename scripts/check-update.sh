#!/bin/bash
# Swarm update notifier — fires on SessionStart hook
#
# Phase 1 (background): fetches latest version from GitHub, writes the fetch cache.
#   Rate-limited to once per 24h, except when cached version == installed version
#   (treats "you're current" as potentially stale and re-fetches immediately).
#   Silent on any network failure. Fully non-blocking — never delays session start.
# Phase 2 (instant): reads the cached result, compares against the installed version,
#   and if a newer version exists emits ONE pure-JSON object on stdout:
#     - systemMessage      → user-visible line, shown in the CLI ONCE per new version
#     - additionalContext  → relay directive for the assistant, emitted EVERY session.
#                            This is the only channel that surfaces in IDE/web clients
#                            (where systemMessage does not render), so the assistant can
#                            still tell the user about the update there.
#
# A SessionStart hook requires stdout to be ONLY the JSON object — every other write
# goes to a file or /dev/null. (Bare stdout from this event is injected into the model's
# context but never shown to the user, which is why a plain echo reached no one.)
#
# Two disjoint single-writer state files (race-free, no locking):
#   .swarms-update-cache  {version, fetched_at}  — written ONLY by the Phase 1 fetcher
#   .swarms-notified      {notified_version}     — written ONLY by the Phase 2 display
#
# Opt-out: set SWARM_SKIP_UPDATE_CHECK=1

CACHE_FILE="$HOME/.claude/.swarms-update-cache"
NOTIFIED_FILE="$HOME/.claude/.swarms-notified"
GITHUB_URL="https://raw.githubusercontent.com/DheerG/swarms/main/.claude-plugin/plugin.json"

[[ "${SWARM_SKIP_UPDATE_CHECK}" == "1" ]] && exit 0

# Read a string field from a JSON file (jq, or grep fallback). Empty if missing/absent.
read_field() {  # read_field <file> <key>
  if command -v jq &>/dev/null; then
    jq -r --arg k "$2" '.[$k] // empty' "$1" 2>/dev/null
  else
    grep -o "\"$2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$1" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"'
  fi
}

# Emit the SessionStart JSON. stdout must contain ONLY this object.
emit_json() {  # emit_json <additionalContext> [systemMessage]
  if command -v jq &>/dev/null; then
    if [[ -n "$2" ]]; then
      jq -nc --arg sm "$2" --arg ac "$1" \
        '{systemMessage:$sm, hookSpecificOutput:{hookEventName:"SessionStart", additionalContext:$ac}}'
    else
      jq -nc --arg ac "$1" \
        '{hookSpecificOutput:{hookEventName:"SessionStart", additionalContext:$ac}}'
    fi
  else
    if [[ -n "$2" ]]; then
      printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$2" "$1"
    else
      printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$1"
    fi
  fi
}

# Find the RUNNING plugin version. Claude Code passes the plugin root as $1 (see
# hooks.json): it expands ${CLAUDE_PLUGIN_ROOT} into the command string reliably but does
# NOT guarantee it in the script's environment (it's empty for SessionStart hooks —
# anthropics/claude-code#27145), so we PREFER the argument and treat the env var as only a
# secondary fallback. That root is the version dir executing THIS session — the correct
# thing to compare. (Globbing the cache for the max version is a false negative: a project
# pinned to an older version while a newer one is installed elsewhere would wrongly read as
# up to date.) Fall back to the cache glob only when neither $1 nor the env var is set.
PLUGIN_ROOT="${1:-${CLAUDE_PLUGIN_ROOT:-}}"
if [[ -n "$PLUGIN_ROOT" && -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ]]; then
  INSTALLED=$(read_field "$PLUGIN_ROOT/.claude-plugin/plugin.json" version)
else
  PLUGIN_DIR=$(ls -d "$HOME/.claude/plugins/cache/swarms/swarm/"*/ 2>/dev/null | sort -V | tail -1)
  [[ -n "$PLUGIN_DIR" ]] && INSTALLED=$(read_field "${PLUGIN_DIR%/}/.claude-plugin/plugin.json" version)
fi
[[ -z "$INSTALLED" ]] && exit 0

# Phase 1: Background fetch (rate-limited to once per 24h). Detached and fully silenced.
(
  if [[ -f "$CACHE_FILE" ]]; then
    LAST=$(grep -o '"fetched_at":[0-9]*' "$CACHE_FILE" 2>/dev/null | grep -o '[0-9]*$')
    LAST=${LAST:-0}
    DIFF=$(( $(date +%s) - LAST ))
    if [[ $DIFF -lt 86400 ]]; then
      # Within the 24h window: skip re-fetch unless the cache says "you're current".
      # If cached_latest == installed, the cache may have been written before a newer
      # version was published — treat it as potentially stale and fall through to re-fetch.
      CACHED=$(read_field "$CACHE_FILE" version)
      [[ "$CACHED" != "$INSTALLED" ]] && exit 0
    fi
  fi
  command -v curl &>/dev/null || exit 0
  RAW=$(curl -sf --max-time 2 "$GITHUB_URL" 2>/dev/null)
  [[ -z "$RAW" ]] && exit 0
  if command -v jq &>/dev/null; then
    LATEST=$(echo "$RAW" | jq -r '.version // empty' 2>/dev/null)
  else
    LATEST=$(echo "$RAW" | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')
  fi
  [[ -n "$LATEST" ]] && printf '{"version":"%s","fetched_at":%s}\n' "$LATEST" "$(date +%s)" > "$CACHE_FILE"
) > /dev/null 2>&1 &

# Phase 2: Display the cached result from a previous fetch.
# Cold cache → silent this run (the background fetch above seeds it for next time).
[[ ! -f "$CACHE_FILE" ]] && exit 0

LATEST=$(read_field "$CACHE_FILE" version)
[[ -z "$LATEST" ]] && exit 0

# Guard: both versions must match the semver charset. Anything else (corrupted fetch,
# malformed/tampered plugin.json) is garbage — never surface it, and this keeps every
# printf interpolation below provably safe without escaping. Covers the jq and grep paths.
[[ "$LATEST" =~ ^[0-9A-Za-z._+-]+$ ]] || exit 0
[[ "$INSTALLED" =~ ^[0-9A-Za-z._+-]+$ ]] || exit 0

# Is LATEST strictly greater than INSTALLED?
HIGHER=$(printf '%s\n%s' "$INSTALLED" "$LATEST" | sort -V | tail -1)
[[ "$HIGHER" == "$LATEST" && "$LATEST" != "$INSTALLED" ]] || exit 0

# An update is available. Prime the assistant every session (additionalContext); show the
# user-visible line (systemMessage) only once per newly-detected version, then stamp it.
ADDITIONAL_CONTEXT="A swarm plugin update is available: v${LATEST} (installed v${INSTALLED}). If you have not already told the user this session, let them know they can upgrade by running /swarm:update."

NOTIFIED=$(read_field "$NOTIFIED_FILE" notified_version)
if [[ "$LATEST" != "$NOTIFIED" ]]; then
  emit_json "$ADDITIONAL_CONTEXT" "Swarm v${LATEST} is available (you have v${INSTALLED}). Run /swarm:update to upgrade."
  printf '{"notified_version":"%s"}\n' "$LATEST" > "$NOTIFIED_FILE"
else
  emit_json "$ADDITIONAL_CONTEXT"
fi
