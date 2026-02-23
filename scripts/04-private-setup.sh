#!/bin/bash
# 04-private-setup.sh
# Run setup scripts from private config repo (GAM, secrets, etc.)

set -e

echo "Running private setup scripts..."

PRIVATE_CONFIG_DIR="$HOME/.mac-bootstrap-config"
PRIVATE_SCRIPTS_DIR="$PRIVATE_CONFIG_DIR/scripts"

# Check if private config repo exists
if [ "$HAS_PRIVATE_CONFIG" != true ] || [ ! -d "$PRIVATE_CONFIG_DIR" ]; then
    echo "⚠ No private config repository found"
    echo "  Skipping private setup scripts"
    echo ""
    echo "  If you have sensitive setup steps (GAM, secrets, etc.),"
    echo "  create a private repo with a scripts/ directory"
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
    echo "  Create scripts like: 01-gam-setup.sh, 02-aws-setup.sh, etc."
else
    echo ""
    echo "✓ Ran $script_count private setup script(s)"
fi

echo ""
echo "Private setup complete!"
