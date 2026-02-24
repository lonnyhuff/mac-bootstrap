#!/bin/bash
# 03-dotfiles.sh
# Install dotfiles from private config repo or use defaults
#
# How it works:
# - Looks for your-private-config/dotfiles/*
# - Each file needs header comments at the top:
#     # BOOTSTRAP_DEST: ~/.zshrc
#     # BOOTSTRAP_BACKUP: true
#     <your actual file content starts here>
#
# - Script reads the headers, copies to destination, strips the headers out
# - If no private repo, creates minimal defaults (Homebrew path, 1Password SSH agent, basic aliases)
#
# Idempotent: only writes files that have changed. Safe to run multiple times.

set -e

echo "Setting up dotfiles..."

PRIVATE_CONFIG_DIR="$HOME/.mac-bootstrap-config"

# Check if private config repo exists
if [ "$HAS_PRIVATE_CONFIG" = true ] && [ -d "$PRIVATE_CONFIG_DIR/dotfiles" ]; then
    echo "⚙ Installing dotfiles from private config..."

    installed=0
    skipped=0

    # Parse dotfiles with DEST headers and install them
    # Note: dotglob is needed to match files starting with . (e.g., .zshrc, .gitconfig)
    shopt -s dotglob
    for file in "$PRIVATE_CONFIG_DIR/dotfiles"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")

            # Extract destination from file header (e.g., # BOOTSTRAP_DEST: ~/.zshrc)
            dest=$(grep "^# BOOTSTRAP_DEST:" "$file" | head -1 | sed 's/^# BOOTSTRAP_DEST: //')
            backup=$(grep "^# BOOTSTRAP_BACKUP:" "$file" | head -1 | sed 's/^# BOOTSTRAP_BACKUP: //')

            if [ -n "$dest" ]; then
                # Expand ~ to home directory
                dest="${dest/#\~/$HOME}"

                # Create directory if needed
                mkdir -p "$(dirname "$dest")"

                # Generate content with headers stripped
                new_content=$(grep -v "^# BOOTSTRAP_" "$file")

                # Only write if content differs
                if [ -f "$dest" ] && [ "$(cat "$dest")" = "$new_content" ]; then
                    skipped=$((skipped + 1))
                else
                    # Backup existing file if requested (only on first install)
                    if [ "$backup" = "true" ] && [ -f "$dest" ] && [ ! -f "${dest}.backup" ]; then
                        echo "  Backing up existing $(basename "$dest") to ${dest}.backup"
                        cp "$dest" "${dest}.backup"
                    fi

                    echo "  Installing $filename → $dest"
                    echo "$new_content" > "$dest"
                    installed=$((installed + 1))
                fi
            else
                echo "  Skipping $filename (no BOOTSTRAP_DEST header)"
            fi
        fi
    done

    if [ $installed -gt 0 ]; then
        echo "✓ Installed $installed dotfile(s)"
    fi
    if [ $skipped -gt 0 ]; then
        echo "✓ $skipped dotfile(s) already up to date"
    fi
else
    echo "⚠ No private config repo found, using minimal defaults..."

    # Create minimal .gitconfig if it doesn't exist
    if [ ! -f "$HOME/.gitconfig" ]; then
        echo "⚙ Creating minimal .gitconfig..."
        cat > "$HOME/.gitconfig" << 'EOF'
[user]
	email = your@email.com
	name = Your Name
[core]
	editor = vim
[init]
	defaultBranch = main
EOF
        echo "✓ Created .gitconfig (update your name/email)"
    else
        echo "✓ .gitconfig already exists"
    fi

    # Create minimal .zshrc if it doesn't exist
    if [ ! -f "$HOME/.zshrc" ]; then
        echo "⚙ Creating minimal .zshrc..."
        cat > "$HOME/.zshrc" << 'EOF'
# Homebrew
if [[ $(uname -m) == 'arm64' ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 1Password SSH Agent
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Aliases
alias ll='ls -lah'
alias gs='git status'
alias gd='git diff'

# PATH
export PATH="$HOME/bin:$PATH"
EOF
        echo "✓ Created minimal .zshrc"
    else
        echo "✓ .zshrc already exists"
    fi
fi

echo ""
echo "Dotfiles setup complete!"
