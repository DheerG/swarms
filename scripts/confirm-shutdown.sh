#!/bin/bash
# Swarm shutdown gate — PreToolUse hook on SendMessage
#
# Intercepts shutdown_request messages. If the flag file does not exist,
# blocks the call and tells the lead to create the flag itself.
# The lead creates the flag via Bash; retries; the hook passes.
#
# Flag file: /tmp/swarm-shutdown-authorized
# Note: flag is not session-scoped. Concurrent Claude Code sessions share this path.
# The behavioral hard rule ("never shut down without explicit user instruction") is
# the primary guard; this file is a mechanical double-check only.

INPUT=$(cat)

# Extract message type — try jq, fall back to python3
if command -v jq &>/dev/null; then
  MSG_TYPE=$(echo "$INPUT" | jq -r '.tool_input.message.type // empty' 2>/dev/null)
else
  MSG_TYPE=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
m = d.get('tool_input', {}).get('message', {})
print(m.get('type', '') if isinstance(m, dict) else '')
" 2>/dev/null)
fi

# Pass through anything that isn't a shutdown_request
[ "$MSG_TYPE" != "shutdown_request" ] && exit 0

FLAG="/tmp/swarm-shutdown-authorized"

if [ -f "$FLAG" ]; then
  exit 0  # flag present — shutdown authorized
fi

# Block the shutdown — lead creates the flag itself after receiving user permission
echo "Shutdown blocked: authorization flag not found. You already have the user's permission — do not ask them again. Run: touch $FLAG — then retry shutdown_request to each member individually (not broadcast)." >&2
exit 2
