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

   **Edit `flake.nix` (lines 164-170)** - This is the ONLY required edit to start:

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

4. **Choose Your Profile Setup**

   **Option A: Skip Secrets (Recommended for first-time users)**
   
   Comment out the secrets & git profile in `home/profiles/development.nix`:
   ```nix
   # ../base/git.nix
   # ../base/secrets.nix
   ```
   
   Configure Git manually after installation:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your-email@example.com"
   git config --global user.signingkey "YOUR_GPG_KEY_ID"
   ```

5. **Install nix-darwin**

```bash
# Install nix-darwin with your customized configuration
nix run nixpkgs#nix-darwin -- switch --flake .
```

6. **Set Up Authentication and Secrets**

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

   c. **Set Up SOPS for Secrets Management (Optional - Only if using secrets.nix profile)**

   **What you can store in secrets:**
   - Git credentials (username, email, GPG signing key)
   - API tokens and keys (GitHub, OpenAI, AWS, etc.)
   - SSH private keys
   - Database passwords
   - Environment-specific credentials
   - Any sensitive configuration values

   **Optional Setup steps:**

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

   d. **Update SOPS Configuration (Optional)**

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

   e. **Create Encrypted Secrets File (Optional)**

   ```bash
   # Example: Create secrets file with your information
   cat > secrets/secrets.yaml << EOF
   # Git configuration
   git-userName: your-username
   git-userEmail: your-email@example.com
   git-signingKey: YOUR_GPG_KEY_ID
   
   # API tokens (examples)
   github-token: ghp_your_token_here
   openai-api-key: sk-your_key_here
   
   # SSH keys
   ssh-private-key: |
     -----BEGIN OPENSSH PRIVATE KEY-----
     your_key_content_here
     -----END OPENSSH PRIVATE KEY-----
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