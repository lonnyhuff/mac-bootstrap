#!/bin/bash
# 01-prerequisites.sh
# Verify all required tools are installed and working

set -e

echo "Checking prerequisites..."

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found"
    exit 1
fi
echo "✓ Homebrew installed"

# Check 1Password CLI
if ! command -v op &> /dev/null; then
    echo "❌ 1Password CLI not found"
    exit 1
fi
echo "✓ 1Password CLI installed"

# Check 1Password authentication
if ! op vault list &> /dev/null; then
    echo "❌ 1Password CLI not authenticated"
    exit 1
fi
echo "✓ 1Password CLI authenticated"

# Check git
if ! command -v git &> /dev/null; then
    echo "❌ git not found"
    exit 1
fi
echo "✓ git installed"

# Check GitHub CLI
if command -v gh &> /dev/null; then
    echo "✓ GitHub CLI installed"

    # Check if authenticated
    if gh auth status &> /dev/null; then
        echo "✓ GitHub CLI authenticated"
    else
        echo "⚠ GitHub CLI not authenticated"
        read -p "Authenticate with GitHub now? (y/n): " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            gh auth login
        fi
    fi
else
    echo "⚠ GitHub CLI not found (optional)"
fi

echo ""
echo "All prerequisites met!"
