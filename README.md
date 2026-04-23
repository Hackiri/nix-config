# Nix Configuration

A modular Nix configuration for macOS (nix-darwin) and NixOS with Home Manager integration. Based on **nixpkgs 25.11**.

## Features

- **Cross-platform**: Works on both macOS and NixOS
- **Modular architecture**: Organized system, service, and user configurations
- **Profile-based**: Layered user profiles (minimal → development → platform)
- **Homebrew integration**: macOS application management
- **Development tools**: Neovim, Emacs, Git, and language toolchains

## ⚠️ x86_64-darwin (Intel Mac) Notice

> [!CAUTION]
> Nixpkgs **26.05 is the last release** to support `x86_64-darwin`. Binary builds and source support will continue until 26.05 goes end-of-life (late 2026), but **26.11 will drop x86_64-darwin entirely** — no binary cache, no source builds.

> [!IMPORTANT]
> This configuration uses `nixos-25.11` (stable) exclusively. The `nixpkgs-unstable` channel is **not** used because unstable packages receive less CI coverage on Intel Mac and are more likely to have build failures on `x86_64-darwin`. The `allowDeprecatedx86_64Darwin = true` flag is set in `flake.nix` to suppress the deprecation warning.

> [!TIP]
> 🖥️ Install **NixOS** on the hardware (supported indefinitely on x86_64)
> 🍎 Switch to **MacPorts** (plans to maintain Intel support longer than Homebrew)
> 💻 Migrate to **Apple Silicon** hardware

## Structure

