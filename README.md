# Nix Configuration

A modular Nix configuration for macOS (nix-darwin) and NixOS with Home Manager integration. Based on **nixpkgs 26.05**.

## Features

- **Cross-platform**: Works on both macOS and NixOS
- **Modular architecture**: Organized system, service, and user configurations
- **Import-based composition**: Layered user profiles provide shared package defaults; hosts import capabilities and the central program module
- **Import-managed programs**: Hosts import `home/programs/default.nix`; category `default.nix` files select individual programs
- **Homebrew integration**: macOS application management
- **Development tools**: Neovim, Emacs, Git, and language toolchains

## Platform Support

`main` is the current-platform line. It declares the Apple Silicon `mbp2` host
and retains the shared NixOS modules and templates that will gain first-class
desktop/server fixtures in Phase 2.

Intel macOS is preserved separately on the local `legacy-intel` branch at the
verified `legacy-intel-26.05-baseline` tag. That branch remains on the frozen
26.05-compatible stack; publishing the branch and tag is a separate explicit
operation.

## Structure

```
nix-config/
|-- flake.nix                   # Main flake configuration (flake-parts)
|-- flake.lock                  # Flake input locks
|-- hosts/                      # Host-specific configurations
|   |-- mbp2/                   # MacBook Pro (darwin) aarch64-darwin
|-- home/                       # Home Manager configurations
|   |-- profiles/               # Layered platform and import-only capability modules
|   |-- programs/               # Program import list and configurations (editors, shells, terminals, etc.)
|   `-- packages/               # Package bundles composed by profile layers
|-- modules/                    # System modules
|   |-- system/                 # System configurations (darwin, nixos, shared)
|   `-- services/               # Service modules (homebrew, NixOS services)
|-- lib/                        # Shared library functions
|   |-- builders.nix            # System builders (mkDarwin, mkNixOS, auto-discovery)
|   |-- devshells.nix           # Language-specific development shells
|   |-- pre-commit.nix          # Git pre-commit hook configuration
|   `-- theme.nix               # Centralized theme/palette definitions
|-- overlays/                   # Nixpkgs overlays
|-- pkgs/                       # Custom packages
|-- templates/                  # Project and host templates
|   |-- host/                   # Generic host scaffold
|   |-- nixos-desktop/          # NixOS desktop host scaffold
|   |-- node/                   # Node.js project template
|   |-- python/                 # Python project template
|   |-- ai-python/              # Python AI app template with evals
|   |-- rust/                   # Rust project template
|   `-- go/                     # Go project template
|-- secrets/                    # Encrypted secrets (sops-nix)
`-- stylua.toml                 # Stylua configuration
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

   **1. Set your username in `flake.nix`:**

   Hosts are auto-discovered from `hosts/*/meta.nix` files. The default username is defined once in `flake.nix`:

   ```nix
   defaultUsername = "wm";  # Change to your exact macOS/Linux username (run 'whoami')
   ```

   All hosts inherit this username unless they override it in their `meta.nix`.

   **Host discovery rule:** a host is only discovered when `meta.nix`, `configuration.nix`, and `home.nix` all exist and `meta.nix` evaluates successfully.

   **2. Edit the host's `meta.nix`:**

   Each host directory has a `meta.nix` that defines its platform and device type. Host discovery only includes directories with the full `meta.nix` / `configuration.nix` / `home.nix` trio present:

   ```nix
   # hosts/mbp2/meta.nix
   {
     type = "darwin";             # "darwin" or "nixos"
     system = "aarch64-darwin";    # "x86_64-linux" for NixOS
     device = "laptop";           # "laptop", "desktop", "server", or "vm"
     # username = "other";        # Optional: override defaultUsername for this host
   }
   ```

   **3. Rename the Host Directory to Match Your Hostname**

   The directory name under `hosts/` becomes the configuration name. Rename it to match your hostname (run `scutil --get LocalHostName` on macOS):

   ```bash
   mv hosts/mbp2 hosts/YOUR_HOSTNAME
   ```

   **4. Import the central program module in `home.nix`:**

   Program modules live under `home/programs/`. Hosts import `home/programs/default.nix`
   once; that root selects categories, while each category's `default.nix` selects
   its individual programs.

   ```nix
   {
     imports =
       [
         ../../home/profiles/platforms/darwin.nix
         ../../home/programs
       ];
   }
   ```

   **5. Disable SOPS (Crucial if you haven't set up age keys yet):**
   The default host config imports `./sops.nix`. If you don't have your age keys set up yet, you **must disable it** before building to avoid activation errors. Remove or comment this import in your host's `home.nix` file:

   ```nix
   imports = [
     # ./sops.nix
   ];
   ```

   You can re-enable SOPS later by adding the import back.

4. **Install nix-darwin**

   ```bash
   # Install nix-darwin with your customized configuration
   nix run nix-darwin -- switch --flake '.#YOUR_HOSTNAME'
   ```

   After installation, configure Git manually:

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your-email@example.com"
   ```

   > **Note:** GPG commit signing is disabled by default. It is automatically enabled when you set up SOPS, which provides your signing key. To enable signing without SOPS, set `programs.git.signing.signByDefault = true` and configure your GPG key.

5. **Set Up SOPS Secrets (Optional)**

   Host configs opt into SOPS through `hosts/<host>/sops.nix`. If you disabled it before the first build, follow these steps when you're ready to enable sops-encrypted Git credentials:

   a. **Enable sops in your host config** (`hosts/<host>/home.nix`):

   ```nix
   imports = [
     ./sops.nix
   ];
   ```

   b. **Generate age key:**

   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
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

   The default secrets are fully customizable — add, remove, or replace them to fit your needs. The included defaults are just a starting point:

   ```bash
   cat > secrets/secrets.yaml << EOF
   git-userName: your-username
   git-userEmail: your-email@example.com
   git-signingKey-YOUR_HOSTNAME: YOUR_GPG_KEY_ID
   ssh-config-srv696730: |
     Host srv696730
       HostName your-server.example.com
       User your-user
       IdentityFile ~/.ssh/id_ed25519
   EOF

   sops -e -i secrets/secrets.yaml
   ```

   e. **Add, change, or remove a secret:**

   Secrets are split in two places:
   - `home/profiles/capabilities/sops.nix` — the machinery plus the three git secrets its hooks require (`git-userName`, `git-userEmail`, and the per-host `git-signingKey-${hostName}`). Normally not edited.
   - `hosts/<host>/sops.nix` — every other secret for that machine. This is the file to edit.

   To add a value:

   ```bash
   # 1. Add the key to the encrypted store (opens $EDITOR, re-encrypts on save)
   sops secrets/secrets.yaml
   ```

   ```nix
   # 2. Declare it in hosts/<host>/sops.nix with its decrypted destination
   config.sops.secrets = {
     github-token = {
       path = "${config.home.homeDirectory}/.config/secrets/github-token";
       mode = "0400";   # 0400 read-only, 0600 when a tool must rewrite it
     };
   };
   ```

   ```bash
   # 3. Rebuild, then validate structure without decrypting values
   sudo darwin-rebuild switch --flake '.#YOUR_HOSTNAME'
   just check
   ```

   The YAML key name must match the Nix attribute name. Removing a secret means deleting it from both files. `just check` compares the declared attribute names against the encrypted file and fails if they drift.

   **Example use cases for sops:**
   - **Git credentials** — Encrypt your name, email, and GPG signing key so they're never stored in plaintext in the repo. Git hooks automatically read from sops-decrypted secrets on checkout and merge.
   - **API tokens** — Store tokens for services (GitHub, cloud providers) as sops secrets and reference them in shell environment or program configs.
   - **SSH keys** — Manage SSH private keys as encrypted secrets that are decrypted at activation time by sops-nix.
   - **Shared configs across machines** — Commit encrypted secrets to the repo and decrypt on each machine with its own age key. Each host only needs its age key to access all shared secrets.

   **Convenience aliases** (available when the SOPS capability is imported):

   ```bash
   sops-edit secrets/secrets.yaml   # Decrypt, edit in $EDITOR, re-encrypt
   sops-encrypt secrets/new.yaml    # Encrypt a file in-place
   sops-decrypt secrets/secrets.yaml # Print decrypted contents to stdout
   ```

## Adding a New Host

To deploy this configuration on another machine, start from the cross-platform
host scaffold rather than copying the existing `mbp2` Darwin host:

1. **Create a host directory** from the host template:

   ```bash
   cp -r templates/host hosts/YOUR_HOSTNAME
   ```

2. **Edit `hosts/YOUR_HOSTNAME/meta.nix`** for the new machine:

   ```nix
   {
     type = "darwin";             # "darwin" or "nixos"
     system = "aarch64-darwin";   # Architecture of the new machine
     device = "laptop";           # "laptop", "desktop", "server", or "vm"
     username = "youruser";       # Optional: only needed if different from defaultUsername in flake.nix
   }
   ```

3. **Select the platform configuration:**
   - In `configuration.nix`, keep the Darwin configuration or replace it with
     the commented NixOS configuration and add the machine's generated
     `hardware-configuration.nix`.
   - In `home.nix`, select the matching Darwin or NixOS platform profile and
     home-directory path.
   - Add optional capabilities such as SOPS only after their prerequisites are
     configured.

4. **Build:**

   ```bash
   # Darwin
   sudo darwin-rebuild switch --flake '.#YOUR_HOSTNAME'
   # Or, for the first Darwin installation:
   nix run nix-darwin -- switch --flake '.#YOUR_HOSTNAME'

   # NixOS
   sudo nixos-rebuild switch --flake '.#YOUR_HOSTNAME'
   ```

The host is auto-discovered from `meta.nix` — no changes to `flake.nix` required.

## Usage

### System Updates

```bash
# macOS system-level changes (nix-darwin + home-manager)
nixswitch  # Alias: nh darwin switch -H <hostname> ~/nix-config
# OR manually:
sudo darwin-rebuild switch --flake '.#<hostname>'

# Alternative using nix run during first-time Darwin setup
nix run nix-darwin -- switch --flake '.#<hostname>'

# NixOS system-level changes
sudo nixos-rebuild switch --flake '.#<hostname>'
# Or use the NixOS alias:
nixswitch  # Alias: nh os switch -H <hostname> ~/nix-config
```

**Quoting:** zsh with `extendedglob` treats `#` as a glob operator, so an
unquoted flake reference fails with `zsh: no matches found: .#mbp2`. Quote the
reference (`'.#mbp2'`) or use the `nixswitch` alias, which needs no argument.

The `nixswitch` alias automatically uses the current host's name — no need to specify it.

**Note:** This configuration integrates home-manager through nix-darwin/NixOS modules, so there's no separate home-manager-only command. User configurations are applied together with system configurations.

### Doom Emacs Reconciliation

Doom's source is pinned by Nix, but package reconciliation is deliberately not
run during activation. After the first activation, after changing
`~/.config/doom`, or after updating the pinned Doom revision, run:

```bash
doom sync
```

This explicitly runs the pinned Doom executable from `~/.config/emacs`; it does
not clone or execute mutable upstream code during Home Manager activation.

The pin lives in `home/programs/editors/emacs/default.nix`. Doom v3 keeps its
modules in the `sources/doom+` git submodule, so the fetch sets
`fetchSubmodules = true`. Without it the checkout contains no modules and every
module listed in `doom.d/init.el` is silently missing — `doom sync` succeeds but
installs only Doom's core packages. When bumping `rev`, keep `fetchSubmodules`
and update `hash` from:

```bash
nix run 'nixpkgs#nix-prefetch-git' -- \
  --url https://github.com/doomemacs/doomemacs \
  --rev <NEW_REV> --fetch-submodules
```

**`doom sync` fails to clone a package:** a `fatal: could not read Username for
'https://github.com'` error during clone means the recipe points at a repository
that no longer exists — GitHub answers 404 for a missing repository by asking for
credentials. Verify with `git ls-remote <url>` and drop or repoint the recipe in
`doom.d/packages.el`. The `gtea`, `gogs` and `buck` wrappers were removed from
`ghub` 5.x and their `emacsmirror` mirrors are gone; they are no longer declared
here.

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
nixclean     # Clean old generations through nh

# Debugging
nixtrace     # Show trace for debugging
nixverbose   # Verbose output
nixedit      # Open configuration in $EDITOR
```

#### **Nix Utilities**

```bash
nxsearch     # Search packages through nh
nxrepl       # Interactive nix REPL
nxdev        # Enter development shell

# Update every input, then validate the result
nix flake update
just check

# Update one input, then validate the result
nix flake update nixpkgs
just check
```

### Repository Validation

`just check` is the authoritative local and CI gate. It builds native checks,
evaluates every declared system without cross-building, validates all standalone
templates in disposable copies, checks encrypted SOPS structure without
decrypting values, and exercises host/layout/security regressions.

```bash
just check
```

### Pre-commit Hooks

This configuration uses [git-hooks.nix](https://github.com/cachix/git-hooks.nix) for reproducible pre-commit checks and tool provisioning:

**Enabled hooks:**

- `alejandra` - Nix code formatter
- `deadnix` - Remove unused Nix code
- `statix` - Nix linter
- `stylua` - Lua formatter

**Troubleshooting:**

If you use a custom Git hooks directory via `core.hooksPath`, the dev shell will not auto-install hooks. That avoids conflicts with Home Manager or SOPS-managed hooks.

Run checks manually:

```bash
nix develop --command pre-commit run --all-files
```

Install a repo-specific commit hook into the active hooks directory:

```bash
nix develop --command install-pre-commit-hook
```

If the active `core.hooksPath` points at a shared global directory, the installer refuses by default so you do not accidentally affect every repo. Use `--force-shared` only when that is intentional.

If a commit is blocked by a stale repo hook, for example:

```
.git/hooks/pre-commit: .../pre-commit: No such file or directory
```

This means the repo hook points at an old Nix store path. Reinstall the managed hook:

```bash
nix develop --command install-pre-commit-hook
```

Then retry the commit.

The dev shell also refreshes `.pre-commit-config.yaml` as a symlink to the generated config so manual runs and installed wrappers use the same configuration.

SOPS checkout/merge hooks use Git's template directory for newly initialized
repositories and do not set a global `core.hooksPath`, so repository-local
pre-commit hooks continue to run. To install or refresh the SOPS hooks in an
existing repository, run `install-sops-git-hooks` from that repository.

#### **Quick Navigation**

```bash
dots         # cd ~/nix-config
files        # Open yazi file manager
vi           # nvim (Neovim)
```

## Architecture

The configuration uses a layered profile system for Home Manager:

```
home/profiles/
  ├─ layers/          Broad shared stacks
  ├─ platforms/       Darwin and NixOS composition
  └─ capabilities/    Import-only add-ons for tools, services, and secrets
```

Profiles are composed via `mkHomeManagerConfig` in `lib/builders.nix`. Capability modules in `home/profiles/capabilities/` are active when imported; `profiles.kubernetes.toolSet` remains as the selector for Kubernetes tool variants.

## Development Shells

Language-specific development environments are available as flake outputs (defined in `lib/devshells.nix`). Only Python is installed globally (required by Neovim); all other language toolchains are available exclusively through devShells:

```bash
nix develop .#node      # Node.js, Yarn, pnpm, Bun, TypeScript, Prettier
nix develop .#python    # Python 3.14, uv, pip, Ruff, mypy, pytest
nix develop .#rust      # rustc, Cargo, rustfmt, Clippy, rust-analyzer
nix develop .#go        # Go, gopls, golangci-lint, Delve
nix develop .#ruby      # Ruby 3.4
nix develop .#php       # PHP 8.4, Composer
```

The default `nix develop` shell provides Nix tooling (formatters, linters, pre-commit hooks).

### Automatic activation with direnv

**Auto-detect (recommended):** When you `cd` into a project with recognized markers (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Gemfile`, `composer.json`), a zsh hook prompts you to create a devShell. It generates `flake.nix` in `~/.cache/direnv-flakes/` and creates a project-local `.envrc` pointing to it. For Git repositories, the hook adds `.envrc` and `.direnv` to `.git/info/exclude`, so no tracked files are added.

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

