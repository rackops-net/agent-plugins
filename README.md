# VSCode Titlebar Color Plugin for Claude Code

A Claude Code plugin that automatically manages VSCode window titlebar colors based on Claude's state, providing visual feedback about whether Claude is actively working or waiting for your input.

## Features

- **Automatic Color Management**: Titlebar colors change automatically based on Claude's state
- **Visual Feedback**: Know at a glance if Claude is waiting for input (yellow titlebar) or actively working (default colors)
- **Non-Intrusive**: Uses Claude Code's hook system to work seamlessly in the background
- **Safe**: Gracefully handles edge cases and preserves your existing VSCode settings

## How It Works

The plugin uses two Claude Code hooks:

1. **UserPromptSubmit Hook**: When you submit a prompt to Claude, the titlebar resets to default colors
2. **Stop Hook**: When Claude finishes responding and is waiting for input, the titlebar changes to yellow

## Requirements

- [Claude Code](https://claude.com/claude-code) installed and configured
- [jq](https://stedolan.github.io/jq/) for JSON manipulation
- VSCode with a project that has a `.vscode` directory

### Installing jq

**macOS (Homebrew)**:
```bash
brew install jq
```

**Linux (apt)**:
```bash
sudo apt-get install jq
```

**Linux (yum)**:
```bash
sudo yum install jq
```

**Windows**:
Download from [jq releases](https://github.com/stedolan/jq/releases)

## Installation

### Method 1: As a Claude Code Plugin (Recommended)

1. Clone this repository to your Claude Code plugins directory:
```bash
git clone https://github.com/yourusername/vsclaude-titlebar-plugin.git ~/.claude/plugins/vsclaude-titlebar
```

2. Enable the plugin through Claude Code's plugin system:
```bash
claude --enable-plugin vsclaude-titlebar
```

### Method 2: Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/vsclaude-titlebar-plugin.git
```

2. Copy the hook configuration to your Claude Code settings:
```bash
# For all projects (user-wide)
cp hooks/hooks.json ~/.claude/hooks/

# OR for a specific project
cp hooks/hooks.json /path/to/your/project/.claude/hooks/
```

3. Update the paths in `hooks.json` to point to the scripts:
```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "hooks": [{
        "type": "command",
        "command": "/absolute/path/to/hooks/scripts/reset-titlebar.sh",
        "timeout": 5
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "/absolute/path/to/hooks/scripts/set-yellow-titlebar.sh",
        "timeout": 5
      }]
    }]
  }
}
```

## Usage

Once installed, the plugin works automatically:

1. Start a Claude Code session in a project with VSCode open
2. Submit a prompt - the titlebar should reset to default colors
3. Wait for Claude to finish responding - the titlebar should change to yellow
4. Submit another prompt - the titlebar resets again

## Titlebar Colors

The plugin uses these colors when Claude is waiting for input:

- **Active titlebar**: Amber (#f59e0b) with black text (#000000)
- **Inactive titlebar**: Light amber (#fbbf24) with gray text (#666666)

These colors are designed to be noticeable but not distracting.

## Configuration

You can customize the titlebar colors by editing [hooks/scripts/set-yellow-titlebar.sh](hooks/scripts/set-yellow-titlebar.sh):

```bash
TITLEBAR_COLORS='{
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#your-color-here",
    "titleBar.activeForeground": "#your-text-color",
    "titleBar.inactiveBackground": "#your-inactive-color",
    "titleBar.inactiveForeground": "#your-inactive-text"
  }
}'
```

## Troubleshooting

### Titlebar colors aren't changing

1. Check that jq is installed: `which jq`
2. Check that the scripts are executable: `ls -la hooks/scripts/`
3. Enable verbose mode in Claude Code with `Ctrl+O` to see hook output
4. Check Claude Code logs: `claude --debug`

### Settings are being reset unexpectedly

The reset script only removes titlebar color settings, not other customizations. If you're experiencing issues, check your `.vscode/settings.json.backup` file which is created before each modification.

### jq errors

Make sure you have jq version 1.6 or later:
```bash
jq --version
```

## File Structure

```
vsclaude-titlebar-plugin/
├── package.json                     # Project metadata
├── README.md                        # This file
├── hooks/
│   ├── hooks.json                  # Claude Code hook configuration
│   └── scripts/
│       ├── reset-titlebar.sh       # Reset titlebar colors
│       └── set-yellow-titlebar.sh  # Set titlebar to yellow
└── .gitignore
```

## How It Works Technically

### Hook Events

1. **UserPromptSubmit**: Fires when you submit a prompt to Claude
   - Reads the current working directory from hook input
   - Removes titlebar color customizations from `.vscode/settings.json`
   - Preserves all other VSCode settings

2. **Stop**: Fires when Claude finishes responding
   - Reads the current working directory from hook input
   - Merges yellow titlebar colors into `.vscode/settings.json`
   - Creates `.vscode` directory if needed

### Safety Features

- Creates backups before modifying settings
- Restores from backup on any error
- Exits gracefully (exit 0) on errors to not block Claude
- Checks for jq installation before running
- Handles missing directories and files gracefully

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details

## Credits

Built for [Claude Code](https://claude.com/claude-code) by Anthropic

## Related Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [VSCode Color Customization](https://code.visualstudio.com/docs/getstarted/themes#_customize-a-color-theme)
