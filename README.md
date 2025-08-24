# Nix Configuration

A Nix configuration for macOS using nix-darwin and Home Manager, providing a declarative and reproducible system environment.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Installation and Setup Guide](#installation-and-setup-guide)
- [Maintenance](#maintenance)

## Overview
This repository contains a complete Nix configuration that manages both system-level settings and user environments on macOS. It combines nix-darwin for system configuration with Home Manager for user environment management, creating a fully reproducible and declarative setup.

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
  - Doom Emacs setup with custom configuration and plugins
- **DevShell Environment**
  - Flexible development shell with language-specific environments
  - Selectable language support (Python, Rust, Go, Node.js)
  - Consistent tooling across projects
- **Kubernetes Environment**
  - Kubernetes toolset (kubectl, helm, k9s)
  - Infrastructure as Code tools (terraform)
  - Network management (cilium-cli)
  - Convenient shell aliases and completions
- **Terminal Environment**
  - Starship prompt customization
  - Zsh with extensive customization (fzf, git)
  - Tmux integration
  - Modern CLI tools (bat, eza, ripgrep, fd, jq)
  - Directory jumping with zoxide
- **Development Tools**
  - Code Quality
    - Pre-commit hooks
    - Sops for encrypted secrets
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
    ├── common-pkg.nix     # Common packages for all systems
    ├── common.nix         # Shared home configuration
    ├── darwin.nix         # macOS-specific home configuration
    ├── nixos.nix          # NixOS configuration
    ├── aerospace/         # Aerospace configuration
    ├── btop/              # System monitor configuration
    ├── direnv/            # Directory environment manager
    ├── emacs/             # Doom Emacs configuration
    ├── git/               # Git configuration
    ├── kube/              # Kubernetes configuration
    ├── neovide/           # Neovide GUI for Neovim
    ├── neovim/            # Neovim configuration
    ├── python/            # Python configuration
    ├── sops-nix/          # Sops configuration
    ├── starship/          # Shell prompt configuration
    ├── terminal/          # Terminal configurations
    ├── tmux/              # Tmux configuration
    ├── yazi/              # File manager configuration
├── hosts/                 # Host-specific configurations
    └── nix-darwin/        # macOS configuration
        ├── configuration.nix  # System configuration
        └── home.nix       # User environment
├── modules/               # Configuration modules
    ├── common/            # Shared modules
    │   └── darwin-common.nix  # Common Darwin configuration
    ├── darwin/            # macOS-specific modules
    │   └── homebrew.nix   # Homebrew configuration
    │   └── font.nix       # Font configuration
    └── nixos/             # NixOS modules (placeholder)
├── overlay/               # Overlay    
├── pkgs/                  # Custom package definitions
    ├── devshell/          # Devshell definitions
    ├── default.nix        # Package exports
    ├── kubernetes-tools.nix # Kubernetes tools package
    └── dev-tools.nix      # Development tools package
├── secrets/               # Secrets
├── .pre-commit-config.yaml # Pre-commit configuration
├── shell.nix              # Development shell
├── stylua.nix             # Stylua configuration
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
1. Install Nix (Determinate Systems) upstream channel

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. Clone This Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/nix-config.git ~/nix-config
cd ~/nix-config
```

3. Configure Your System
   Before installing nix-darwin, customize the configuration files to match your system:

a. Update System Configuration in `flake.nix`:

### System Configuration Function
The configuration uses a flexible `mkDarwin` function that parameterizes system creation:

```nix
# Function to create a Darwin system configuration
mkDarwin = {
  name,
  system ? "x86_64-darwin",
  username ? "wm",
}:
```

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

This allows for:
- Consistent username usage throughout the configuration
- Easy switching between different machines and users
- Passing the username variable to all modules via `specialArgs`
- Configuring home-manager with the same username

b. Configure Host Settings in `hosts/nix-darwin/configuration.nix`

c. Set Up User Environment in `hosts/nix-darwin/home.nix`

4. Install nix-darwin

```bash
# Install nix-darwin with your customized configuration
nix run nixpkgs#nix-darwin -- switch --flake .
```

5. Set Up Authentication and Secrets

a. Generate SSH Key for GitHub

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add SSH key to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy the output and add it to GitHub Settings > SSH and GPG keys > New SSH key
```

b. Generate GPG Key for Commit Signing

```bash
# Generate GPG key
gpg --full-generate-key
# Choose: (9) ECC (sign and encrypt)
# Choose: (1) Curve 25519
# Enter your name and email when prompted

# Export public key for GitHub
gpg --armor --export YOUR_KEY_ID
# Copy the output and add it to GitHub Settings > SSH and GPG keys > New GPG key
```

c. Set Up SOPS for Secrets Management

```bash
# Generate age key for SOPS
age-keygen > ~/.config/sops/age/keys.txt

# Create age key directories
mkdir -p ~/.config/sops/age
mkdir -p ~/Library/Application\ Support/sops/age

# Copy age key to both locations
cp ~/.config/sops/age/keys.txt ~/Library/Application\ Support/sops/age/keys.txt

# Get the public key from the generated file
grep "public key:" ~/.config/sops/age/keys.txt
```

d. Update SOPS Configuration

Update `.sops.yaml` with your new age public key:

```yaml
keys:
  - &main-key age1your_public_key_here
creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *main-key
```

e. Create Encrypted Secrets File

```bash
# Create new secrets file with your information
cat > secrets/secrets.yaml << EOF
git-userName: your-username
git-userEmail: your-email@example.com
git-signingKey: YOUR_GPG_KEY_ID
EOF

# Encrypt the secrets file
sops -e -i secrets/secrets.yaml
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
nixswitch

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