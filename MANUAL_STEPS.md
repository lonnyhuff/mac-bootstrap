# Manual Steps Guide

This script automates most setup, but some steps require manual intervention.

## How This Works

1. Script installs Homebrew (triggers Xcode CLI tools installation automatically)
2. Script installs 1Password app and CLI via Homebrew
3. **Script pauses** - you configure 1Password manually
4. Script verifies 1Password CLI works
5. Script continues with rest of setup (pulls secrets, installs packages, configures system)

## What You'll Need to Do When Script Pauses

The script will pause after installing 1Password and display instructions:

**Step 1: Launch 1Password and sign in**
- Open 1Password app (installed via Homebrew)
- Sign in to your account
- Complete initial sync

**Step 2: Enable Developer Settings**
- Open 1Password → Settings → Developer
- Enable "Use the SSH agent"
- Enable "Connect with 1Password CLI"

**Step 3: Authenticate 1Password CLI**
The script will run `op signin` for you and wait for you to complete the authentication flow in your browser.

**Step 4: Verify**
Script will check that `op vault list` works. If it does, setup continues automatically.

## Secrets Required in 1Password

The script will look for these items. Set them up before running bootstrap, or the script will prompt you:

**GAM OAuth Credentials** (already configured for this user)
- Item name: "GAM Credentials"
- Vault: "Clawdbot"
- Item ID: muscfbrgk4qzwophgskjiyjolm
- Note: For others using this script, create a Document or Secure Note containing your GAM oauth2.txt contents

**SSH Keys**
- Script expects SSH keys to be stored in 1Password's SSH agent
- Add your keys to 1Password, they'll be auto-injected into SSH sessions

**AWS Credentials** (optional)
- If you use AWS, store access keys in 1Password
- Script can reference them in ~/.aws/credentials setup

## Private Config Repo (Optional)

If you have a private `mac-bootstrap-config` repo with dotfiles and secrets:
- Script will prompt for the repo URL during setup
- See docs/PRIVATE_CONFIG.md for structure details
- Script will clone it and install configs according to file headers

## Running Bootstrap

```bash
git clone https://github.com/YOUR_USERNAME/mac-bootstrap.git
cd mac-bootstrap
./bootstrap.sh
```

The script is idempotent - safe to run multiple times if something fails.