```
nix-config/
├── flake.nix                   # Main flake configuration (flake-parts)
├── flake.lock                  # Flake input locks
├── hosts/                      # Host-specific configurations
│   ├── mbp/                    # MacBook Pro (darwin) x86_64-darwin
│   ├── mbp2/                   # MacBook Pro (darwin) aarch64-darwin
├── home/                       # Home Manager configurations
│   ├── profiles/               # Layered user profiles (base, features, platform)
│   ├── programs/               # Program configurations (editors, shells, terminals, etc.)
│   └── packages/               # Package collections (cli-essentials, build-tools, etc.)
├── modules/                    # System modules
│   ├── system/                 # System configurations (darwin, nixos, shared)
│   └── services/               # Service configurations (homebrew, fonts)
├── lib/                        # Shared library functions
│   ├── builders.nix            # System builders (mkDarwin, mkNixOS, auto-discovery)
│   ├── devshells.nix           # Language-specific development shells
│   ├── pre-commit.nix          # Git pre-commit hook configuration
│   └── theme.nix               # Centralized theme/palette definitions
├── overlays/                   # Nixpkgs overlays
├── pkgs/                       # Custom packages
├── templates/                  # Project and host templates
│   ├── host/                   # Generic host scaffold
│   ├── nixos-desktop/          # NixOS desktop host scaffold
│   ├── node/                   # Node.js project template
│   ├── python/                 # Python project template
│   ├── rust/                   # Rust project template
│   └── go/                     # Go project template
├── secrets/                    # Encrypted secrets (sops-nix)
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

1. **Get the Repository**

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

2. **Configure Your System**

   **1. Set your username in `flake.nix`:**

   Hosts are auto-discovered from `hosts/*/meta.nix` files. The default username is defined once in `flake.nix`:

   ```nix
   defaultUsername = "wm";  # Change to your exact macOS/Linux username (run 'whoami')
   ```

   All hosts inherit this username unless they override it in their `meta.nix`.

   **Host discovery rule:** a host is only discovered when `meta.nix`, `configuration.nix`, and `home.nix` all exist, `meta.nix` evaluates successfully, and `meta.enable = true`.

   **2. Edit the host's `meta.nix`:**

   Each host directory has a `meta.nix` that defines whether the host is active plus its platform and device type. Host discovery only includes directories with `enable = true` and the full `meta.nix` / `configuration.nix` / `home.nix` trio present, so staging directories under `hosts/` are safe:

   ```nix
   # hosts/mbp/meta.nix
   {
     enable = true;              # Set false while staging or copying a new host
     type = "darwin";             # "darwin" or "nixos"
     system = "x86_64-darwin";    # "aarch64-darwin" for Apple Silicon, "x86_64-linux" for NixOS
     device = "laptop";           # "laptop" or "desktop"
     # username = "other";        # Optional: override defaultUsername for this host
   }
   ```

   **3. Rename the Host Directory to Match Your Hostname**

   The directory name under `hosts/` becomes the configuration name. Rename it to match your hostname (run `scutil --get LocalHostName` on macOS):

   ```bash
   mv hosts/mbp hosts/YOUR_HOSTNAME
   ```

   When copying from `templates/host` or `templates/nixos-desktop`, leave `enable = false` until the new host is ready to build, then flip it to `true`.

   **4. Disable SOPS (Crucial if you haven't set up age keys yet):**
   The default `home.nix` has SOPS enabled. If you don't have your age keys set up yet, you **must disable it** before building to avoid activation errors. Edit your host's `home.nix` file:

   ```nix
   profiles.sops.enable = false;
   ```

   You can re-enable SOPS later by following step 5.

3. **Install nix-darwin**

   ```bash
   # Install nix-darwin with your customized configuration
   nix run nix-darwin -- switch --flake .
   ```

   After installation, configure Git manually:

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your-email@example.com"
   ```

   > **Note:** GPG commit signing is disabled by default. It is automatically enabled when you set up SOPS (step 5), which provides your signing key. To enable signing without SOPS, set `programs.git.signing.signByDefault = true` and configure your GPG key.

4. **Set Up SOPS Secrets (Optional)**

   The `mbp` host config ships with SOPS enabled. If you disabled it in step 3, follow these steps when you're ready to enable sops-encrypted Git credentials:

   a. **Enable sops in your host config** (`hosts/mbp/home.nix`):

   ```nix
   profiles.sops.enable = true;
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

   The default secrets in `sops.nix` are fully customizable — add, remove, or replace them to fit your needs. The included defaults are just a starting point:

   ```bash
   cat > secrets/secrets.yaml << EOF
   git-userName: your-username
   git-userEmail: your-email@example.com
   git-signingKey: YOUR_GPG_KEY_ID
   ssh-config-srv696730: |
     Host srv696730
       HostName your-server.example.com
       User your-user
       IdentityFile ~/.ssh/id_ed25519
   EOF

   sops -e -i secrets/secrets.yaml
   ```

   Edit the `secrets` attrset in `sops.nix` to match whatever keys you define in `secrets.yaml`. You can also add host-specific secrets via `profiles.sops.extraSecrets` in your host's `home.nix`. See [Customizing secrets](home/profiles/README.md#customizing-secrets) for details.

   **Example use cases for sops:**
   - **Git credentials** — Encrypt your name, email, and GPG signing key so they're never stored in plaintext in the repo. Git hooks automatically read from sops-decrypted secrets on checkout and merge.
   - **API tokens** — Store tokens for services (GitHub, cloud providers) as sops secrets and reference them in shell environment or program configs.
   - **SSH keys** — Manage SSH private keys as encrypted secrets that are decrypted at activation time by sops-nix.
   - **Shared configs across machines** — Commit encrypted secrets to the repo and decrypt on each machine with its own age key. Each host only needs its age key to access all shared secrets.

   **Convenience aliases** (available when `profiles.sops.enable = true`):

   ```bash
   sops-edit secrets/secrets.yaml   # Decrypt, edit in $EDITOR, re-encrypt
   sops-encrypt secrets/new.yaml    # Encrypt a file in-place
   sops-decrypt secrets/secrets.yaml # Print decrypted contents to stdout
   ```

## Adding a New Host

To deploy this configuration on another machine:

1. **Create a host directory** by copying an existing one:

   ```bash
   cp -r hosts/mbp hosts/YOUR_HOSTNAME
   ```

2. **Edit `hosts/YOUR_HOSTNAME/meta.nix`** for the new machine:

   ```nix
   {
     enable = true;              # Required for host auto-discovery
     type = "darwin";             # "darwin" or "nixos"
     system = "aarch64-darwin";   # Architecture of the new machine
     device = "laptop";           # "laptop" or "desktop"
     username = "youruser";       # Optional: only needed if different from defaultUsername in flake.nix
   }
   ```

   New hosts are ignored until `enable = true`, so you can safely stage incomplete directories under `hosts/`.

3. **Disable SOPS** in `hosts/YOUR_HOSTNAME/home.nix` if you haven't set up age keys:

   ```nix
   profiles.sops.enable = false;
   ```

4. **Build:**

   ```bash
   sudo darwin-rebuild switch --flake .#YOUR_HOSTNAME
   # Or for first-time install:
   nix run nix-darwin -- switch --flake .#YOUR_HOSTNAME
   ```

The host is auto-discovered from `meta.nix` — no changes to `flake.nix` required.

## Usage

### System Updates

```bash
# macOS system-level changes (nix-darwin + home-manager)
nixswitch  # Alias: sudo darwin-rebuild switch --flake ~/nix-config#<hostname>
# OR manually:
sudo darwin-rebuild switch --flake .#<hostname>

# Alternative using nix run (if darwin-rebuild not available)
sudo nix run nix-darwin -- switch --flake .#<hostname>

# NixOS system-level changes
sudo nixos-rebuild switch --flake .#<hostname>
```

The `nixswitch` alias automatically uses the current host's name — no need to specify it.

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

## Architecture

The configuration uses a layered profile system for Home Manager:

```
base/            Shared foundations (shell, git, core programs)
  └─ features/   Optional feature sets, gated by options
       ├─ development.nix   Dev tools, editors, language packages
       ├─ kubernetes.nix    Kubernetes tooling (tool set selection)
       ├─ sops.nix          Secrets and signing integration
       └─ platform/         Platform-specific settings (darwin, nixos)
```

Profiles are composed via `mkHomeManagerConfig` in `lib/builders.nix`. Feature flags in `home/profiles/features/` use `lib.mkEnableOption` to gate package groups.

## Development Shells

Language-specific development environments are available as flake outputs (defined in `lib/devshells.nix`). Only Python is installed globally (required by Neovim); all other language toolchains are available exclusively through devShells:

```bash
nix develop .#node      # Node.js, Yarn, pnpm, Bun, TypeScript, Prettier
nix develop .#python    # Python 3.13, uv, pip, Ruff, mypy, pytest
nix develop .#rust      # rustc, Cargo, rustfmt, Clippy, rust-analyzer
nix develop .#go        # Go, gopls, golangci-lint, Delve
nix develop .#ruby      # Ruby 3.4
nix develop .#php       # PHP 8.4, Composer
```

The default `nix develop` shell provides Nix tooling (formatters, linters, pre-commit hooks).

### Automatic activation with direnv

**Auto-detect (recommended):** When you `cd` into a project with recognized markers (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Gemfile`, `composer.json`), a zsh hook prompts you to create a devShell. It generates `flake.nix` in `~/.cache/direnv-flakes/` and a `.envrc` pointing to it — no files added to the project.

**Manual setup:** You can also create `.envrc` files yourself:

```bash
# Use a devShell from this config
echo 'use flake ~/nix-config#rust' > .envrc
direnv allow
```

Replace `#rust` with any available shell (`#node`, `#go`, `#python`, `#ruby`, `#php`).

If the project has its own `flake.nix` (e.g. from `nix flake init -t ~/nix-config#rust`), use:

```bash
echo 'use flake' > .envrc
direnv allow
```

The environment loads/unloads automatically as you enter/leave the directory.

> **Note:** If a project's direnv cache points to a stale path (e.g. a deleted worktree), run `direnv reload` in that project to refresh the cache.

## Project Templates

Scaffold a new project with a ready-made `flake.nix`:

```bash
# Initialize a new project from a template
nix flake init -t ~/nix-config#node
nix flake init -t ~/nix-config#python
nix flake init -t ~/nix-config#rust
nix flake init -t ~/nix-config#go
```

Each template provides a self-contained `flake.nix` with the same tooling as the corresponding development shell, so new projects work independently from this config.

## Troubleshooting

### Activation Failing due to "Unexpected files in /etc" (nix.custom.conf)

If your very first `nix-darwin` installation fails with:

```
error: Unexpected files in /etc, aborting activation
The following files have unrecognized content and would be overwritten:
  /etc/nix/nix.custom.conf
```

This occurs because the Determinate Systems Nix installer places its own configuration file here, but `nix-darwin` requires total declarative control over `/etc/nix/`.

Rename the old config so `nix-darwin` can safely write its own:

```bash
sudo mv /etc/nix/nix.custom.conf /etc/nix/nix.custom.conf.before-nix-darwin
# Then re-run the switch command
sudo nix run nix-darwin -- switch --flake .
```

### Homebrew Taps conflict after enabling `mutableTaps = false`

If you see:

```
Error: An existing /usr/local/Homebrew/Library/Taps is in the way
```

Remove the existing taps so nix-darwin can manage them declaratively:

```bash
sudo rm -rf /usr/local/Homebrew/Library/Taps
sudo darwin-rebuild switch --flake ~/nix-config#mbp
```

### Known Harmless Warnings

**`options.json` store path warning:**

```
warning: Using 'builtins.derivation' to create a derivation named 'options.json' that references the store path ... without a proper context.
```

This is a [known home-manager issue](https://github.com/nix-community/home-manager) on recent Nix versions. It is mitigated by `manual.json.enable = false` and `documentation.doc.enable = false` in this config. The warning is cosmetic and will be resolved upstream.

**`eval-cores` / `lazy-trees` unknown setting (Determinate Nix):**

```
warning: unknown setting 'eval-cores'
warning: unknown setting 'lazy-trees'
```

These come from Determinate Nix's managed `/etc/nix/nix.conf`, not from this config. They appear when the Nix binary doesn't recognize settings added by a newer Determinate config. Safe to ignore — Nix skips unknown settings. Running `sudo determinate-nixd upgrade` may resolve them on supported platforms.

## Documentation

Detailed documentation for specific components:

### Core Configuration

- **[Home Manager Profiles](home/profiles/README.md)** - Layered profile system (base → features → platform)
- **[Custom Packages](pkgs/README.md)** - Kubernetes tools collection

### Programs

- **[Zsh Configuration](home/programs/shells/zsh/README.md)** - Zsh setup with vim mode, FZF commands, and aliases
- **[Development Tools](home/programs/development/README.md)** - Direnv layouts and Git configuration (basic or sops)
- **[Neovim Snippets](home/programs/editors/neovim/lua/snippets/README.md)** - LuaSnip snippets for multiple languages
