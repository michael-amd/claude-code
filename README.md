# Claude Code Setup for AMD LLM Gateway

This repository contains an automated setup script for installing and configuring [Claude Code CLI](https://github.com/anthropics/claude-code) to work with AMD's LLM Gateway.

## Overview

Claude Code is Anthropic's official CLI tool that provides an interactive command-line interface for Claude AI. This setup script configures it to use AMD's LLM Gateway instead of Anthropic's direct API endpoints.

## Features

- 🚀 **Automated Installation**: Interactive setup with menu-driven installation
- 🔧 **Environment Configuration**: Automatically configures Claude Code for AMD LLM Gateway
- 📁 **Flexible Installation**: Choose between HOME directory or current directory installation
- 🛠 **Launcher Creation**: Creates a convenient `claude` launcher in `~/.local/bin`
- ✅ **Dependency Checking**: Validates Node.js version and installs required tools

## Prerequisites

- **Node.js 18+**: Required for Claude Code CLI
  - Install from [https://nodejs.org/en/download](https://nodejs.org/en/download)
- **npm**: Node package manager (usually included with Node.js)
- **AMD LLM API Key**: Valid API key for AMD's LLM Gateway
- **Linux/Unix Environment**: Script designed for bash shell environments

## Quick Start

1. **Clone or download this repository**
2. **Run the setup script**:
   ```bash
   ./setup_claude_code.sh
   ```
3. **Choose installation location** using the interactive menu
4. **Set your API key**:
   ```bash
   export AMD_LLM_API_KEY='your-api-key-here'
   ```
5. **Start using Claude**:
   ```bash
   claude
   ```

## Installation Options

The setup script provides two installation options:

1. **HOME Directory**: Installs to `$HOME/node_modules/.bin/claude`
2. **Current Directory**: Installs to `$(pwd)/node_modules/.bin/claude`

Both options create a launcher script at `~/.local/bin/claude` for easy access.

## Configuration

### Environment Variables

The launcher script automatically sets these environment variables:

- `ANTHROPIC_API_KEY`: Set to "dummy" (not used with gateway)
- `ANTHROPIC_BASE_URL`: Points to AMD LLM Gateway
- `ANTHROPIC_CUSTOM_HEADERS`: Sets subscription key from `AMD_LLM_API_KEY`
- `ANTHROPIC_DEFAULT_SONNET_MODEL`: claude-sonnet-4
- `ANTHROPIC_DEFAULT_OPUS_MODEL`: claude-opus-4
- `ANTHROPIC_DEFAULT_HAIKU_MODEL`: claude-3.5
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`: Disabled for privacy

### Required Environment Variable

You must set your AMD LLM API key:

**For bash/zsh users** (add to `~/.bashrc` or `~/.zshrc`):
```bash
export AMD_LLM_API_KEY='your-api-key-here'
```

**For csh/tcsh users** (add to `~/.cshrc`):
```csh
setenv AMD_LLM_API_KEY 'your-api-key-here'
```

## Usage Examples

```bash
# Start interactive Claude session
claude

# Run with a specific prompt
claude -p 'Create a script that cleans trailing whitespace from a file'

# Get help
claude --help

# Switch models (inside Claude)
/model
```

## File Structure

```
claude-code/
├── setup_claude_code.sh           # Main setup script
├── scripts/
│   └── claude_launcher_template.sh # Template for launcher script
├── package.json                    # NPM dependencies
└── README.md                       # This file
```

## What the Setup Script Does

1. **Dependency Validation**: Checks for Node.js 18+ and npm
2. **Package Installation**: Installs `@anthropic-ai/claude-code` via npm
3. **Configuration**: Bypasses Claude Code login screens
4. **Launcher Creation**: Creates executable launcher with proper environment setup
5. **PATH Setup**: Provides instructions for adding `~/.local/bin` to PATH

## Troubleshooting

### Node.js Version Issues
If you get Node.js version errors, install Node.js 18+ from [nodejs.org](https://nodejs.org/) or use a version manager like [nvm](https://github.com/nvm-sh/nvm).

### PATH Issues
If `claude` command is not found, ensure `~/.local/bin` is in your PATH:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### API Key Issues
Verify your `AMD_LLM_API_KEY` is set correctly:
```bash
echo $AMD_LLM_API_KEY
```