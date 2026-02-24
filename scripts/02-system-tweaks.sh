#!/bin/bash
# 02-system-tweaks.sh
# macOS system preferences and tweaks for a minimal dev environment

set -e

echo "Applying system tweaks..."

# =============================================================================
# TouchID for sudo
# =============================================================================

if ! grep -q "pam_tid.so" /etc/pam.d/sudo 2>/dev/null; then
    echo "⚙ Enabling TouchID for sudo..."
    sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
    sudo sed -i '' '1 a\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo
    echo "✓ TouchID enabled for sudo"
else
    echo "✓ TouchID for sudo already enabled"
fi

# =============================================================================
# Keyboard & Input
# =============================================================================

echo "⚙ Configuring keyboard and input..."

# Enable key repeat (disable press-and-hold for accents)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a faster keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart quotes and dashes (annoying for coding)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "✓ Keyboard and input configured"

# =============================================================================
# Finder
# =============================================================================

echo "⚙ Configuring Finder..."

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Display full POSIX path in Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Use list view in all Finder windows
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Avoid creating .DS_Store files on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

echo "✓ Finder configured (list view by default)"

# =============================================================================
# Dock - Minimal Setup
# =============================================================================

echo "⚙ Configuring Dock (minimal)..."

# Remove all apps from Dock
defaults write com.apple.dock persistent-apps -array

# Set Dock icon size
defaults write com.apple.dock tilesize -int 48

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hide delay
defaults write com.apple.dock autohide-delay -float 0

# Speed up dock show/hide animation
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Don't show recent applications
defaults write com.apple.dock show-recents -bool false

# Don't animate opening applications
defaults write com.apple.dock launchanim -bool false

echo "✓ Dock configured (empty and hidden)"

# =============================================================================
# Screenshots
# =============================================================================

echo "⚙ Configuring screenshots..."

# Save screenshots to Downloads folder
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

# Save screenshots in PNG format
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

echo "✓ Screenshots configured"

# =============================================================================
# UI/UX Improvements
# =============================================================================

echo "⚙ Configuring UI/UX..."

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable window animations (faster)
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

echo "✓ UI/UX configured"

# =============================================================================
# Trackpad & Mouse
# =============================================================================

echo "⚙ Configuring trackpad and mouse..."

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Enable three finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

echo "✓ Trackpad and mouse configured"

# =============================================================================
# Apply Changes
# =============================================================================

# Only restart UI processes on first run (check a known setting as a sentinel)
CURRENT_DOCK_RECENTS=$(defaults read com.apple.dock show-recents 2>/dev/null || echo "1")
if [ "$CURRENT_DOCK_RECENTS" != "0" ]; then
    echo "⚙ Restarting affected applications..."
    killall Finder 2>/dev/null || true
    killall Dock 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
    echo "✓ System tweaks applied (UI refreshed)"
else
    echo "✓ System tweaks already applied"
fi

echo ""
echo "Note: Some changes require a logout/login to take full effect"
