# Home Manager Profiles

This directory organizes Home Manager modules by role instead of by history.

## Structure

```text
profiles/
|-- layers/
|   |-- foundation.nix      # always-on cross-platform base
|   `-- development.nix     # main development stack
|-- capabilities/
|   |-- agent-dev.nix       # optional AI agent development workflow
|   |-- kubernetes.nix      # optional Kubernetes tooling
|   |-- redis.nix           # optional local Redis user service
|   `-- sops.nix            # optional encrypted secrets integration
`-- platforms/
    |-- darwin.nix          # macOS composition
    `-- nixos.nix           # NixOS composition
```

## Taxonomy

- `layers/`: broad opinionated stacks that compose behavior, defaults, and program modules
- `capabilities/`: optional add-ons that can be imported independently for behavior, services, and secrets
- `platforms/`: OS-specific entry points that compose layers plus platform extras
- `home/packages/*`: plain package bundles imported directly from hosts/templates

## Hierarchy

```text
layers/foundation.nix
  ->
layers/development.nix
  ->
platforms/darwin.nix or platforms/nixos.nix
  ->
hosts/*/home.nix imports package bundles directly
```

Optional capability modules can be imported directly by hosts:

- `capabilities/agent-dev.nix`
- `capabilities/kubernetes.nix`
- `capabilities/redis.nix`
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

Provides:

- Editors, shells, terminals, direnv, git, utilities
- Behavior and program composition for the development workspace
- No package bundle selection interface; package bundles are imported directly by hosts/templates

Feature flags:

- `profiles.development.enable`
- `profiles.development.editors.*`
- `profiles.development.shells.enable`
- `profiles.development.utilities.enable`
- `profiles.development.terminals.enable`
- `profiles.development.terminals.default`

### `capabilities/agent-dev.nix`

Provides optional AI agent workflow tooling controlled by:

- `profiles.agentDev.enable`
- `profiles.agentDev.defaultBaseRef`
- `profiles.agentDev.hermes.enable`

### `capabilities/kubernetes.nix`

Provides optional Kubernetes tooling controlled by:

- `profiles.kubernetes.enable`
- `profiles.kubernetes.includeLocalDev`
- `profiles.kubernetes.toolSet`

### `capabilities/redis.nix`

Provides an optional local Redis user service controlled by:

- `profiles.redis.enable`
- `profiles.redis.port`
- `profiles.redis.bind`
- `profiles.redis.databases`

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

macOS host with full development package bundles plus optional SOPS and Kubernetes:

```nix
{
  imports = [
    ../../home/profiles/platforms/darwin.nix
    ../../home/packages/development
    ../../home/profiles/capabilities/kubernetes.nix
    ../../home/profiles/capabilities/sops.nix
  ];
}
```

NixOS host with selected package bundles:

```nix
{
  imports = [
    ../../home/profiles/platforms/nixos.nix
    ../../home/packages/development/build.nix
    ../../home/packages/development/languages.nix
  ];
}
```

Capability modules remain profile-based. Keep importing capability profiles such as Kubernetes, SOPS, Redis, and agent development when you want their behavior or services.
