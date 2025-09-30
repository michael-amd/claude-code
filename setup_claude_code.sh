#!/bin/bash
#
# setup_claude_code.sh - Claude Code installation script for AMD LLM Gateway
#
# author: christian.deangelis@amd.com and claude
#
# This script automates the installation and configuration of Claude Code CLI
# for use with AMD's LLM Gateway. It handles installation and creates a launcher script with proper environment setup.
#
# The script will prompt for installation location (HOME or current directory)
# and guide through the setup process including API key configuration.
#

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create the claude launcher
create_claude_launcher() {
    local install_dir="$1"
    local launcher_dir="$HOME/.local/bin"
    local launcher_path="${launcher_dir}/claude"
    local claude_binary="${install_dir}/node_modules/.bin/claude"

    # Create .local/bin directory if it doesn't exist
    mkdir -p "$launcher_dir"

    # Generate launcher from template
    sed "s|SCRIPT_DIR_PLACEHOLDER|${SCRIPT_DIR}|g; s|CLAUDE_BINARY_PATH|${claude_binary}|g" \
        "${SCRIPT_DIR}/scripts/claude_launcher_template.sh" > "$launcher_path"

    # Make it executable
    chmod +x "$launcher_path"

    print_success "Claude launcher created at: $launcher_path"
}


# Installation function
install_claude() {
    local install_dir="$1"
    clear
    print_info "Installing Claude Code to: ${install_dir}/node_modules/.bin/claude"
    print_warning "press Ctrl+C to cancel..."
    sleep 3

    # Load nvm if available
    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        export NVM_DIR="$HOME/.nvm"
        source "$NVM_DIR/nvm.sh"
        # Use Node.js 18 if available
        if nvm list | grep -q "v18"; then
            nvm use 18 >/dev/null 2>&1
        fi
    fi
    
    # Check if we have Node.js 18+ and npm
    print_info "Checking Node.js version..."
    node_version=$(node --version 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1)
    
    if [[ -z "$node_version" ]] || [[ "$node_version" -lt 18 ]]; then
        print_error "Node.js version 18+ is required. Current version: $(node --version 2>/dev/null || echo 'not found')"
        print_info "Please install Node.js 18+ from https://nodejs.org/ or use a version manager like nvm"
        exit 1
    else
        print_success "Node.js version $(node --version) is sufficient."
    fi
    
    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        print_error "npm is not found. Please install npm or use a Node.js installation that includes npm."
        exit 1
    fi

    print_info "Installing @anthropic-ai/claude-code..."
    cd "$install_dir"

    # Create package.json if it doesn't exist
    if [[ ! -f "package.json" ]]; then
        print_info "Creating package.json..."
        echo '{"name": "claude-code-install", "version": "1.0.0"}' > package.json
    fi

    npm install --no-fund --no-audit @anthropic-ai/claude-code

    if [[ $? -eq 0 ]]; then
        print_success "Claude Code installed successfully to ${install_dir}/node_modules/.bin/claude"

        # Configure Claude to bypass login screen
        CLAUDE_CONFIG="$HOME/.claude.json"

        # Ensure jq is available
        if ! command -v jq &> /dev/null; then
            print_warning "jq is not available. Installing via package manager..."
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y jq
            elif command -v yum &> /dev/null; then
                sudo yum install -y jq
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y jq
            else
                print_error "Cannot install jq automatically. Please install jq manually."
                exit 1
            fi
        fi

        # Create file if it doesn't exist
        if [[ ! -f "$CLAUDE_CONFIG" ]]; then
            echo '{}' > "$CLAUDE_CONFIG"
        fi

        jq '
          . + {"hasCompletedOnboarding": true} +
          {
            "customApiKeyResponses": (
              if has("customApiKeyResponses") then
                .customApiKeyResponses + {
                  "approved": (
                    if .customApiKeyResponses | has("approved") then
                      (.customApiKeyResponses.approved + ["dummy"]) | unique
                    else
                      ["dummy"]
                    end
                  ),
                  "rejected": (
                    if .customApiKeyResponses | has("rejected") then
                      .customApiKeyResponses.rejected
                    else
                      []
                    end
                  )
                }
              else
                {
                  "approved": ["dummy"],
                  "rejected": []
                }
              end
            )
          }
        ' "$CLAUDE_CONFIG" > "${CLAUDE_CONFIG}.tmp" && mv "${CLAUDE_CONFIG}.tmp" "$CLAUDE_CONFIG"

        # Create the claude launcher
        create_claude_launcher "${install_dir}"

        echo
        print_success "🎉 Claude Code Setup Complete! 🎉"
        echo
        print_info "=== SAMPLE COMMANDS ==="
        print_info "Start Claude:           claude"
        print_info "Run with prompt:        claude -p 'Create a script that cleans trailing whitespace from a file'"
        print_info "Switch models:          /model (inside Claude)"
        print_info "Get help:               claude --help"
        echo
        echo "=== REQUIRED NEXT STEPS ==="
        echo "1. Set AMD_LLM_API_KEY to your API key. You should add this to your .env or startup file (.cshrc or .bash_profile/.bashrc or equivalent)"
        echo "   bash:     export AMD_LLM_API_KEY='your_api_key_here'"
        echo "   csh/tcsh: setenv AMD_LLM_API_KEY 'your_api_key_here'"
        echo
        if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
            echo "2. Restart your shell or source your startup file"
			echo "3. Start using Claude: claude"
        else
            echo "2. Add ~/.local/bin to your PATH: (add this to you startup file as well)"
            echo "   bash:     export PATH=\"\$HOME/.local/bin:\$PATH\""
            echo "   csh/tcsh: set path = (\$path \$HOME/.local/bin)"
			echo "3. Restart your shell or source your startup file"
            echo "4. Start using Claude: claude"
        fi
        echo "run into issues? contact christian.deangelis@amd.com"
        echo
        exit 0
    else
        print_error "Installation failed. Please check the error messages above."
        exit 1
    fi
}

