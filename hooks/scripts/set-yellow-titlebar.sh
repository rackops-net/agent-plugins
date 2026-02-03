#!/bin/bash
# set-yellow-titlebar.sh
# Set VSCode titlebar to yellow color to indicate Claude is waiting for user input

set -e

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq to use this hook." >&2
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

# Define the settings file path
VSCODE_DIR="$CWD/.vscode"
SETTINGS_FILE="$VSCODE_DIR/settings.json"

# Create .vscode directory if it doesn't exist
if [ ! -d "$VSCODE_DIR" ]; then
    mkdir -p "$VSCODE_DIR"
fi

# Define the titlebar color settings
TITLEBAR_COLORS='{
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#f59e0b",
    "titleBar.activeForeground": "#000000",
    "titleBar.inactiveBackground": "#fbbf24",
    "titleBar.inactiveForeground": "#666666"
  }
}'

# If settings.json doesn't exist, create it with titlebar colors
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "$TITLEBAR_COLORS" | jq '.' > "$SETTINGS_FILE"
    exit 0
fi

# Create a backup of the settings file
BACKUP_FILE="$SETTINGS_FILE.backup"
cp "$SETTINGS_FILE" "$BACKUP_FILE"

# Merge titlebar colors into existing settings
# This will override existing titlebar colors but preserve other settings
UPDATED_SETTINGS=$(jq --argjson colors "$TITLEBAR_COLORS" '
  . as $original |
  $colors |
  .["workbench.colorCustomizations"] as $newColors |
  $original |
  .["workbench.colorCustomizations"] = (
    (.["workbench.colorCustomizations"] // {}) + $newColors
  )
' "$SETTINGS_FILE")

# Check if jq command succeeded
if [ $? -eq 0 ]; then
    # Write the updated settings back to the file
    echo "$UPDATED_SETTINGS" > "$SETTINGS_FILE"
    # Remove backup on success
    rm -f "$BACKUP_FILE"
    exit 0
else
    # Restore from backup on failure
    echo "Error: Failed to update settings.json. Restoring from backup." >&2
    mv "$BACKUP_FILE" "$SETTINGS_FILE"
    exit 0  # Exit gracefully to not block Claude
fi
