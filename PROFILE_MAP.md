# Profile Import Map

This file is the short reference for the current profile taxonomy and import flow.

## Overview

```text
hosts/*/home.nix
├── platforms/darwin.nix or platforms/nixos.nix
├── optional: capabilities/kubernetes.nix
└── optional: capabilities/sops.nix
```

## Layer Flow

```text
layers/foundation.nix
  ├── packages/core/cli.nix
  ├── packages/core/networking.nix
  ├── programs/security
  └── programs/utilities/btop

layers/development.nix
  ├── layers/foundation.nix
  ├── programs/shells
  ├── programs/development
  ├── programs/editors
  ├── programs/terminals
  ├── programs/utilities
  └── packages/development/default.nix
       ├── build.nix
       ├── quality.nix
       ├── databases.nix
       ├── languages.nix
       ├── security.nix
       └── web.nix

platforms/darwin.nix
  ├── layers/development.nix
  ├── packages/platform/darwin.nix
  └── programs/utilities/aerospace

platforms/nixos.nix
  ├── layers/development.nix
  └── packages/platform/nixos.nix
```

## Optional Capabilities

```text
capabilities/kubernetes.nix
  ├── pkgs/kubernetes-tools.nix
  ├── k9s config files
  └── shell completion/aliases

capabilities/sops.nix
  ├── secrets/secrets.yaml
  ├── git hooks
  ├── gpg/git signing config
  └── shell aliases
```

## Host Examples

`hosts/mbp/home.nix` and `hosts/mbp2/home.nix` currently import:

- `../../home/profiles/platforms/darwin.nix`
- `../../home/profiles/capabilities/kubernetes.nix`
- `../../home/profiles/capabilities/sops.nix`

## Naming Rules

- `layers/*` means broad stack composition
- `capabilities/*` means optional add-on behavior
- `platforms/*` means OS-specific composition
- `packages/core/*` means always-useful baseline packages
- `packages/development/*` means dev package bundles
- `packages/platform/*` means OS-specific package bundles