# Menu options with descriptions
options=("Install to HOME directory ($HOME/node_modules/.bin/claude)" "Install to current directory: ($(pwd)/node_modules/.bin/claude)" "Exit setup")
selected=0

# Function to draw the menu
draw_menu() {
    clear
    echo "═══════════════════════════════════════════════════════════════"
    echo "                    Claude Code Setup"
    echo "═══════════════════════════════════════════════════════════════"
    echo
    echo "Setup Claude Code via the AMD LLM Gateway"
    echo "issues? contact christian.deangelis@amd.com"
    echo
    echo "Choose installation location:"
    echo

    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo "  → $((i+1)). ${options[$i]}"
        else
            echo "    $((i+1)). ${options[$i]}"
        fi
        echo
    done

    echo "Use ↑/↓ arrows or 1/2/3 to select, Enter to confirm"
}

# Main menu loop
while true; do
    draw_menu

    # Read a single character
    read -rsn1 key

    # Handle special keys (arrow keys send 3 characters: ESC [ A/B)
    case $key in
        $'\e')  # ESC sequence
            read -rsn2 key
            case $key in
                '[A') # Up arrow
                    ((selected--))
                    if [ $selected -lt 0 ]; then
                        selected=$((${#options[@]} - 1))
                    fi
                    ;;
                '[B') # Down arrow
                    ((selected++))
                    if [ $selected -ge ${#options[@]} ]; then
                        selected=0
                    fi
                    ;;
            esac
            ;;
        '') # Enter key
            case $selected in
                0)
                    install_claude "$HOME"
                    ;;
                1)
                    install_claude "$(pwd)"
                    ;;
                2)
                    clear
                    print_info "Installation cancelled."
                    print_info "If you want to install elsewhere, cd to that directory and run this script again."
                    exit 0
                    ;;
            esac
            ;;
        '1') # Number 1 - immediate selection
            install_claude "$HOME"
            ;;
        '2') # Number 2 - immediate selection
            install_claude "$(pwd)"
            ;;
        '3') # Number 3 - immediate selection
            clear
            print_info "Installation cancelled."
            print_info "If you want to install elsewhere, cd to that directory and run this script again."
            exit 0
            ;;
    esac
done
