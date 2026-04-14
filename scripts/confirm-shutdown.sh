#!/bin/bash
# Swarm shutdown gate — PreToolUse hook on SendMessage
#
# Intercepts shutdown_request messages. If the session-scoped flag file
# does not exist, blocks the call and tells the lead to get user confirmation.
# The user creates the flag file; the lead retries; the hook clears it and passes.
#
# Flag file: /tmp/swarm-shutdown-authorized-{session_id}
# Session-scoped so stale files from previous sessions are inert and
# concurrent Claude Code sessions cannot cross-contaminate.

INPUT=$(cat)

# Extract message type — try jq, fall back to python3
if command -v jq &>/dev/null; then
  MSG_TYPE=$(echo "$INPUT" | jq -r '.tool_input.message.type // empty' 2>/dev/null)
  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
else
  MSG_TYPE=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
m = d.get('tool_input', {}).get('message', {})
print(m.get('type', '') if isinstance(m, dict) else '')
" 2>/dev/null)
  SESSION_ID=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('session_id', ''))
" 2>/dev/null)
fi

# Pass through anything that isn't a shutdown_request
[ "$MSG_TYPE" != "shutdown_request" ] && exit 0

# Fail safe if session_id could not be extracted
if [ -z "$SESSION_ID" ]; then
  echo "Shutdown blocked: could not extract session_id from hook input." >&2
  exit 2
fi

FLAG="/tmp/swarm-shutdown-authorized-${SESSION_ID}"

if [ -f "$FLAG" ]; then
  rm -f "$FLAG"
  exit 0  # user confirmed — allow shutdown
fi

# Block the shutdown — lead must ask user directly, not present an interpretation
echo "Shutdown blocked. Ask the user directly: did you want to end the team session? If yes, they run: touch $FLAG — then retry." >&2
exit 2

