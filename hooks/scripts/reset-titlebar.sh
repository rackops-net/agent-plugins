#!/bin/bash
# reset-titlebar.sh
# Reset VSCode titlebar to default colors by removing custom color settings

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
SETTINGS_FILE="$CWD/.vscode/settings.json"

# If .vscode directory doesn't exist, nothing to reset
if [ ! -d "$CWD/.vscode" ]; then
    exit 0
fi

# If settings.json doesn't exist, nothing to reset
if [ ! -f "$SETTINGS_FILE" ]; then
    exit 0
fi

# Create a backup of the settings file
BACKUP_FILE="$SETTINGS_FILE.backup"
cp "$SETTINGS_FILE" "$BACKUP_FILE"

# Remove titlebar color customizations
# We remove the entire titleBar object from workbench.colorCustomizations
UPDATED_SETTINGS=$(jq 'if .["workbench.colorCustomizations"] then
  .["workbench.colorCustomizations"] |= del(.["titleBar.activeBackground"], .["titleBar.activeForeground"], .["titleBar.inactiveBackground"], .["titleBar.inactiveForeground"])
  else . end |
  if .["workbench.colorCustomizations"] and (.["workbench.colorCustomizations"] | length) == 0 then
    del(.["workbench.colorCustomizations"])
  else . end' "$SETTINGS_FILE")

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
