# Home Manager Profiles

This directory contains the layered profile system for Home Manager configurations.

## Directory Structure

```
profiles/
├── base/                    # Foundation profiles
│   └── minimal.nix         # Essential cross-platform tools
├── features/               # Feature-specific profiles
│   ├── development.nix     # Development tools and environments
│   ├── desktop.nix         # GUI applications and desktop tools
│   ├── kubernetes.nix      # Kubernetes tooling and workflows
│   └── sops.nix            # SOPS encrypted secrets (gated by profiles.sops.enable)
├── platform/               # Platform-specific profiles
│   ├── darwin.nix          # macOS complete profile
│   ├── nixos.nix           # NixOS complete profile
│   ├── darwin-pkgs.nix     # macOS-specific packages
│   └── nixos-pkgs.nix      # Linux-specific packages
└── README.md
```

## Profile Hierarchy

Profiles are organized in an inheritance chain, with each level building upon the previous:

```
base/minimal.nix (foundation)
    ↓
features/development.nix (adds dev tools)
    ↓
features/desktop.nix (adds GUI apps)
    ↓
platform/darwin.nix or platform/nixos.nix (platform-specific)
```

## Profile Descriptions

### Base Profiles

#### `base/minimal.nix` - Foundation Profile
**Purpose**: Essential cross-platform tools available everywhere
**Includes**:
- Basic CLI tools (bat, eza, fd, fzf, jq, ripgrep, tree, zoxide)
- Network essentials (curl, wget)
- System utilities (htop, fastfetch)
- File processing (zip, unzip, gzip)
- Shell configuration (zsh with native plugins)
- Essential utilities (btop)

**Used by**: All other profiles
**Imports**: Programs (shells, utilities/btop)

---

### Feature Profiles

#### `features/development.nix` - Development Profile

**Purpose**: Comprehensive development environment

**Includes**:

- Text editors (Neovim, Emacs, Neovide)
- Development tools (Git with basic config, direnv)
- Terminal emulators (Alacritty, Ghostty, Tmux)
- Build tools and compilers
- Code quality tools (linters, formatters)
- Database clients
- Programming language runtimes
- Web development tools
- Security tools

**Git Configuration**: Uses basic git by default (no sops dependency). For sops-encrypted git credentials, import `features/sops.nix` and set `profiles.sops.enable = true` in your host config.

**Inherits from**: `base/minimal.nix`
**Used by**: `features/desktop.nix`

**Imports**:

- Programs: editors, development (direnv), shells, terminals, utilities
- Packages: build-tools, code-quality, databases, languages, security, terminals, web-dev

#### `features/desktop.nix` - Desktop Profile
**Purpose**: GUI applications and desktop environment tools
**Includes**:
- Desktop applications
- Media processing tools (imagemagick, ghostscript)

**Inherits from**: `features/development.nix` (which includes `base/minimal.nix`)
**Used by**: `platform/darwin.nix`, `platform/nixos.nix`
**Imports**:
- Packages: utilities

#### `features/kubernetes.nix` - Kubernetes Development Profile

**Purpose**: Kubernetes engineer workflow with remote cluster management

**Includes**:

- Kubernetes CLI tools (kubectl, helm, kustomize, kubectx)
- GitOps tools (argocd, flux)
- Container tools (skopeo, dive, crane)
- Local development (kind, tilt, kubeconform) when `includeLocalDev = true`
- Cloud provider CLIs (AWS, GCP, Azure)

**Configuration Options**:

```nix
profiles.kubernetes = {
  enable = true;
  includeLocalDev = true;  # Include kind, tilt, kubeconform (default: true)
};
```

**Note**: k9s configuration is managed via separate YAML files (`k9s/config.yml`, `k9s/skin.yml`).

**Standalone**: Can be imported independently for Kubernetes-only setups

#### `features/sops.nix` - SOPS Encrypted Secrets

**Purpose**: Gate all sops-nix configuration behind a single feature flag

**Includes**:

- Git post-checkout/post-merge hooks that read from sops secrets
- GPG configuration for commit signing
- SOPS shell aliases (sops-edit, sops-encrypt, sops-decrypt)
- launchd service PATH fix (Darwin)

**Configuration**:

```nix
profiles.sops.enable = true;
```

**Prerequisites**:
- Age key at `~/.config/sops/age/keys.txt`
- Encrypted `secrets/secrets.yaml` with your age public key

---

### Platform Profiles

