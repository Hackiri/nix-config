# Profile Import Map

This document provides a comprehensive map of how all files are linked in the profile structure.

## Table of Contents
1. [Overview](#overview)
2. [Profile Hierarchy](#profile-hierarchy)
3. [Detailed Import Maps](#detailed-import-maps)
4. [Host Configurations](#host-configurations)

---

## Overview

The profile system uses a three-layer architecture:
- **Base Layer**: Foundation profiles with essential tools
- **Features Layer**: Optional feature sets that build on base
- **Platform Layer**: Platform-specific configurations (Darwin/NixOS)

---

## Profile Hierarchy

```text
┌─────────────────────────────────────────────────────────────────────┐
│                         HOST CONFIGURATIONS                         │
│    (hosts/mbp/home.nix, hosts/desktop/home.nix)                     │
│    Optional: + base/git.nix + base/secrets.nix for sops            │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
        ┌───────────▼──────────┐   ┌───────────▼──────────┐
        │   platform/darwin    │   │   platform/nixos     │
        └───────────┬──────────┘   └───────────┬──────────┘
                    │                           │
                    └─────────────┬─────────────┘
                                  │
                    ┌─────────────▼──────────────┐
                    │    features/desktop        │
                    │  (includes development)    │
                    └─────────────┬──────────────┘
                                  │
                    ┌─────────────▼──────────────┐
                    │   features/development     │
                    │   (includes minimal +      │
                    │    basic Git by default)   │
                    └─────────────┬──────────────┘
                                  │
                    ┌─────────────▼──────────────┐
                    │      base/minimal          │
                    │     (foundation)           │
                    └─────────────────────────────┘
```

---

## Detailed Import Maps

### Layer 1: Base Profiles

#### `base/minimal.nix` (Foundation)
**Purpose**: Essential cross-platform tools available everywhere

```
base/minimal.nix
├── packages/cli-essentials.nix        # bat, eza, fd, fzf, ripgrep, jq
├── packages/network.nix               # wget, cachix
├── programs/security/                 # SSH hardening
├── programs/utilities/btop/           # System monitoring
└── Direct packages:
    ├── neofetch, htop
    └── unzip, zip, gzip
```

#### `base/git.nix` (Git with Sops Hooks - Optional)
**Purpose**: Git configuration with sops-integrated hooks

**Note**: This is NOT imported by default. Import it in your host config if you want sops integration.

```
base/git.nix
└── programs/development/git/git-hooks.nix
```

#### `base/secrets.nix` (Sops Utilities - Optional)
**Purpose**: Sops command-line utilities for encrypted secrets management

**Note**: Only needed if using `base/git.nix` for sops integration.

```
base/secrets.nix
└── programs/utilities/sops-nix/sops.nix  # Sops utilities only
```

---

### Layer 2: Features Profiles

#### `features/development.nix`

**Purpose**: Comprehensive development environment

```text
features/development.nix
├── Profiles:
│   └── base/minimal.nix                # Foundation (always)
│
├── Programs:
│   ├── programs/shells/                # Zsh, starship, bash
│   ├── programs/editors/               # Neovim, Emacs, etc.
│   ├── programs/development/           # Direnv + basic Git (default)
│   ├── programs/kubernetes/            # Kubernetes tools module
│   ├── programs/terminals/             # Tmux, Alacritty, etc.
│   └── programs/utilities/             # Btop, yazi (NOT sops)
│
└── Packages:
    ├── packages/build-tools.nix        # Make, cmake, gcc, etc.
    ├── packages/code-quality.nix       # Linters, formatters
    ├── packages/databases.nix          # DB clients, Redis, etc.
    ├── packages/languages.nix          # Python, Node, Go, Rust, etc.
    ├── packages/security.nix           # Security utilities
    ├── packages/terminals.nix          # Terminal utilities
    ├── packages/web-dev.nix            # Web development tools
    └── packages/custom.nix             # Custom /pkgs/ packages
```

**Import Chain (Default Configuration)**:

```text
development.nix
  ↓
  ├─→ minimal.nix (always)
  │     ↓
  │     └─→ programs/utilities/btop, programs/security
  │
  ├─→ programs/shells (zsh, starship, bash)
  └─→ programs/development/git/default.nix (basic Git, no sops)

For sops integration, add to your host config:
  ├─→ base/git.nix (Git with sops hooks)
  │     ↓
  │     └─→ programs/development/git/git-hooks.nix
  │
  └─→ base/secrets.nix (sops CLI utilities)
        ↓
        └─→ programs/utilities/sops-nix/sops.nix
```

#### `features/desktop.nix`

**Purpose**: GUI applications and desktop environment

```text
features/desktop.nix
├── Profiles:
│   └── features/development.nix        # Includes all dev tools
│
└── Packages:
    └── packages/utilities.nix          # Desktop utilities
```

**Import Chain**:

```text
desktop.nix
  ↓
  └─→ development.nix
        ↓
        ├─→ minimal.nix (always)
        └─→ basic Git (default, no sops)
```

#### `features/kubernetes.nix` (Standalone)

**Purpose**: Kubernetes development tools (optional add-on)

```text
features/kubernetes.nix
├── Options:
│   ├── profiles.kubernetes.enable
│   ├── profiles.kubernetes.toolset      # minimal, admin, operations, devops, security-focused, mesh, complete
│   └── profiles.kubernetes.includeLocalDev
│
└── Provides:
    ├── programs.kube module             # Kubectl, helm, etc.
    └── kind, tilt, kubeconform (if includeLocalDev)
```

**Note**: This is a standalone module that can be imported separately. It does NOT inherit from minimal/development.

---

### Layer 3: Platform Profiles

#### `platform/darwin.nix` (macOS)
**Purpose**: macOS-specific configuration

```
platform/darwin.nix
├── Profiles:
│   └── features/desktop.nix            # Full desktop stack
│       └── features/development.nix    # Full dev stack
│           └── base/minimal.nix        # Foundation
│
├── Platform Packages:
│   └── platform/darwin-pkgs.nix
│       ├── mkalias
│       ├── pam-reattach
│       ├── reattach-to-user-namespace
│       └── aerospace
│
���── Programs:
    └── programs/utilities/aerospace/   # macOS window manager
```

**Full Import Chain (Default Configuration)**:
```
platform/darwin.nix
  ↓
  ├─→ features/desktop.nix
  │     ↓
  │     ├─→ features/development.nix
  │     │     ↓
  │     │     ├─→ base/minimal.nix (always)
  │     │     │     ↓
  │     │     │     └─→ programs/utilities/btop, programs/security
  │     │     │
  │     │     ├─→ programs/shells (zsh, starship, bash)
  │     │     ├─→ programs/development/git/default.nix (basic Git)
  │     │     │
  │     │     └─→ [all development programs & packages]
  │     │
  │     └─→ [desktop packages]
  │
  ├─→ platform/darwin-pkgs.nix
  └─→ programs/utilities/aerospace

For sops integration, add to host config:
  ├─→ base/git.nix
  └─→ base/secrets.nix
```

#### `platform/nixos.nix` (Linux)

**Purpose**: NixOS-specific configuration

```text
platform/nixos.nix
├── Profiles:
│   └── features/desktop.nix            # Full desktop stack
│       └── features/development.nix    # Full dev stack
│           └── base/minimal.nix        # Foundation
│
└── Platform Packages:
    └── platform/nixos-pkgs.nix
        ├── xclip, xsel
        └── XDG configuration
```

**Full Import Chain**:

```text
platform/nixos.nix
  ↓
  ├─→ features/desktop.nix
  │     ↓
  │     └─→ [same as darwin above, with basic Git]
  │
  └─→ platform/nixos-pkgs.nix
```

---

## Host Configurations

### `hosts/mbp/home.nix` (macOS Laptop)

```text
hosts/mbp/home.nix
├── platform/darwin.nix                 # Full macOS stack
├── features/kubernetes.nix             # Additional K8s tools
├── base/git.nix                        # Optional: sops git hooks
├── base/secrets.nix                    # Optional: sops utilities
└── Configuration:
    └── profiles.kubernetes.enable = true
```

**Complete Import Tree**:

```text
hosts/mbp/home.nix
  ↓
  ├─→ platform/darwin.nix
  │     ↓
  │     └─→ [See platform/darwin.nix full chain above]
  │
  ├─→ features/kubernetes.nix           # Standalone K8s module
  │
  └─→ base/git.nix + base/secrets.nix   # Optional sops integration
```

### `hosts/desktop/home.nix` (NixOS Desktop)

```text
hosts/desktop/home.nix
└── platform/nixos.nix                  # Full NixOS stack
```

**Complete Import Tree**:

```text
hosts/desktop/home.nix
  ↓
  └─→ platform/nixos.nix
        ↓
        └─→ [See platform/nixos.nix full chain above]
```

---

## Program Modules Structure

### Programs Directory Organization

```
home/programs/
├── development/
│   ├── default.nix              → git/default.nix + direnv
│   ├── git/
│   │   ├── default.nix          → Basic Git config
│   │   └── git-hooks.nix        → Git + sops hooks (imported via base/git.nix)
│   └── direnv/
│
├── editors/
│   ├── default.nix              → All editor configs
│   ├── neovim/
│   ├── emacs/
│   └── ...
│
├── kubernetes/
│   └── default.nix              → Kubernetes tools module
│
├── shells/
│   ├── default.nix              → Zsh + shell enhancements
│   ├── zsh/
│   └── ...
│
├── terminals/
│   ├── default.nix              → All terminal configs
│   ├── tmux/
│   ├── alacritty/
│   └── ...
│
└── utilities/
    ├── default.nix              → btop + yazi (NOT sops!)
    ├── btop/
    ├── yazi/
    ├── sops-nix/
    │   └── sops.nix             → Only imported via base/secrets.nix
    └── aerospace/               → macOS window manager
```

### Key Points

1. **`programs/utilities/default.nix`** does NOT import sops (only btop + yazi)
2. **`programs/development/default.nix`** imports basic Git + direnv
3. **Git configuration is modular** with TWO options:
   - **Default**: `programs/development/git/default.nix` (basic Git, no sops)
   - **Optional**: `base/git.nix` → git-hooks.nix (with sops integration, add in host config)
4. **`base/secrets.nix`** only imports sops CLI utilities (optional, only needed with base/git.nix)

This ensures:

- **Works out of the box**: New users get basic Git without needing sops setup
- **No conflicts**: Only ONE Git configuration is imported at a time
- **Truly optional**: Sops can be added later in host config when ready

---

## Package Collections Structure

```
home/packages/
├── build-tools.nix              # Make, cmake, gcc, cargo-make, etc.
├── code-quality.nix             # Linters, formatters (alejandra, shellcheck, etc.)
├── databases.nix                # PostgreSQL, MySQL, Redis clients, etc.
├── languages.nix                # Python, Node, Go, Rust, Java, etc.
├── network.nix                  # Network debugging, DNS tools
├── security.nix                 # Password managers, encryption tools
├── terminals.nix                # Terminal utilities, multiplexers
├── utilities.nix                # General desktop utilities
├── web-dev.nix                  # Web development tools
└── custom.nix                   # Custom packages from /pkgs/
```

---

## Summary: Who Includes What?

| Profile | Includes |
| ------- | -------- |
| **base/minimal** | CLI essentials, network tools, btop, SSH |
| **base/git** | Git with sops hooks (optional, import in host config) |
| **base/secrets** | Sops CLI utilities (optional, import in host config) |
| **features/development** | minimal + shells + basic Git + all dev tools |
| **features/desktop** | development + GUI apps |
| **features/kubernetes** | Standalone K8s module |
| **platform/darwin** | desktop + macOS packages + aerospace |
| **platform/nixos** | desktop + Linux packages + XDG |
| **hosts/mbp** | darwin + kubernetes + sops (optional) |
| **hosts/desktop** | nixos |

### Git Configuration Options

Basic Git is now the default in `features/development.nix`. For sops integration, add imports in your host config:

| Option | Where to Import | Features | Use Case |
| ------ | --------------- | -------- | -------- |
| **Basic** (default) | Included in development.nix | Basic Git, no sops | Works out of the box |
| **Sops** (optional) | Host config (e.g., hosts/mbp/home.nix) | Git with sops hooks | Encrypted credentials |

---

## Benefits of This Structure

1. **Modular**: Each profile has a clear, single responsibility
2. **Works Out of the Box**: Basic Git by default, no sops setup required
3. **Optional Sops**: Add sops in host config when ready
4. **No Duplication**: Each module imported exactly once
5. **Platform-Specific**: Clear separation of Darwin vs NixOS
6. **Feature-Rich**: Desktop inherits all development tools
7. **Discoverable**: Easy to find what you need by category
8. **Flexible**: Mix and match features (e.g., add kubernetes separately)
