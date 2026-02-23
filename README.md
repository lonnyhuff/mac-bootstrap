# The Setup

## Why

I move around computers a lot, testing, breaking things, rebuilding. I keep a minimal setup and admire people who can just hop onto any machine and live in vim and a browser, but I'm particular about my workflow. More importantly, I think about security when moving between systems.

Password managers like 1Password make it significantly easier to move around without leaving credentials on disk. If a laptop gets stolen while traveling, it's harder to extract SSH keys, PEM files, or OAuth tokens when they're not sitting in plaintext in `~/.ssh` or `~/bin`. This setup tries to find a balance between portability, security, personal preferences, and speed.

## What It Does

- Installs Homebrew (triggers Xcode CLI tools)
- Installs everything in `Brewfile` (dev tools, apps)
- Configures 1Password CLI
- Pulls dotfiles and secrets from private repo
- Applies system tweaks (see comments in `scripts/02-system-tweaks.sh`)

## Usage

```bash
git clone https://github.com/lonnyhuff/the-setup.git
cd the-setup
./bootstrap.sh
```

Script pauses for 1Password configuration, then handles the rest.

## Private Repo

The bootstrap script is hardcoded to pull from my private config repo. If you're not me, it'll warn you and let you skip it (using minimal defaults instead).

The private repo just contains:
- Dotfiles with my personal preferences
- References to my 1Password item IDs (not the actual secrets)
- Setup scripts that pull secrets from 1Password at runtime

No actual secrets touch git. The private repo is just automation glue.

If you fork this, create your own private config repo with this structure:

```
your-private-config/
├── dotfiles/     # Files with BOOTSTRAP_DEST: ~/.zshrc headers
└── scripts/      # Numbered scripts (01-gam-setup.sh, etc.)
```

Then update `PRIVATE_REPO_URL` in `bootstrap.sh`. Check the comments in the scripts for details.

