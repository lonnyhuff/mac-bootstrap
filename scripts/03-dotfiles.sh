#!/bin/bash
# 03-dotfiles.sh
# Install dotfiles from private config repo or use defaults

set -e

echo "Setting up dotfiles..."

PRIVATE_CONFIG_DIR="$HOME/.mac-bootstrap-config"

# Check if private config repo exists
if [ "$HAS_PRIVATE_CONFIG" = true ] && [ -d "$PRIVATE_CONFIG_DIR/dotfiles" ]; then
    echo "⚙ Installing dotfiles from private config..."

    # Parse dotfiles with DEST headers and install them
    for file in "$PRIVATE_CONFIG_DIR/dotfiles"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")

            # Extract destination from file header
            dest=$(grep "^# BOOTSTRAP_DEST:" "$file" | head -1 | sed 's/^# BOOTSTRAP_DEST: //')
            backup=$(grep "^# BOOTSTRAP_BACKUP:" "$file" | head -1 | sed 's/^# BOOTSTRAP_BACKUP: //')

            if [ -n "$dest" ]; then
                # Expand ~ to home directory
                dest="${dest/#\~/$HOME}"

                # Backup existing file if requested
                if [ "$backup" = "true" ] && [ -f "$dest" ]; then
                    echo "  Backing up existing $(basename "$dest") to ${dest}.backup"
                    cp "$dest" "${dest}.backup"
                fi

                # Create directory if needed
                mkdir -p "$(dirname "$dest")"

                # Copy file (removing header lines)
                echo "  Installing $filename → $dest"
                grep -v "^# BOOTSTRAP_" "$file" > "$dest"
            else
                echo "  Skipping $filename (no BOOTSTRAP_DEST header)"
            fi
        fi
    done

    echo "✓ Dotfiles installed from private config"
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
