#!/bin/bash
# Common utility functions for titlebar management scripts

# Get the PID file path for a given working directory
# Uses MD5 hash of CWD to support multiple workspaces independently
get_pid_file() {
    local cwd="$1"
    if [ -z "$cwd" ]; then
        echo "" >&2
        return 1
    fi

    # Use MD5 hash of CWD for unique PID file per workspace
    local cwd_hash=$(echo -n "$cwd" | md5)
    echo "/tmp/claude-titlebar-blink-${cwd_hash}.pid"
}

# Cleanup any running blink process for the given PID file
# Attempts graceful SIGTERM first, then forces SIGKILL if needed
cleanup_blink_process() {
    local pid_file="$1"

    # If no PID file exists, nothing to cleanup
    if [ ! -f "$pid_file" ]; then
        return 0
    fi

    # Read PID from file
    local pid=$(cat "$pid_file" 2>/dev/null)
    if [ -z "$pid" ]; then
        rm -f "$pid_file"
        return 0
    fi

    # Check if process exists
    if ! ps -p "$pid" > /dev/null 2>&1; then
        # Process already dead, just cleanup PID file
        rm -f "$pid_file"
        return 0
    fi

    # Send SIGTERM for graceful shutdown
    kill -15 "$pid" 2>/dev/null || true

    # Wait up to 1 second for graceful termination
    for i in {1..10}; do
        if ! ps -p "$pid" > /dev/null 2>&1; then
            rm -f "$pid_file"
            return 0
        fi
        sleep 0.1
    done

    # Force kill if still alive
    kill -9 "$pid" 2>/dev/null || true
    sleep 0.1
    rm -f "$pid_file"
}

# Check if jq is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed. Please install jq to use this feature." >&2
        return 1
    fi
    return 0
}
