#!/bin/bash
# Swarm update notifier — fires on SessionStart hook
#
# Phase 1 (background): fetches latest version from GitHub, writes to cache.
#   Rate-limited to once per 24h, except when cached version == installed version
#   (treats "you're current" as potentially stale and re-fetches immediately).
#   Silent on any network failure.
# Phase 2 (instant): reads cached result, compares against installed version,
#   prints one line if a newer version exists.
#
# Opt-out: set SWARM_SKIP_UPDATE_CHECK=1

CACHE_FILE="$HOME/.claude/.swarms-update-cache"
GITHUB_URL="https://raw.githubusercontent.com/arthrod/swarms/main/.claude-plugin/plugin.json"

[[ "${SWARM_SKIP_UPDATE_CHECK}" == "1" ]] && exit 0

# Find installed version from plugin.json (not directory name — avoids prefix mismatch)
PLUGIN_DIR=$(ls -d "$HOME/.claude/plugins/cache/swarms/swarm/"*/ 2>/dev/null | sort -V | tail -1)
[[ -z "$PLUGIN_DIR" ]] && exit 0

if command -v jq &>/dev/null; then
  INSTALLED=$(jq -r '.version // empty' "${PLUGIN_DIR}.claude-plugin/plugin.json" 2>/dev/null)
else
  INSTALLED=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "${PLUGIN_DIR}.claude-plugin/plugin.json" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
fi
[[ -z "$INSTALLED" ]] && exit 0

# Phase 1: Background fetch (rate-limited to once per 24h)
(
  if [[ -f "$CACHE_FILE" ]]; then
    LAST=$(grep -o '"fetched_at":[0-9]*' "$CACHE_FILE" 2>/dev/null | grep -o '[0-9]*$')
    LAST=${LAST:-0}
    DIFF=$(( $(date +%s) - LAST ))
    if [[ $DIFF -lt 86400 ]]; then
      # Within the 24h window: skip re-fetch unless the cache says "you're current".
      # If cached_latest == installed, the cache may have been written before a newer
      # version was published — treat it as potentially stale and fall through to re-fetch.
      if command -v jq &>/dev/null; then
        CACHED=$(jq -r '.version // empty' "$CACHE_FILE" 2>/dev/null)
      else
        CACHED=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$CACHE_FILE" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
      fi
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

# Phase 2: Display cached result from previous fetch
[[ ! -f "$CACHE_FILE" ]] && exit 0

if command -v jq &>/dev/null; then
  LATEST=$(jq -r '.version // empty' "$CACHE_FILE" 2>/dev/null)
else
  LATEST=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$CACHE_FILE" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
fi
[[ -z "$LATEST" ]] && exit 0

# Is LATEST strictly greater than INSTALLED?
HIGHER=$(printf '%s\n%s' "$INSTALLED" "$LATEST" | sort -V | tail -1)
if [[ "$HIGHER" == "$LATEST" && "$LATEST" != "$INSTALLED" ]]; then
  echo "Swarm v${LATEST} is available (you have v${INSTALLED}). Run /swarm:update to upgrade."
fi
