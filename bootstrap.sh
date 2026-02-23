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
clear
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

log_warn "1Password has been installed, but needs manual configuration"
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

# Verify 1Password CLI works
if op vault list &> /dev/null; then
    log_success "1Password CLI authenticated successfully"
else
    log_error "1Password CLI authentication failed"
    log_error "Please run 'op signin' manually and try again"
    exit 1
fi

# =============================================================================
# Phase 4: Private Config Repo (Optional)
# =============================================================================

echo ""
log_info "Phase 4: Private Config Repository"
echo ""

PRIVATE_CONFIG_DIR="$HOME/.mac-bootstrap-config"

if confirm "Do you have a private mac-bootstrap-config repository?"; then
    read -p "Enter the git clone URL: " PRIVATE_REPO_URL

    if [ -d "$PRIVATE_CONFIG_DIR" ]; then
        log_warn "Config directory already exists at $PRIVATE_CONFIG_DIR"
        if confirm "Pull latest changes?"; then
            cd "$PRIVATE_CONFIG_DIR"
            git pull
            log_success "Private config updated"
        fi
    else
        log_info "Cloning private config repository..."
        git clone "$PRIVATE_REPO_URL" "$PRIVATE_CONFIG_DIR"
        log_success "Private config cloned to $PRIVATE_CONFIG_DIR"
    fi

    export HAS_PRIVATE_CONFIG=true
else
    log_info "Skipping private config repository"
    export HAS_PRIVATE_CONFIG=false
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
# Done!
# =============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                     Setup Complete!                        ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

log_success "Your environment is ready"
echo ""
log_info "Next steps:"
echo "  • Restart your terminal for all changes to take effect"
echo "  • Review installed applications in /Applications"
echo "  • Check ~/.zshrc for shell configurations"
echo ""

if [ "$HAS_PRIVATE_CONFIG" = true ]; then
    log_info "Private config installed from: $PRIVATE_CONFIG_DIR"
fi

echo ""
log_warn "Some applications may need manual setup (Raycast, Slack, etc.)"
echo ""
