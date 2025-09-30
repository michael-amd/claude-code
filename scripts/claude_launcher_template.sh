#!/bin/bash
#
# Claude Code Launcher Script
# This script sets up the environment and launches Claude Code with AMD LLM Gateway
#

# Source environment setup from the setup script directory
SETUP_SCRIPT_DIR="SCRIPT_DIR_PLACEHOLDER"

# Set required environment variables for AMD LLM Gateway
export ANTHROPIC_API_KEY="dummy"
export ANTHROPIC_BASE_URL="https://llm-api.amd.com/Anthropic"
export ANTHROPIC_CUSTOM_HEADERS="Ocp-Apim-Subscription-Key: ${AMD_LLM_API_KEY}"
export ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-4"
export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-3.5"
export ANTHROPIC_SMALL_FAST_MODEL="claude-3.5"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# Load nvm if available to ensure we use Node.js 18+
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
    # Use Node.js 18 if available
    if nvm list | grep -q "v18"; then
        nvm use 18 >/dev/null 2>&1
    fi
fi

# Check if AMD_LLM_API_KEY is set
if [ -z "${AMD_LLM_API_KEY:-}" ]; then
    echo "Error: AMD_LLM_API_KEY is not set."
    echo "Please set it with: export AMD_LLM_API_KEY='your-api-key-here'"
    echo "Or add it to your ~/.bashrc or ~/.profile"
    exit 1
fi

# Launch Claude Code
exec "CLAUDE_BINARY_PATH" "$@"
