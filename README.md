# Nix Configuration

A comprehensive Nix configuration for macOS using nix-darwin and Home Manager, providing a declarative and reproducible system environment.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Installation and Setup Guide](#installation-and-setup-guide)
- [Maintenance](#maintenance)

## Overview
This repository contains a complete Nix configuration that manages both system-level settings and user environments on macOS. It combines nix-darwin for system configuration with Home Manager for user environment management, creating a fully reproducible and declarative setup.

## Migration Note
This configuration was migrated from `/private/etc/nix-darwin` to `~/nix-config` on June 22, 2025. All paths have been updated to reference the new location.

## Features

### Core Components
- **Declarative macOS Configuration**
  - System-wide settings management via nix-darwin
  - Host & user-specific configuration
  - Homebrew integration via `nix-homebrew`
  - Package management via `nixpkgs` and `nix-darwin`
  - Touch ID for sudo authentication
- **User Environment Management**
  - User-specific home directory configuration
  - XDG base directory support
  - Dotfiles management
  - Application settings synchronization
- **Package Management**
  - Nix Flakes for reproducible builds
  - Weekly garbage collection & storage optimization
  - Content-addressed derivations
  - Binary cache configuration (nixos.org and nix-community)

### Development Environment
- **Neovim Configuration**
  - LSP support for multiple languages
  - Code completion enhancements
  - Syntax highlighting and colorization
  - Git integration
- **Emacs Configuration**
  - Custom Emacs setup
- **Terminal Environment**
  - Starship prompt customization
  - Zsh with extensive customization
  - Tmux integration
  - Modern CLI tools (bat, eza, ripgrep, fd, jq)
  - Directory jumping with zoxide
- **Development Tools**
  - Code Quality
    - Pre-commit hooks
    - Alejandra for Nix formatting
    - Deadnix for dead code detection
    - Statix for Nix static analysis
    - Stylua for Lua formatting
  - Version Control
    - Git with GPG signing
    - Lazygit for enhanced Git CLI

### System Features
- **Security**
  - Touch ID for sudo authentication
  - Secure GPG configuration
  - Keychain integration
- **Applications**
  - Managed via Homebrew (browsers, development tools, utilities)
  - Mac App Store integration via mas
- **Docker Compatibility**
  - Podman configuration with Docker compatibility layer

## System Architecture

### Directory Structure
```bash
nix-config/
├── flake.nix              # Main flake configuration
├── home/                  # Home Manager configurations
│   ├── common.nix         # Shared home configuration
│   ├── darwin.nix         # macOS-specific home configuration
│   ├── nixos.nix          # NixOS configuration
│   ├── secrets.nix        # Git secrets
│   ├── btop/              # System monitor configuration
│   ├── direnv/            # Directory environment manager
│   ├── emacs/             # Emacs configuration
│   ├── neovide/           # Neovide GUI for Neovim
│   ├── neovim/            # Neovim configuration
│   ├── starship/          # Shell prompt configuration
│   ├── terminal/          # Terminal configurations
│   ├── tmux/              # Tmux configuration
│   └── yazi/              # File manager configuration
├── hosts/                 # Host-specific configurations
│   └── nix-darwin/        # macOS configuration
│       ├── configuration.nix  # System configuration
│       └── home.nix       # User environment
├── modules/               # Configuration modules
│   ├── common/            # Shared modules
│   │   └── darwin-common.nix  # Common Darwin configuration
│   ├── darwin/            # macOS-specific modules
│   │   └── homebrew.nix   # Homebrew configuration
│   └── nixos/             # NixOS modules (placeholder)
└── shell.nix             # Development shell
```

### Key Components
- `home-manager`: User-specific configuration with various tools and applications
- `nix-darwin`: System-wide settings for macOS
- `nixpkgs`: Package collection for nix-darwin
- `flake.nix`: Nix flake for system configuration and user environment
- `configuration.nix`: Host-specific configuration
- `home.nix`: User configuration
- `homebrew.nix`: Homebrew package management for macOS applications

### Separation of Concerns
This configuration follows a clear separation of concerns between system and user configurations:

#### System-Level (nix-darwin)
- macOS system defaults and preferences
- Security settings and system services (Touch ID for sudo)
- Homebrew package management
- Core system utilities (mkalias, pam-reattach)

#### User-Level (home-manager)
- User packages and applications
- Shell configuration and aliases
- Development tools (Neovim, Emacs, Git)
- Terminal environment (Zsh, Tmux, Starship)

## Installation and Setup Guide

### Prerequisites
- macOS 10.15 or later
- Administrative access
- Internet connection
- Basic knowledge of Nix/Nix Flakes

### Installation Steps
1. Install Nix

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

2. Enable Nix Flakes

```bash
# Enable flakes and nix-command in your Nix configuration
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

3. Clone This Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/nix-config.git ~/nix-config
cd ~/nix-config
```

4. Configure Your System
   Before installing nix-darwin, customize the configuration files to match your system:

a. Update System Configuration in `flake.nix`:

```nix
# Set correct system architecture
system = "x86_64-darwin"; # or "aarch64-darwin" for Apple Silicon

# Update hostname and user configuration
darwinConfigurations = {
  "your-hostname" = mkDarwin {
    name = "nix-darwin";
    username = "your-username";
  };
};
```

b. Configure Host Settings in `hosts/nix-darwin/configuration.nix`

c. Set Up User Environment in `hosts/nix-darwin/home.nix`

5. Install nix-darwin

```bash
# Install nix-darwin with your customized configuration
nix run nixpkgs#nix-darwin -- switch --flake .
```

## Maintenance

### System Updates
1. Update Flake Inputs

```bash
nix flake update  # Update all inputs
nix flake lock --update-input nixpkgs  # Update specific input
```

2. Rebuild System

```bash
# Using the convenience alias
updatenix

# Or directly
sudo darwin-rebuild switch --flake ~/nix-config#nix-darwin
```

### System Cleanup
1. Garbage Collection

```bash
# Manual cleanup
nix-collect-garbage -d

# Optimize store
nix store optimize
```

2. Cache Management

```bash
# Clear old generations
sudo nix-collect-garbage -d

# Remove unused packages
nix store gc
```

### Troubleshooting
1. Common Issues

- Check system logs: `darwin-rebuild switch --show-trace`
- Verify flake inputs: `nix flake metadata`
- Test configuration: `darwin-rebuild check`

2. Recovery Steps

- Rollback to previous generation: `darwin-rebuild switch --rollback`
- Boot to previous generation: `darwin-rebuild boot --rollback`
- Clean build: `darwin-rebuild switch --flake . --recreate-lock-file`