## AI Engineering Workflow

This repo includes an optional import-only Home Manager capability for AI-assisted development:

- Import `home/profiles/capabilities/agent-dev.nix` to install local agent workflow commands.
- `agent-guard` checks agent-generated changes before review.
- `agent-eval-host <host>` evaluates any discovered Darwin or NixOS host output without building it.
- `nix flake init -t ~/nix-config#ai-python` creates a Python AI app with uv and evals.
- `docs/workflows/ai-agent-workflows.md` describes the review loop.
- `docs/workflows/mcp-curation.md` describes MCP discovery and safe tool use.

## Project Templates

Scaffold a new project with a ready-made `flake.nix`:

```bash
# Initialize a new project from a template
nix flake init -t ~/nix-config#node
nix flake init -t ~/nix-config#python
nix flake init -t ~/nix-config#ai-python
nix flake init -t ~/nix-config#rust
nix flake init -t ~/nix-config#go
```

Each language template provides a self-contained `flake.nix` with the same tooling as the corresponding development shell. The AI Python template adds its own application and evaluation tools. New projects therefore work independently from this config.

## Troubleshooting

### Existing Determinate Nix installation

Darwin hosts use Determinate's nix-darwin module with `nix.enable = false`, so
Determinate Nix retains ownership of its daemon and `/etc/nix` files while this
flake declares supported custom settings through `determinateNix.customSettings`.
Do not rename or replace `/etc/nix/nix.custom.conf` as part of normal activation.

