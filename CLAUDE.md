# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a nix-darwin configuration repository for macOS. It uses flake-parts with nix-darwin and home-manager to manage system and user configuration declaratively.

## Commands

```bash
# Apply configuration changes
darwin-rebuild switch --flake .#Danielos-MacBook-Pro

# Format nix files (uses alejandra)
nix fmt

# Enter development shell (provides nixd, just, alejandra)
nix develop

# Build without switching (useful for testing)
nix build .#darwinConfigurations.Danielos-MacBook-Pro.system

# Build custom packages
nix build .#repo-cloner
```

## Architecture

**Flake Structure:**
- `flake.nix` - Entry point defining darwin configurations and home-manager integration
- `hosts/macbook/` - Host-specific configuration (system packages, preferences)
- `modules/common/` - Cross-platform modules (fonts, users, nix-core)
- `modules/darwin/` - macOS-specific system modules (apps, system settings, homebrew)
- `home/` - Home-manager configurations
- `pkgs/` - Custom packages
- `dotfiles/` - Non-nix config files (hammerspoon, sketchybar, etc.)

**Bootstrap a new machine:**
```bash
nix run github:danielo515/nix-darwin -- ~/my-config
```
This clones the repo and optionally runs darwin-rebuild to set up the system.

**Home-Manager Organization:**
- `home/default.nix` - Entry point, imports platform-specific configs based on `isDarwin`
- `home/darwin/` - macOS-specific user config (ghostty, hammerspoon, aerospace)
- `home/nixos/` - Linux-specific user config
- `home/programs/` - Cross-platform programs (neovim, tmux, starship)
- `home/shell/` - Shell configurations (zsh, bash, zoxide, wezterm)

**Special Args passed through configuration:**
- `username`, `useremail` - User identity
- `isDarwin` - Platform detection for conditional imports
- `hostname`, `system` - Host-specific values
- `flake` - Self reference for accessing custom packages

## Code Style

- Prefer functional and immutable patterns
- Avoid superfluous comments; code should be self-explanatory
