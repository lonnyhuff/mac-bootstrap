# mac-bootstrap

Automated macOS setup for systems engineers who move between machines frequently.

## Why This Exists

I'm a systems engineer. I move around computers a lot—testing, breaking things, rebuilding. I keep a minimal setup and admire people who can just hop onto any machine and live in vim and a browser, but I'm particular about my workflow. More importantly, I think about security when moving between systems.

Password managers like 1Password make it significantly easier to move around without leaving credentials on disk. If a laptop gets stolen while traveling, it's harder to extract SSH keys, PEM files, or OAuth tokens when they're not sitting in plaintext in `~/.ssh` or `~/bin`. This setup tries to find a balance between portability, security (not leaving keys behind), personal preferences, and speed—so I can spend less time configuring systems and more time actually working.

## Design Philosophy

**Security-first secrets management**: All sensitive credentials live in 1Password. The bootstrap script pulls them at setup time with proper permissions. No secrets in git, even in private repos.

**Public/private split**: This public repo contains generic bootstrap logic. Your personal configs, dotfiles, and secret references live in a separate private repo that gets cloned during setup.

**Minimal and opinionated**: Empty hidden Dock, list view Finder, TouchID for sudo, fast keyboard repeat. No animations, no bloat. Just a clean dev environment.

**Idempotent and testable**: Safe to run multiple times. Script checks prerequisites before each step.

**Homebrew as foundation**: Everything installable goes through Homebrew. No manual downloads, no App Store dependencies (except 1Password initial setup, which Homebrew handles anyway).

## What This Does

1. Installs Homebrew and Xcode CLI tools
2. Installs packages and applications from `Brewfile`:
   - CLI tools: git, gh, node, python, awscli, gcloud-cli, 1password-cli
   - Apps: 1Password, Claude Code, Cursor, Ghostty, Raycast, Slack, Signal, etc.
3. Configures 1Password (pauses for manual setup, then verifies CLI access)
4. Optionally clones your private config repository
5. Runs setup scripts:
   - Verifies prerequisites
   - Applies system tweaks (TouchID sudo, Finder/Dock preferences, keyboard settings)
   - Installs dotfiles from private repo (or minimal defaults)
   - Runs private setup scripts (GAM, AWS creds, etc.)

**System tweaks applied:**
- TouchID authentication for sudo
- Empty, auto-hidden Dock with no animations
- Finder: list view by default, show hidden files, full POSIX paths
- Fast keyboard repeat, disabled autocorrect/smart quotes
- Screenshots saved to Downloads in PNG format
- Tap-to-click and three-finger drag enabled
- Various animation delays removed

## Quick Start

```bash
git clone https://github.com/lonnyhuff/mac-bootstrap.git
cd mac-bootstrap
./bootstrap.sh
```

The script will guide you through the process. See [MANUAL_STEPS.md](MANUAL_STEPS.md) for what to expect.

## Documentation

- **[MANUAL_STEPS.md](MANUAL_STEPS.md)** - What happens during bootstrap and when you'll need to interact
- **[QUICK_START.md](QUICK_START.md)** - Reference guide with troubleshooting
- **[docs/PRIVATE_CONFIG.md](docs/PRIVATE_CONFIG.md)** - How to structure your private config repo
- **[docs/examples/](docs/examples/)** - Example scripts for GAM setup, etc.

## Private Config Repository

This bootstrap expects an optional private repo (`mac-bootstrap-config`) containing:

```
mac-bootstrap-config/
├── dotfiles/          # .zshrc, .gitconfig, etc. with BOOTSTRAP_DEST headers
├── scripts/           # Private setup scripts (GAM, secrets, etc.)
└── claude-projects/   # Project-specific Claude.md templates
```

The bootstrap script will prompt for your private repo URL and clone it to `~/.mac-bootstrap-config`. See [docs/PRIVATE_CONFIG.md](docs/PRIVATE_CONFIG.md) for detailed structure and examples.

## Customization

**Fork this repo** and modify to your needs:

- **`Brewfile`** - Add/remove packages and applications
- **`scripts/02-system-tweaks.sh`** - Adjust macOS preferences
- **`scripts/`** - Add your own numbered scripts (e.g., `05-custom-setup.sh`)

The bootstrap script runs all numbered scripts in `scripts/` sequentially.

## GAM + 1Password Integration

This bootstrap includes an approach for managing GAM (Google Apps Manager) credentials via 1Password. Instead of leaving OAuth tokens on disk, they're pulled from 1Password during setup and installed with proper permissions.

See [docs/examples/01-gam-setup.sh.example](docs/examples/01-gam-setup.sh.example) for a template to add to your private config repo.

A more sophisticated approach (a wrapper tool that pulls tokens on-demand rather than at setup) is planned as a separate project.

## Notes

- This is built for my workflow but designed to be forkable
- Some manual configuration still required (Raycast shortcuts, app sign-ins, etc.)
- The bootstrap is idempotent—safe to run multiple times if something fails
- Optimized for Apple Silicon Macs but should work on Intel with minor PATH adjustments
