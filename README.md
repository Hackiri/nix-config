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
```

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
   # macOS (requires sudo for system-level changes)
   sudo nix run nix-darwin -- switch --flake .#mbp
   
   # NixOS
   sudo nixos-rebuild switch --flake .#desktop
   ```

## Usage

### System Updates

```bash
# macOS system-level changes (nix-darwin + home-manager)
nixswitch  # Custom alias: sudo darwin-rebuild switch --flake ~/nix-config#mbp
# OR manually:
sudo darwin-rebuild switch --flake .#mbp

# Alternative using nix run (if darwin-rebuild not available)
sudo nix run nix-darwin -- switch --flake .#mbp

# NixOS system-level changes
sudo nixos-rebuild switch --flake .#desktop
```

**Note:** This configuration integrates home-manager through nix-darwin/NixOS modules, so there's no separate home-manager-only command. User configurations are applied together with system configurations.

### Available Commands

This configuration provides many convenient aliases for system management:

#### **System Management**
```bash
# Build and switch
nixswitch    # Build and activate configuration
nixbuild     # Build only (no activation)
nixboot      # Build but activate on next boot
nixcheck     # Check configuration validity
nixdry       # Dry run (test build without changes)

# System maintenance
nixlist      # List all generations
nixrollback  # Rollback to previous generation
nixclean     # Clean old generations and garbage collect

# Debugging
nixtrace     # Show trace for debugging
nixverbose   # Verbose output
nixedit      # Open configuration in $EDITOR
```

#### **Nix Utilities**
```bash
nxsearch     # Search packages (nix search nixpkgs)
nxrepl       # Interactive nix REPL
nxdev        # Enter development shell

# Update workflow
nix flake update  # Update flake inputs
nixswitch         # Apply updates
```

#### **Quick Navigation**
```bash
dots         # cd ~/nix-config
files        # Open yazi file manager
vi           # nvim (Neovim)
```