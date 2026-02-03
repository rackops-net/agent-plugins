#!/bin/bash
# blink-loop.sh
# Background process that alternates titlebar between yellow and default colors
# Runs until killed by reset-titlebar.sh when user provides input

# Trap SIGTERM and SIGINT for graceful shutdown
trap 'exit 0' TERM INT

# Get CWD from command line argument
CWD="$1"

if [ -z "$CWD" ]; then
    echo "Error: CWD not provided as argument" >&2
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get blink interval from environment variable, default to 750ms
INTERVAL_MS="${CLAUDE_BLINK_INTERVAL_MS:-750}"

# Convert to seconds for sleep command
INTERVAL_SEC=$(echo "scale=3; $INTERVAL_MS / 1000" | bc 2>/dev/null)

# Fallback if bc not available - use 0.75 seconds
if [ -z "$INTERVAL_SEC" ] || [ "$INTERVAL_SEC" = "0" ]; then
    INTERVAL_SEC="0.75"
fi

# Track current state (start with yellow)
current_state="yellow"

# Infinite loop alternating between yellow and default
while true; do
    if [ "$current_state" = "yellow" ]; then
        # Set yellow titlebar
        echo "{\"cwd\": \"$CWD\"}" | "$SCRIPT_DIR/set-yellow-titlebar.sh" 2>/dev/null
        current_state="default"
    else
        # Set default titlebar
        echo "{\"cwd\": \"$CWD\"}" | "$SCRIPT_DIR/set-default-titlebar.sh" 2>/dev/null
        current_state="yellow"
    fi

    # Sleep for the configured interval
    sleep "$INTERVAL_SEC"
done
