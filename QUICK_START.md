# Quick Start Guide

## First Time Setup

### 1. Prerequisites
- Clean macOS install (or existing system)
- Signed in with Apple ID / iCloud

### 2. Clone This Repo
```bash
git clone https://github.com/YOUR_USERNAME/mac-bootstrap.git
cd mac-bootstrap
```

### 3. Run Bootstrap
```bash
./bootstrap.sh
```

The script will:
1. Install Homebrew + Xcode CLI tools
2. Install all packages from Brewfile
3. Pause for you to configure 1Password
4. Continue with system tweaks and setup

### 4. Follow Prompts
- Configure 1Password when prompted
- Optionally provide your private config repo URL
- Wait for setup to complete

### 5. Restart Terminal
```bash
# Close and reopen your terminal, or:
source ~/.zshrc
```

## What Gets Installed

### CLI Tools
- git, gh (GitHub CLI)
- node, python
- awscli, gcloud-cli
- nmap
- 1password-cli

### Applications
- 1Password (password manager)
- Claude Code (AI coding assistant)
- Cursor (code editor)
- Ghostty (terminal)
- Raycast (launcher)
- Slack, Signal, Spotify
- Notion, mitmproxy
- qflipper (hardware tool)

### System Tweaks
- TouchID for sudo
- Faster keyboard repeat
- Hidden Dock (empty)
- Finder list view by default
- Screenshots to Downloads
- Disabled animations
- And more...

## Private Config Repo (Optional but Recommended)

Create a private repo for your dotfiles and secrets:

1. See [docs/PRIVATE_CONFIG.md](docs/PRIVATE_CONFIG.md)
2. Create `mac-bootstrap-config` private repo
3. Add your dotfiles, setup scripts, etc.
4. Bootstrap will clone and use it automatically

## Customization

### Modify Brewfile
Edit `Brewfile` to add/remove packages:
```ruby
brew "your-package"
cask "your-app"
```

### Add Setup Scripts
Add numbered scripts to `scripts/`:
- `scripts/05-your-setup.sh`

### Adjust System Tweaks
Edit `scripts/02-system-tweaks.sh` for preferences

## Troubleshooting

### 1Password CLI Not Working
```bash
op signin
op vault list
```

### Homebrew Issues
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Re-run Bootstrap
The script is idempotent - safe to run multiple times:
```bash
./bootstrap.sh
```

## Next Steps After Setup

1. Configure installed applications:
   - Raycast: Set up shortcuts
   - Ghostty: Configure theme
   - Slack: Sign in to workspaces

2. Clone your work repositories

3. Set up project-specific tools

4. Customize shell further (aliases, functions, etc.)

## Maintenance

### Update All Packages
```bash
brew update && brew upgrade
```

### Re-sync Dotfiles
```bash
cd ~/.mac-bootstrap-config
git pull
cd ~/mac-bootstrap
./bootstrap.sh  # Will skip already-done steps
```

### Update Private Config
```bash
cd ~/.mac-bootstrap-config
git add .
git commit -m "Update configs"
git push
```
