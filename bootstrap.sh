#!/bin/bash
set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}==>${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

pause_for_input() {
    echo ""
    read -p "Press ENTER to continue..."
    echo ""
}

confirm() {
    local prompt="$1"
    local response
    while true; do
        read -p "$prompt (y/n): " response
        case "$response" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

# Banner
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                   macOS Setup Script                       ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

log_info "This script will set up your macOS environment"
log_info "See MANUAL_STEPS.md for what to expect"
echo ""

# Confirm before proceeding
if ! confirm "Ready to begin?"; then
    log_warn "Setup cancelled. Run this script again when ready."
    exit 0
fi

# =============================================================================
# Phase 1: Install Homebrew
# =============================================================================

echo ""
log_info "Phase 1: Homebrew Installation"
echo ""

if command -v brew &> /dev/null; then
    log_success "Homebrew already installed"
    brew --version
else
    log_info "Installing Homebrew (this will also install Xcode CLI tools)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH (for Apple Silicon Macs)
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    log_success "Homebrew installed successfully"
fi

# =============================================================================
# Phase 2: Install Packages via Brewfile
# =============================================================================

echo ""
log_info "Phase 2: Installing Packages"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "$SCRIPT_DIR/Brewfile" ]; then
    log_info "Installing packages from Brewfile..."
    brew bundle --file="$SCRIPT_DIR/Brewfile"
    log_success "All packages installed"
else
    log_error "Brewfile not found at $SCRIPT_DIR/Brewfile"
    exit 1
fi

# =============================================================================
# Phase 3: Configure 1Password
# =============================================================================

echo ""
log_info "Phase 3: 1Password Configuration"
echo ""

# Skip manual setup if CLI is already authenticated
if op vault list &> /dev/null; then
    log_success "1Password CLI already authenticated"
else
    log_warn "1Password needs manual configuration"
    echo ""
    echo "Please complete these steps:"
    echo "  1. Launch 1Password application"
    echo "  2. Sign in to your account"
    echo "  3. Go to Settings → Developer"
    echo "  4. Enable 'Use the SSH agent'"
    echo "  5. Enable 'Connect with 1Password CLI'"
    echo ""

    pause_for_input

    # Authenticate 1Password CLI
    log_info "Authenticating 1Password CLI..."
    if ! op account list &> /dev/null; then
        log_info "Running 'op signin' - follow prompts in your browser..."
        eval $(op signin)
    fi

    # Verify
    if op vault list &> /dev/null; then
        log_success "1Password CLI authenticated successfully"
    else
        log_error "1Password CLI authentication failed"
        log_error "Please run 'op signin' manually and try again"
        exit 1
    fi
fi

# =============================================================================
# Phase 4: Private Config Repo
# =============================================================================
#
# This is hardcoded to MY private repo. If you're not me, you should:
# 1. Fork this repo
# 2. Create your own private config repo
# 3. Update PRIVATE_REPO_URL below to point to yours
#
# "But isn't it insecure to hardcode a private repo URL?"
# No. The private repo just contains:
#   - References to 1Password item IDs (not the actual secrets)
#   - Personal dotfiles and preferences
#   - Setup scripts that PULL secrets from 1Password at runtime
#
# Actual secrets never touch git. Even in the private repo.
# The private repo is just my personal automation layer.
#
# If someone steals your GitHub creds, you have bigger problems than
# them seeing which 1Password items you reference.

echo ""
log_info "Phase 4: Private Config Repository"
echo ""

PRIVATE_CONFIG_DIR="$HOME/.mac-bootstrap-config"
PRIVATE_REPO_URL="git@github.com:lonnyhuff/the-setup-private.git"

# Check if someone is trying to use my private repo (which won't work for them)
CURRENT_USER=$(whoami)
if [[ "$CURRENT_USER" != "lonnyhuff" ]] && [[ ! -d "$PRIVATE_CONFIG_DIR" ]]; then
    log_warn "Hold up! You're trying to use my hardcoded private repo."
    echo ""
    echo "That won't work for you because:"
    echo "  1. It's private (you don't have access)"
    echo "  2. It contains MY 1Password item IDs (not yours)"
    echo "  3. It's personalized for MY workflow"
    echo ""
    echo "You should:"
    echo "  1. Fork this repo"
    echo "  2. Create your own private config repo"
    echo "  3. Update PRIVATE_REPO_URL in bootstrap.sh"
    echo ""
    if confirm "Skip private config and use defaults?"; then
        export HAS_PRIVATE_CONFIG=false
        log_info "Skipping private config (using minimal defaults)"
    else
        log_error "Exiting. Update PRIVATE_REPO_URL in bootstrap.sh and try again."
        exit 1
    fi
else
    # Either it's me, or the directory already exists (they set it up manually)
    if [ -d "$PRIVATE_CONFIG_DIR" ]; then
        log_info "Updating private config..."
        git -C "$PRIVATE_CONFIG_DIR" pull --quiet 2>/dev/null && \
            log_success "Private config updated" || \
            log_success "Private config up to date"
        export HAS_PRIVATE_CONFIG=true
    else
        log_info "Cloning private config repository..."
        if git clone "$PRIVATE_REPO_URL" "$PRIVATE_CONFIG_DIR" 2>/dev/null; then
            log_success "Private config cloned to $PRIVATE_CONFIG_DIR"
            export HAS_PRIVATE_CONFIG=true
        else
            log_warn "Couldn't clone private config (probably don't have access)"
            log_info "Continuing with minimal defaults..."
            export HAS_PRIVATE_CONFIG=false
        fi
    fi
fi

# =============================================================================
# Phase 5: Run Setup Scripts
# =============================================================================

echo ""
log_info "Phase 5: Running Setup Scripts"
echo ""

# Run numbered scripts in order
for script in "$SCRIPT_DIR"/scripts/[0-9][0-9]-*.sh; do
    if [ -f "$script" ]; then
        log_info "Running $(basename "$script")..."
        bash "$script"
        log_success "$(basename "$script") completed"
    fi
done

# =============================================================================
# Done! Summary
# =============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                     Setup Complete!                        ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Reload shell environment so we can verify tools
source "$HOME/.zshrc" 2>/dev/null || true

log_info "Configuration summary:"
echo ""

# Homebrew packages
brew_formulae=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
brew_casks=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
log_success "Homebrew: $brew_formulae formulae, $brew_casks casks installed"

# CLI tools
for tool in git gh node python3 aws gcloud nmap op tailscale starship; do
    if command -v "$tool" &> /dev/null; then
        version=$("$tool" --version 2>&1 | head -1)
        log_success "$tool: $version"
    else
        log_warn "$tool: not found"
    fi
done

# GAM (not in PATH by default, check directly)
if [ -f "$HOME/bin/gam7/gam" ]; then
    gam_version=$("$HOME/bin/gam7/gam" version 2>&1 | head -1)
    log_success "gam: $gam_version"
else
    log_warn "gam: not installed"
fi

# Shell config
echo ""
if [ -f "$HOME/.zshrc" ]; then
    log_success "Shell config: ~/.zshrc"
fi

# Dotfiles
if [ -d "$HOME/.config" ]; then
    dotfile_count=$(ls -1 "$HOME/.config" 2>/dev/null | wc -l | tr -d ' ')
    log_success "Dotfiles: $dotfile_count items in ~/.config"
fi

# Private config
if [ "$HAS_PRIVATE_CONFIG" = true ]; then
    private_scripts=$(ls -1 "$PRIVATE_CONFIG_DIR/scripts"/[0-9][0-9]-*.sh 2>/dev/null | wc -l | tr -d ' ')
    log_success "Private config: $private_scripts script(s) from $PRIVATE_CONFIG_DIR"
fi

# macOS tweaks
log_success "macOS system preferences: configured"

echo ""
log_warn "Apps that may need manual setup: Raycast, Slack, Signal, Notion, Spotify"
echo ""
