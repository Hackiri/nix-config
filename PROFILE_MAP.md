# Profile Import Map

This file is the short reference for the current profile taxonomy and import flow.

## Overview

```text
hosts/*/home.nix
|-- platforms/darwin.nix or platforms/nixos.nix
|-- optional: home/packages/development or individual bundle modules
|-- select one: programRegistry.suites.workstation.darwin or programRegistry.suites.workstation.nixos
|-- optional: capabilities/kubernetes.nix
|-- optional: capabilities/redis.nix
|-- optional: capabilities/agent-dev.nix
`-- optional: capabilities/sops.nix
```

## Layer Flow

```text
layers/foundation.nix
  |-- packages/core/cli.nix
  |-- packages/core/networking.nix
  `-- core package bundles selected by the layer

layers/development.nix
  |-- layers/foundation.nix
  `-- development behavior, defaults, and package composition

hosts/*/home.nix
  |-- packages/development/default.nix or individual bundles
  |   |-- build.nix
  |   |-- quality.nix
  |   |-- databases.nix
  |   |-- languages.nix
  |   |-- security.nix
  |   `-- web.nix
  `-- one static program suite from home/programs/default.nix

platforms/darwin.nix
  |-- layers/development.nix
  `-- packages/platform/darwin.nix

platforms/nixos.nix
  |-- layers/development.nix
  `-- packages/platform/nixos.nix
```

## Optional Capabilities

```text
capabilities/kubernetes.nix
  |-- pkgs/kubernetes-tools.nix
  |-- k9s config files
  `-- shell completion/aliases

capabilities/sops.nix
  |-- secrets/secrets.yaml
  |-- git hooks
  |-- gpg/git signing config
  `-- shell aliases
```

## Host Examples

`hosts/mbp/home.nix` and `hosts/mbp2/home.nix` currently compose:

- `../../home/profiles/platforms/darwin.nix`
- `../../home/packages/development`
- `../../home/profiles/capabilities/kubernetes.nix`
- `../../home/profiles/capabilities/redis.nix`
- `../../home/profiles/capabilities/agent-dev.nix`
- `../../home/profiles/capabilities/sops.nix`
- `programRegistry.suites.workstation.darwin`

## Naming Rules

- `layers/*` means broad stack composition
- `capabilities/*` means optional add-on behavior, services, or secrets
- `platforms/*` means OS-specific composition
- `packages/core/*` means always-useful baseline packages
- `packages/development/*` means dev package bundles selected by hosts
- `programRegistry.suites/*` means static program suites selected by hosts
- `packages/platform/*` means OS-specific package bundles
