#!/bin/bash
# start-blink-titlebar.sh
# Starts the titlebar blink background process
# Called by the Stop hook when Claude finishes responding

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "$SCRIPT_DIR/common.sh"

# Check if jq is installed
if ! check_jq; then
    exit 0  # Exit gracefully to not block Claude
fi

# Read hook input from stdin
INPUT=$(cat)

# Extract the current working directory from hook input
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

if [ -z "$CWD" ]; then
    echo "Error: Could not determine current working directory from hook input" >&2
    exit 0
fi

# Get PID file location
PID_FILE=$(get_pid_file "$CWD")

# Cleanup any existing blink process to prevent orphans
cleanup_blink_process "$PID_FILE"

# Start new blink process in background
"$SCRIPT_DIR/blink-loop.sh" "$CWD" > /dev/null 2>&1 &
BLINK_PID=$!

# Save PID to file for later cleanup
echo "$BLINK_PID" > "$PID_FILE"

exit 0
