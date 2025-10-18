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
│   └── desktop/                # NixOS Desktop
├── home/                       # Home Manager configurations
│   ├── profiles/               # User profiles (minimal, development, desktop, darwin, nixos)
│   ├── programs/               # Program configurations (editors, terminals, shells, etc.)
│   └── packages/               # Package collections (build-tools, languages, web-dev, etc.)
├── modules/                    # System modules
│   ├── system/                 # System configurations (darwin, nixos)
│   ├── services/               # Service configurations
│   ├── optional-features/      # Optional features
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
- Git for cloning the repository

### Complete Setup Guide

1. **Install Nix (Determinate Systems) upstream channel**

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. **Clone This Repository**

```bash
# Clone the repository
git clone https://github.com/yourusername/nix-config.git ~/nix-config
cd ~/nix-config
```

3. **Configure Your System**
   Before installing nix-darwin, customize the configuration files to match your system:

   a. **Update System Configuration in `flake.nix`:**

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

   b. **Configure Host Settings in `hosts/nix-darwin/configuration.nix`**

   c. **Set Up User Environment in `hosts/nix-darwin/home.nix`**

4. **Install nix-darwin**

```bash
# Install nix-darwin with your customized configuration
nix run nixpkgs#nix-darwin -- switch --flake .
```

5. **Set Up Authentication and Secrets**

   a. **Generate SSH Key for GitHub**

   ```bash
   # Generate SSH key
   ssh-keygen -t ed25519 -C "your-email@example.com"

   # Add SSH key to GitHub
   cat ~/.ssh/id_ed25519.pub
   # Copy the output and add it to GitHub Settings > SSH and GPG keys > New SSH key
   ```

   b. **Generate GPG Key for Commit Signing**

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

   c. **Set Up SOPS for Secrets Management**

   ```bash
   # Generate age key for SOPS
   age-keygen > ~/.config/sops/age/keys.txt

   # Create age key directories
   mkdir -p ~/.config/sops/age
   mkdir -p ~/Library/Application\ Support/sops/age

   # Copy age key to both locations
   cp ~/.config/sops/age/keys.txt ~/Library/Application\ Support/sops/age/keys.txt

   # Get the public key from the generated file
   grep "KEY"  ~/.config/sops/age/keys.txt
   ```

   d. **Update SOPS Configuration**

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

   e. **Create Encrypted Secrets File**

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
```

#### **Quick Navigation**
```bash
dots         # cd ~/nix-config
files        # Open yazi file manager
vi           # nvim (Neovim)
```

## Documentation

Detailed documentation for specific components:

### Core Configuration
- **[Home Manager Profiles](home/profiles/README.md)** - User profile system (minimal, development, desktop, darwin, nixos)
- **[Custom Packages](pkgs/README.md)** - Custom Nix packages and development tools

### Programs
- **[Zsh Configuration](home/programs/shells/zsh/README.md)** - Comprehensive Zsh setup with FZF keybindings and aliases
- **[Development Tools](home/programs/development/README.md)** - Direnv and Git configuration
- **[Kubernetes Tools](home/programs/kubernetes/README.md)** - Kubernetes toolsets and utilities
- **[Neovim Configuration](home/programs/editors/neovim/Docs/README.md)** - Enhanced Neovim setup with v12 features
- **[Neovim Snippets](home/programs/editors/neovim/lua/snippets/README.md)** - Custom code snippets