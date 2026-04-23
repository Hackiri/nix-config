# Home Manager Profiles

This directory organizes Home Manager modules by role instead of by history.

## Structure

```text
profiles/
├── layers/
│   ├── foundation.nix      # always-on cross-platform base
│   └── development.nix     # main development stack
├── capabilities/
│   ├── kubernetes.nix      # optional Kubernetes tooling
│   └── sops.nix            # optional encrypted secrets integration
└── platforms/
    ├── darwin.nix          # macOS composition
    └── nixos.nix           # NixOS composition
```

## Taxonomy

- `layers/`: broad opinionated stacks that compose packages and programs
- `capabilities/`: optional add-ons that can be imported independently
- `platforms/`: OS-specific entry points that compose layers plus platform extras

## Hierarchy

```text
layers/foundation.nix
  ↓
layers/development.nix
  ↓
platforms/darwin.nix or platforms/nixos.nix
```

Optional capability modules can be imported directly by hosts:

- `capabilities/kubernetes.nix`
- `capabilities/sops.nix`

## Current Package Coverage

### `layers/foundation.nix`

Imports:

- `../../packages/core/cli.nix`
- `../../packages/core/networking.nix`
- `../../programs/security`
- `../../programs/utilities/btop`

Provides:

- Core CLI tools like `bat`, `eza`, `fd`, `ripgrep`, `jq`, `tree`, `zoxide`
- Archive and utility tools like `zip`, `unzip`, `gzip`, `fastfetch`, `htop`
- Networking baseline like `wget`, `cachix`

### `layers/development.nix`

Imports:

- `./foundation.nix`
- `../../programs/shells`
- `../../programs/development`
- `../../programs/editors`
- `../../programs/terminals`
- `../../programs/utilities`
- `../../packages/development`

Provides:

- Editors, shells, terminals, direnv, git, utilities
- Development package groups: build, quality, databases, languages, security, web

Feature flags:

- `profiles.development.enable`
- `profiles.development.editors.*`
- `profiles.development.shells.enable`
- `profiles.development.utilities.enable`
- `profiles.development.terminals.enable`
- `profiles.development.terminals.default`
- `profiles.development.packages.*`

### `capabilities/kubernetes.nix`

Provides optional Kubernetes tooling controlled by:

- `profiles.kubernetes.enable`
- `profiles.kubernetes.includeLocalDev`
- `profiles.kubernetes.toolSet`

### `capabilities/sops.nix`

Provides optional secrets integration controlled by:

- `profiles.sops.enable`
- `profiles.sops.signingKeySecret`
- `profiles.sops.extraSecrets`

### `platforms/darwin.nix`

Composes:

- `../layers/development.nix`
- `../../packages/platform/darwin.nix`
- `../../programs/utilities/aerospace`

### `platforms/nixos.nix`

Composes:

- `../layers/development.nix`
- `../../packages/platform/nixos.nix`

## Host Usage

macOS host with optional SOPS and Kubernetes:

```nix
{
  imports = [
    ../../home/profiles/platforms/darwin.nix
    ../../home/profiles/capabilities/kubernetes.nix
    ../../home/profiles/capabilities/sops.nix
  ];
}
```

NixOS host:

```nix
{
  imports = [
    ../../home/profiles/platforms/nixos.nix
  ];
}
```