#### `platform/darwin.nix` - macOS Profile
**Purpose**: macOS-specific configuration entry point
**Includes**:
- All tools from desktop → development → minimal chain
- macOS-specific packages and settings
- macOS window management (AeroSpace)

**Inherits from**: `features/desktop.nix`
**Platform**: macOS (Darwin)
**Imports**:
- Platform: platform/darwin-pkgs.nix
- Programs: utilities/aerospace

---

#### `platform/nixos.nix` - NixOS Profile
**Purpose**: NixOS-specific configuration entry point
**Includes**:
- All tools from desktop → development → minimal chain
- Linux-specific packages and settings
- X11/Wayland utilities

**Inherits from**: `features/desktop.nix`
**Platform**: NixOS (Linux)
**Imports**:
- Platform: platform/nixos-pkgs.nix

---

## Platform-Specific Configurations

Platform-specific packages and settings are located in `platform/`:

### `platform/darwin.nix`
macOS-specific packages:
- `mkalias` - macOS alias creation
- `pam-reattach` - Touch ID support in tmux
- `reattach-to-user-namespace` - macOS clipboard integration
- `aerospace` - Tiling window manager

### `platform/nixos.nix`
Linux-specific packages:
- `xclip` - X11 clipboard utility
- `xsel` - X11 selection utility
- XDG desktop configuration

---

## Import Convention

All imports follow a standardized format with category prefixes:

```nix
imports = [
  # Profiles: [description]
  ./minimal.nix

  # Programs: [description]
  ../programs/editors
  ../programs/development

  # Packages: [description]
  ../packages/build-tools.nix
  ../packages/web-dev.nix

  # Platform: [description]
  ./platform/darwin.nix
];
```

**Rules**:
1. **Directory imports**: Omit `default.nix` → `../programs/shells`
2. **File imports**: Include `.nix` extension → `../packages/web-dev.nix`
3. **Relative paths**: Use `../` for parent, `./` for same level
4. **Categories**: Prefix comments with `Profiles:`, `Programs:`, `Packages:`, or `Platform:`

---

## Adding New Packages

### To add packages available everywhere:
→ Add to `minimal.nix` `home.packages`

### To add development-specific packages:
1. Add to appropriate package file in `../packages/`
2. If new category needed, create new `.nix` file
3. Import in `development.nix`

### To add desktop-specific packages:
1. Add to the appropriate package file in `../packages/`
2. Ensure imported in `development.nix`

### To add platform-specific packages:
→ Add to `platform/darwin.nix` or `platform/nixos.nix`

---

## Package Organization

Package collections are in `../packages/`:
- `build-tools.nix` - Compilers, build systems, dev tools
- `cli-essentials.nix` - Core CLI tools (bat, eza, fd, fzf, ripgrep, etc.)
- `code-quality.nix` - Linters, formatters, analyzers
- `databases.nix` - Database clients (psql, redis-cli, etc.)
- `languages.nix` - Language runtimes (Node, Python, Go, etc.)
- `network.nix` - Network tools (wget, cachix)
- `security.nix` - Security tools (sops, age)
- `terminals.nix` - Terminal tools (tmuxinator, moreutils)
- `web-dev.nix` - Web dev tools (httpie, curl, grpcurl, caddy)

---

## Program Configurations

Program-specific configurations are in `../programs/`:
- `development/` - Direnv, basic Git
- `editors/` - Neovim, Emacs, Neovide
- `shells/` - Zsh with fzf-tab and native plugins
- `terminals/` - Alacritty, Ghostty, Tmux
- `utilities/` - AeroSpace, btop, Claude, yazi

Kubernetes configuration is in `features/kubernetes.nix` (not under `programs/`).

---

## Usage in Flake

Profiles are imported via host-specific home configurations:

```nix
# hosts/mbp/home.nix
{
  imports = [
    ../../home/profiles/platform/darwin.nix  # macOS profile
    ../../home/profiles/features/sops.nix    # Optional: SOPS secrets
  ];
  profiles.sops.enable = true;  # Enable when age key is set up
}
```

```nix
# hosts/desktop/home.nix
{
  imports = [
    ../../home/profiles/platform/nixos.nix  # NixOS profile
  ];
}
```

---

## Architecture Principles

1. **Layered Inheritance**: Each profile builds on the previous, avoiding duplication
2. **Clear Separation**: Profiles vs Programs vs Packages vs Platform configs
3. **Explicit Imports**: Import specific files rather than aggregators
4. **Consistent Naming**: Category prefixes in comments for clarity
5. **Documentation**: Each file has clear purpose and usage notes
