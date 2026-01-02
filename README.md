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
│   ├── profiles/               # User profiles (base, features, platform)
│   ├── programs/               # Program configurations (editors, terminals, shells, etc.)
│   └── packages/               # Package collections (cli-essentials, build-tools, languages, etc.)
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

1. **Install Nix (Determinate Systems)**

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
```

   > **Note:** This installs Determinate Nix, which provides enhanced stability and features. macOS users can alternatively use the [graphical installer](https://install.determinate.systems/determinate-pkg/stable/Universal).

2. **Get the Repository**

   **Option A: Fork (Recommended for maintaining your own version)**
   
   ```bash
   # 1. Fork on GitHub: https://github.com/Hackiri/nix-config (click Fork button)
   # 2. Clone your fork
   git clone https://github.com/yourusername/nix-config.git ~/nix-config
   cd ~/nix-config
   ```

   **Option B: Direct Clone (Quick start)**
   
   ```bash
   # Clone directly and make it your own
   git clone https://github.com/Hackiri/nix-config.git ~/nix-config
   cd ~/nix-config
   # Remove original remote and add your own later
   git remote remove origin
   ```

3. **Configure Your System**

   **Edit `flake.nix` (lines 157-163)** - This is the ONLY required edit to start:

   ```nix
   darwinConfigurations = {
     "mbp" = mkDarwin {           # Change "mbp" to your hostname
       name = "mbp";              # Change to match your host directory name
       system = "x86_64-darwin";  # or "aarch64-darwin" for Apple Silicon
       username = "wm";           # Change to your macOS username
     };
   };
   ```

   **What to change:**
   - **Hostname key** (`"mbp"`): Your computer's hostname (run `hostname` to check)
   - **name**: Must match a directory in `hosts/` (use existing `mbp` or create your own)
   - **system**: `"x86_64-darwin"` (Intel) or `"aarch64-darwin"` (Apple Silicon)
   - **username**: Your macOS username (run `whoami` to check)

   **Optional:** Customize host-specific settings in `hosts/mbp/configuration.nix` and `hosts/mbp/home.nix` later

4. **Install nix-darwin**

   ```bash
   # Install nix-darwin with your customized configuration
   nix run nix-darwin -- switch --flake .
   ```

   After installation, configure Git manually:

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your-email@example.com"
   ```

5. **Set Up SOPS Secrets (Optional)**

   By default, the configuration uses basic Git without sops. To enable sops-encrypted Git credentials:

   a. **Enable sops in your host config** (`hosts/mbp/home.nix`):

   ```nix
   imports = [
     ../../home/profiles/platform/darwin.nix
     ../../home/profiles/base/git.nix      # Add this
     ../../home/profiles/base/secrets.nix  # Add this
   ];
   ```

   b. **Generate age key:**

   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen > ~/.config/sops/age/keys.txt
   ```

   c. **Update `.sops.yaml`** with your public key (from the generated file):

   ```yaml
   keys:
     - &main-key age1your_public_key_here
   creation_rules:
     - path_regex: secrets/.*\.yaml$
       key_groups:
         - age:
             - *main-key
   ```

   d. **Create and encrypt secrets:**

   ```bash
   cat > secrets/secrets.yaml << EOF
   git-userName: your-username
   git-userEmail: your-email@example.com
   git-signingKey: YOUR_GPG_KEY_ID
   EOF

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

### Pre-commit Hooks

This configuration uses [git-hooks.nix](https://github.com/cachix/git-hooks.nix) to automatically run code formatters and linters before commits:

**Enabled hooks:**
- `alejandra` - Nix code formatter
- `deadnix` - Remove unused Nix code
- `statix` - Nix linter
- `stylua` - Lua formatter

**Troubleshooting:**

If you encounter an error like:
```
.git/hooks/pre-commit: No such file or directory
```

This means the pre-commit hooks reference stale Nix store paths. Regenerate them:

```bash
# Regenerate hooks without entering shell
nix develop --command true

# Or enter the devShell which will regenerate hooks automatically
nix develop
```

The hooks are automatically installed when you enter the development shell and will run on every commit.

#### **Quick Navigation**
```bash
dots         # cd ~/nix-config
files        # Open yazi file manager
vi           # nvim (Neovim)
```

## Documentation

Detailed documentation for specific components:

### Core Configuration

- **[Home Manager Profiles](home/profiles/README.md)** - Layered profile system (base → features → platform)
- **[Custom Packages](pkgs/README.md)** - Custom Nix packages, Kubernetes tools, and dev-tools

### Programs

- **[Zsh Configuration](home/programs/shells/zsh/README.md)** - Zsh setup with FZF keybindings, aliases, and Oh My Zsh
- **[Development Tools](home/programs/development/README.md)** - Direnv layouts and Git configuration (basic or sops)
- **[Kubernetes Tools](home/programs/kubernetes/README.md)** - Kubernetes toolsets (minimal, admin, devops, complete)
- **[Neovim Snippets](home/programs/editors/neovim/lua/snippets/README.md)** - LuaSnip snippets for multiple languages
