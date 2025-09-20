# Nix Configuration

A modular Nix configuration for macOS (nix-darwin) and NixOS with Home Manager integration.

## Features

- **Cross-platform**: Works on both macOS and NixOS
- **Modular architecture**: Organized system, service, and user configurations
- **Profile-based**: Development, minimal, and desktop user profiles
- **Homebrew integration**: macOS application management
- **Development tools**: Neovim, Emacs, Git, and language toolchains

## Structure

```
nix-config/
├── flake.nix                   # Main flake configuration
├── flake.lock                  # Flake input locks
├── hosts/                      # Host-specific configurations
│   ├── mbp/                    # MacBook Pro
│   ├── desktop/                # NixOS Desktop
│   └── shared/                 # Shared configurations
├── home/                       # Home Manager configurations
│   ├── profiles/               # User profiles (development, minimal, desktop)
│   ├── programs/               # Program configurations
│   ├── packages/               # Package collections
│   └── shared/                 # Shared home configurations
├── modules/                    # System modules
│   ├── system/                 # System configurations
│   ├── services/               # Service configurations
│   ├── features/               # Optional features
│   └── hardware/               # Hardware-specific modules
├── overlays/                   # Nixpkgs overlays
├── pkgs/                       # Custom packages
├── secrets/                    # Encrypted secrets (sops-nix)
├── shell.nix                   # Development shell
└── stylua.toml                 # Stylua configuration

## Installation

### Prerequisites
- macOS or NixOS
- Nix with flakes enabled

### Setup

1. **Install Nix**
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Clone and configure**
   ```bash
   git clone https://github.com/yourusername/nix-config.git ~/nix-config
   cd ~/nix-config
   # Edit flake.nix to update username and system architecture
   ```

3. **Apply configuration**
   ```bash
   # macOS
   nix run nixpkgs#nix-darwin -- switch --flake .#mbp
   
   # NixOS
   sudo nixos-rebuild switch --flake .#desktop
   ```

## Usage

```bash
# Update system
nixswitch

# Check configuration
nixcheck

# Update flake inputs
nix flake update

```