### Homebrew Taps conflict after enabling `mutableTaps = false`

If you see:

```
Error: An existing <Homebrew prefix>/Library/Taps is in the way
```

First inspect the Homebrew prefix and the directory that would be moved. Then
move the existing taps aside so nix-darwin can manage them declaratively. This
works with both Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`)
installations and preserves a backup:

```bash
set -euo pipefail
brew_prefix="$(brew --prefix)"
case "$brew_prefix" in
  /opt/homebrew | /usr/local) ;;
  *) printf 'Unexpected Homebrew prefix: %s\n' "$brew_prefix" >&2; exit 1 ;;
esac
taps_dir="$brew_prefix/Library/Taps"
backup_dir="${taps_dir}.before-nix-homebrew.$(date +%Y%m%d%H%M%S)"
printf 'Moving %s\n' "$taps_dir"
test -d "$taps_dir"
test ! -e "$backup_dir"
sudo mv "$taps_dir" "$backup_dir"
sudo darwin-rebuild switch --flake "$HOME/nix-config#mbp2"
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

- **[Home Manager Profiles](home/profiles/README.md)** - Layers, platforms, and import-only capabilities
- **[Custom Packages](pkgs/README.md)** - Kubernetes tools collection

### Programs

- **[Programs](home/programs/default.nix)** - Central Home Manager import list for shells, editors, terminals, and utilities
