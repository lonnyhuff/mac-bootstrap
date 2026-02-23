# Private Config Repository Structure

This document describes how to structure your private `mac-bootstrap-config` repository.

## Overview

The private config repo stores:
- Personal dotfiles with sensitive information
- Setup scripts for secrets (GAM, AWS, etc.)
- Claude.md templates for your projects
- Any other personal configuration

## Repository Structure

```
mac-bootstrap-config/  (private GitHub repo)
├── README.md
├── dotfiles/
│   ├── .zshrc
│   ├── .gitconfig
│   ├── .gitignore_global
│   └── ssh-config
├── scripts/
│   ├── 01-gam-setup.sh
│   ├── 02-aws-credentials.sh
│   └── 03-other-secrets.sh
└── claude-projects/
    ├── README.md
    └── project-templates/
        └── alfred.md
```

## Dotfile Format

Dotfiles should include headers that tell the bootstrap script where to install them:

```bash
# BOOTSTRAP_DEST: ~/.zshrc
# BOOTSTRAP_BACKUP: true
#
# Your actual file content starts here...

export PATH="$HOME/bin:$PATH"
# ... rest of your .zshrc
```

### Supported Headers

- `BOOTSTRAP_DEST: <path>` - Where to install the file (required)
- `BOOTSTRAP_BACKUP: true|false` - Whether to backup existing file (optional, default: false)

The bootstrap script will:
1. Read the headers
2. Backup the existing file if requested
3. Copy your file to the destination (excluding header lines)

## Private Setup Scripts

Scripts in `scripts/` are run by `04-private-setup.sh` in numerical order.

These scripts have access to:
- `$HOME` - Your home directory
- `$PRIVATE_CONFIG_DIR` - Path to the private config repo (`~/.mac-bootstrap-config`)
- `op` command - 1Password CLI (already authenticated)

### Example: GAM Setup Script

Create `scripts/01-gam-setup.sh`:

```bash
#!/bin/bash
# 01-gam-setup.sh
# Set up GAM with credentials from 1Password

set -e

echo "Setting up GAM..."

# Your specific 1Password details
OP_ITEM_ID="your-item-id-here"
OP_VAULT="your-vault-name"

# GAM directory
GAM_DIR="$HOME/bin/gam7"
GAM_OAUTH_FILE="$GAM_DIR/oauth2.txt"

# Create directory
mkdir -p "$GAM_DIR"

# Pull credentials from 1Password
op document get "$OP_ITEM_ID" --vault "$OP_VAULT" > "$GAM_OAUTH_FILE"
chmod 600 "$GAM_OAUTH_FILE"

# Add alias to .zshrc if not present
if ! grep -q "alias gam=" "$HOME/.zshrc"; then
    echo "" >> "$HOME/.zshrc"
    echo 'alias gam="$HOME/bin/gam7/gam"' >> "$HOME/.zshrc"
fi

echo "✓ GAM setup complete"
```

### Example: AWS Credentials Script

Create `scripts/02-aws-credentials.sh`:

```bash
#!/bin/bash
# 02-aws-credentials.sh
# Set up AWS credentials from 1Password

set -e

echo "Setting up AWS credentials..."

# Pull from 1Password and write to ~/.aws/credentials
mkdir -p "$HOME/.aws"

# Example: pulling from a specific 1Password item
op item get "AWS Access Keys" --format json | \
  jq -r '.fields[] | select(.label=="credentials") | .value' \
  > "$HOME/.aws/credentials"

chmod 600 "$HOME/.aws/credentials"

echo "✓ AWS credentials installed"
```

## Claude Project Templates

Store Claude.md templates for your projects in `claude-projects/`.

The bootstrap script doesn't automatically deploy these - you'll copy them manually to projects as needed, or use a separate script to deploy them.

### Example Template

`claude-projects/project-templates/node-api.md`:

```markdown
# Project: [Project Name]

## Overview
[Quick description of what this project does]

## Setup
\`\`\`bash
npm install
cp .env.example .env
# Edit .env with your credentials
\`\`\`

## Development
\`\`\`bash
npm run dev
\`\`\`

## Testing
\`\`\`bash
npm test
\`\`\`

## Common Tasks
- Deploy: `npm run deploy`
- Lint: `npm run lint`
- Build: `npm run build`

## Architecture Notes
[Key architectural decisions, patterns used, etc.]
```

## Creating Your Private Config Repo

1. Create a new private GitHub repository:
   ```bash
   gh repo create mac-bootstrap-config --private
   ```

2. Clone it locally (temporarily):
   ```bash
   git clone git@github.com:YOUR_USERNAME/mac-bootstrap-config.git
   cd mac-bootstrap-config
   ```

3. Create the structure:
   ```bash
   mkdir -p dotfiles scripts claude-projects/project-templates
   ```

4. Add your dotfiles with headers:
   ```bash
   # Copy your current dotfiles and add headers
   cp ~/.zshrc dotfiles/.zshrc
   # Edit and add BOOTSTRAP_DEST header at the top
   ```

5. Create setup scripts for secrets:
   ```bash
   # Create GAM setup script
   touch scripts/01-gam-setup.sh
   chmod +x scripts/01-gam-setup.sh
   # Edit and add your GAM setup logic
   ```

6. Commit and push:
   ```bash
   git add .
   git commit -m "Initial private config"
   git push origin main
   ```

7. Clean up local clone (bootstrap will clone it to `~/.mac-bootstrap-config`):
   ```bash
   cd ..
   rm -rf mac-bootstrap-config
   ```

## Security Notes

- ✅ **DO** store 1Password item IDs and vault names in private repo
- ✅ **DO** use `op` CLI to pull secrets at setup time
- ❌ **DON'T** commit actual secrets/credentials to git (even private repo)
- ❌ **DON'T** commit OAuth tokens, API keys, or passwords

Always use 1Password as the source of truth for secrets, and pull them dynamically during bootstrap.
