#!/bin/bash
# 04-private-setup.sh
# Run setup scripts from private config repo (GAM, secrets, etc.)
#
# How it works:
# - Looks for your-private-config/scripts/01-*.sh, 02-*.sh, etc.
# - Runs them in order
# - Scripts have access to: $HOME, $PRIVATE_CONFIG_DIR, and `op` command (1Password CLI)
#
# Example script (01-gam-setup.sh):
#   OP_VAULT="your-vault-name"
#   mkdir -p ~/bin/gam7
#   op read "op://$OP_VAULT/GAM Credentials/oauth2/txt" > ~/bin/gam7/oauth2.txt
#   chmod 600 ~/bin/gam7/oauth2.txt
#
# "Wait, you're committing 1Password item IDs to git?"
# Yes. Item IDs are just pointers. They're useless without:
#   1. Access to my 1Password account (requires master password + 2FA)
#   2. The `op` CLI being authenticated (which requires browser auth)
#
# This is like committing "my password is in the safe, top drawer, blue folder"
# without giving you the safe combination. Cool story, still can't get in.
#
# The actual secrets (OAuth tokens, API keys, etc.) are PULLED at setup time
# and never touch git. Not even the private repo.

set -e

echo "Running private setup scripts..."

PRIVATE_CONFIG_DIR="$HOME/.mac-bootstrap-config"
PRIVATE_SCRIPTS_DIR="$PRIVATE_CONFIG_DIR/scripts"

# Check if private config repo exists
if [ "$HAS_PRIVATE_CONFIG" != true ] || [ ! -d "$PRIVATE_CONFIG_DIR" ]; then
    echo "⚠ No private config repository found"
    echo "  Skipping private setup scripts"
    exit 0
fi

# Check if private scripts directory exists
if [ ! -d "$PRIVATE_SCRIPTS_DIR" ]; then
    echo "⚠ No scripts directory in private config repo"
    echo "  Expected at: $PRIVATE_SCRIPTS_DIR"
    echo "  Skipping private setup scripts"
    exit 0
fi

# Run numbered scripts in order (e.g., 01-gam-setup.sh, 02-aws-setup.sh, etc.)
script_count=0
for script in "$PRIVATE_SCRIPTS_DIR"/[0-9][0-9]-*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        echo "⚙ Running private script: $script_name"
        bash "$script"
        echo "✓ $script_name completed"
        script_count=$((script_count + 1))
    fi
done

if [ $script_count -eq 0 ]; then
    echo "⚠ No numbered scripts found in $PRIVATE_SCRIPTS_DIR"
else
    echo ""
    echo "✓ Ran $script_count private setup script(s)"
fi

echo ""
echo "Private setup complete!"
