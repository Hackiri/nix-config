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
│    Optional: + features/sops.nix (profiles.sops.enable = true)     │
│    Optional: + features/kubernetes.nix (profiles.kubernetes.enable) │
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
│   ├── programs/terminals/             # Tmux, Alacritty, etc.
│   └── programs/utilities/             # Btop, claude, yazi
│
└── Packages:
    ├── packages/build-tools.nix        # Make, cmake, gcc, etc.
    ├── packages/code-quality.nix       # Linters, formatters
    ├── packages/databases.nix          # DB clients, Redis, etc.
    ├── packages/languages.nix          # Python, Node, Go, Rust, etc.
    ├── packages/security.nix           # Security utilities
    ├── packages/terminals.nix          # Terminal utilities
    └── packages/web-dev.nix            # Web development tools
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
  └─→ features/sops.nix (profiles.sops.enable = true)
      Provides: git hooks, gpg, sops aliases, launchd fix
```

#### `features/desktop.nix`

**Purpose**: GUI applications and desktop environment

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

#### `features/sops.nix` (Standalone)

**Purpose**: SOPS encrypted secrets management (optional add-on)

```text
features/sops.nix
├── Options:
│   └── profiles.sops.enable
│
└── Provides (when enabled):
    ├── sops-nix secrets (git-userName, git-userEmail, git-signingKey)
    ├── Git post-checkout/post-merge hooks
    ├── GPG configuration
    ├── Shell aliases (sops-edit, sops-encrypt, sops-decrypt)
    └── launchd service PATH fix (Darwin)
```

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
└── Programs:
    └── programs/utilities/aerospace/   # macOS window manager
```

**Full Import Chain**:
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
  └─→ features/sops.nix (profiles.sops.enable = true)
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

---

## Host Configurations

### `hosts/mbp/home.nix` (macOS Laptop)

```text
hosts/mbp/home.nix
├── platform/darwin.nix                 # Full macOS stack
├── features/kubernetes.nix             # Additional K8s tools
├── features/sops.nix                   # SOPS secrets (profiles.sops.enable = true)
└── Configuration:
    ├── profiles.kubernetes.enable = true
    └── profiles.sops.enable = true
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
  └─→ features/sops.nix                 # SOPS secrets (gated by profiles.sops.enable)
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
│   ├── default.nix              → Aggregator: direnv
│   ├── git/
│   │   └── default.nix          → Basic Git config (no sops)
│   └── direnv/
│
├── editors/
│   ├── default.nix              → All editor configs
│   ├── neovim/
│   ├── emacs/
│   └── neovide/                 → Gated by profiles.neovide.enable
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
    ├── default.nix              → btop + claude + yazi
    ├── btop/
    ├── claude/
    ├── yazi/
    └── aerospace/               → macOS window manager (imported by platform/darwin.nix)
```

### Key Points

1. **`programs/utilities/default.nix`** imports btop, claude, yazi
2. **`programs/development/default.nix`** imports direnv only
3. **Git configuration**:
   - **Default**: `programs/development/git/default.nix` (basic Git, no sops)
   - **SOPS-enhanced**: `features/sops.nix` (gated by `profiles.sops.enable`)

This ensures:

- **Works out of the box**: New users get basic Git without needing sops setup
- **No conflicts**: Basic git and sops git config merge cleanly via home-manager
- **Truly optional**: SOPS can be toggled with a single boolean

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
└── web-dev.nix                  # Web development tools
```

---

## Summary: Who Includes What?

| Profile | Includes |
| ------- | -------- |
| **base/minimal** | CLI essentials, network tools, btop, SSH |
| **features/development** | minimal + shells + basic Git + all dev tools |
| **features/desktop** | development + GUI apps + neovide |
| **features/kubernetes** | Standalone K8s module (profiles.kubernetes.enable) |
| **features/sops** | SOPS secrets, git hooks, GPG, aliases (profiles.sops.enable) |
| **platform/darwin** | desktop + macOS packages + aerospace |
| **platform/nixos** | desktop + Linux packages + XDG |
| **hosts/mbp** | darwin + kubernetes + sops |
| **hosts/desktop** | nixos |

### Git Configuration Options

Basic Git is the default in `features/development.nix`. SOPS integration is gated by `profiles.sops.enable`:

| Option | How to Enable | Features | Use Case |
| ------ | ------------- | -------- | -------- |
| **Basic** (default) | Included in development.nix | Basic Git, no sops | Works out of the box |
| **SOPS** (optional) | `profiles.sops.enable = true` | Git with sops hooks, GPG, aliases | Encrypted credentials |

---

## Option Namespaces

All home-manager feature flags use the `profiles.*` namespace:

| Option | File | Purpose |
| ------ | ---- | ------- |
| `profiles.kubernetes.enable` | `features/kubernetes.nix` | Kubernetes tooling |
| `profiles.sops.enable` | `features/sops.nix` | SOPS encrypted secrets |
| `profiles.neovide.enable` | `programs/editors/neovide/default.nix` | Neovide GUI editor |

System-level options use separate namespaces:

| Option | File | Purpose |
| ------ | ---- | ------- |
| `features.fonts.enable` | `modules/optional-features/fonts.nix` | System fonts |
| `services.homebrew.enable` | `modules/services/homebrew.nix` | Homebrew integration |

---

## Benefits of This Structure

1. **Modular**: Each profile has a clear, single responsibility
2. **Works Out of the Box**: Basic Git by default, no sops setup required
3. **Optional SOPS**: Toggle with `profiles.sops.enable = true` when ready
4. **No Duplication**: Each module imported exactly once
5. **Platform-Specific**: Clear separation of Darwin vs NixOS
6. **Feature-Rich**: Desktop inherits all development tools
7. **Discoverable**: Easy to find what you need by category
8. **Flexible**: Mix and match features (e.g., add kubernetes separately)
