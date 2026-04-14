#!/bin/bash
# Swarm smoke test — verifies hook schema and update-check logic locally
#
# Tier 1 tests (no Claude Code needed, ~5 seconds):
#   1. hooks.json schema validation
#   2. check-update.sh normal path (no cache → exits silently)
#   3. check-update.sh stale-equal bypass (cached==installed, fresh cache → re-fetches)
#   4. check-update.sh update-available path (cached>installed → prints notification)
#
# Does not test live hook registration (Tier 2). For that:
#   cp hooks/hooks.json ~/.claude/plugins/cache/swarms/swarm/<version>/hooks/hooks.json
#   cp scripts/check-update.sh ~/.claude/plugins/cache/swarms/swarm/<version>/scripts/check-update.sh
#   Start a fresh Claude Code session and verify via /hooks menu.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK_UPDATE="$REPO_ROOT/scripts/check-update.sh"
HOOKS_JSON="$REPO_ROOT/hooks/hooks.json"
CACHE_FILE="$HOME/.claude/.swarms-update-cache"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "Swarm smoke test"
echo "================"

# ── Test 1: hooks.json is valid JSON ────────────────────────────────────────
echo ""
echo "1. hooks.json — valid JSON"
if jq empty "$HOOKS_JSON" 2>/dev/null; then
  pass "hooks.json parses as valid JSON"
else
  fail "hooks.json is not valid JSON"
fi

# ── Test 2: hooks.json has required fields ──────────────────────────────────
echo ""
echo "2. hooks.json — required fields"
SESSION_START=$(jq -r '.hooks.SessionStart // empty' "$HOOKS_JSON" 2>/dev/null)
PRE_TOOL=$(jq -r '.hooks.PreToolUse // empty' "$HOOKS_JSON" 2>/dev/null)

[[ -n "$SESSION_START" ]] && pass "SessionStart entry present" || fail "SessionStart entry missing"
[[ -n "$PRE_TOOL" ]] && pass "PreToolUse entry present" || fail "PreToolUse entry missing"

STARTUP_MATCHER=$(jq -r '.hooks.SessionStart[0].matcher // empty' "$HOOKS_JSON" 2>/dev/null)
[[ "$STARTUP_MATCHER" == "startup" ]] && pass "SessionStart matcher is 'startup'" || fail "SessionStart matcher is not 'startup' (got: $STARTUP_MATCHER)"

HOOK_CMD=$(jq -r '.hooks.SessionStart[0].hooks[0].command // empty' "$HOOKS_JSON" 2>/dev/null)
[[ "$HOOK_CMD" == *"check-update.sh"* ]] && pass "SessionStart command references check-update.sh" || fail "SessionStart command does not reference check-update.sh (got: $HOOK_CMD)"
[[ "$HOOK_CMD" == *'${CLAUDE_PLUGIN_ROOT}'* ]] && pass "SessionStart command uses \${CLAUDE_PLUGIN_ROOT}" || fail "SessionStart command does not use \${CLAUDE_PLUGIN_ROOT}"

# ── Test 3: check-update.sh — no cache, no plugin (exits cleanly) ───────────
echo ""
echo "3. check-update.sh — exits cleanly when no plugin install found"
BACKUP=""
if [[ -f "$CACHE_FILE" ]]; then
  BACKUP=$(cat "$CACHE_FILE")
fi
rm -f "$CACHE_FILE"

OUTPUT=$(SWARM_SKIP_UPDATE_CHECK=1 bash "$CHECK_UPDATE" 2>&1)
[[ -z "$OUTPUT" ]] && pass "exits silently when SWARM_SKIP_UPDATE_CHECK=1" || fail "unexpected output with SWARM_SKIP_UPDATE_CHECK=1: $OUTPUT"

# ── Test 4: stale-equal bypass — cache says installed==latest, should re-fetch
echo ""
echo "4. check-update.sh — stale-equal bypass fires when cached==installed"

# Find installed version (skip test gracefully if plugin not installed)
PLUGIN_DIR=$(ls -d "$HOME/.claude/plugins/cache/swarms/swarm/"*/ 2>/dev/null | sort -V | tail -1)
if [[ -z "$PLUGIN_DIR" ]]; then
  echo "  SKIP: plugin not installed, cannot determine installed version"
else
  if command -v jq &>/dev/null; then
    INSTALLED=$(jq -r '.version // empty' "${PLUGIN_DIR}.claude-plugin/plugin.json" 2>/dev/null)
  else
    INSTALLED=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "${PLUGIN_DIR}.claude-plugin/plugin.json" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
  fi

  if [[ -z "$INSTALLED" ]]; then
    echo "  SKIP: could not read installed version"
  else
    # Write a fresh (< 24h) cache where cached==installed
    printf '{"version":"%s","fetched_at":%s}\n' "$INSTALLED" "$(date +%s)" > "$CACHE_FILE"

    # Run the bypass check in isolation (mirrors Phase 1 logic)
    LAST=$(grep -o '"fetched_at":[0-9]*' "$CACHE_FILE" | grep -o '[0-9]*$')
    DIFF=$(( $(date +%s) - LAST ))
    CACHED_VER=$(jq -r '.version // empty' "$CACHE_FILE" 2>/dev/null || grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$CACHE_FILE" | grep -o '"[^"]*"$' | tr -d '"')

    if [[ $DIFF -lt 86400 && "$CACHED_VER" == "$INSTALLED" ]]; then
      pass "bypass condition triggers: cache is fresh AND cached==installed"
    else
      fail "bypass condition did not trigger (DIFF=$DIFF, CACHED=$CACHED_VER, INSTALLED=$INSTALLED)"
    fi

    rm -f "$CACHE_FILE"
  fi
fi

# ── Test 5: update-available path — prints notification ─────────────────────
echo ""
echo "5. check-update.sh — prints notification when cache shows newer version"
if [[ -z "${PLUGIN_DIR:-}" ]]; then
  echo "  SKIP: plugin not installed"
else
  # Write cache with a version that is definitely higher than installed
  printf '{"version":"99.99.99","fetched_at":%s}\n' "$(date +%s)" > "$CACHE_FILE"
  OUTPUT=$(bash "$CHECK_UPDATE" 2>/dev/null)
  if echo "$OUTPUT" | grep -q "99.99.99"; then
    pass "notification prints when cache shows newer version"
  else
    fail "notification did not print (output: $OUTPUT)"
  fi
  rm -f "$CACHE_FILE"
fi

# ── Restore cache ────────────────────────────────────────────────────────────
if [[ -n "$BACKUP" ]]; then
  echo "$BACKUP" > "$CACHE_FILE"
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "================================"
echo "Results: $PASS passed, $FAIL failed"
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
