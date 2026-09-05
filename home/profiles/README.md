# Home Manager Profiles

This directory organizes Home Manager modules by role instead of by history. Hosts combine a platform profile with the central program module from `home/programs/default.nix` and optional capabilities.

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

- `layers/`: broad opinionated stacks that compose behavior, defaults, and package bundles
- `capabilities/`: import-only add-ons for behavior, services, and secrets
- `platforms/`: OS-specific entry points that compose layers plus platform extras
- `home/packages/*`: plain package bundles composed by profile layers
- `home/programs/*`: the root selects categories; category `default.nix` files select individual program modules

## Hierarchy

```text
layers/foundation.nix
  ->
layers/development.nix
  ->
platforms/darwin.nix or platforms/nixos.nix
  ->
hosts/*/home.nix imports home/programs/default.nix and optional capabilities
```

Optional capability modules can be imported directly by hosts:

- `capabilities/agent-dev.nix`
- `capabilities/kubernetes.nix`
- `capabilities/redis.nix`
- `capabilities/sops.nix`

## Profile Composition

### `layers/foundation.nix`

Composes:

- `../../packages/core/cli.nix`
- `../../packages/core/networking.nix`

Provides:

- Core CLI tools like `bat`, `eza`, `fd`, `ripgrep`, `jq`, `tree`, `zoxide`
- Archive and utility tools like `zip`, `unzip`, `gzip`, `fastfetch`, `htop`
- Networking baseline like `wget`, `cachix`

### `layers/development.nix`

Composes:

- `./foundation.nix`
- `../../packages/development`

Provides:

- Shared development workspace defaults
- The actual editor, shell, terminal, git, and utility modules come from imports in `home/programs/default.nix`

### `capabilities/agent-dev.nix`

Provides AI agent workflow tooling when imported:

- `agent-guard`
- `agent-eval-host`

### `capabilities/kubernetes.nix`

Provides Kubernetes tooling when imported.

The only capability profile option is:

- `profiles.kubernetes.toolSet`

### `capabilities/redis.nix`

Provides a local Redis user service when imported.

### `capabilities/sops.nix`

Provides encrypted secrets integration when imported. The git signing key secret is selected by host convention: `git-signingKey-${hostName}`. This module declares only the git secrets its hooks require; host-specific secrets are declared in `hosts/<host>/sops.nix`.

### `platforms/darwin.nix`

Composes:

- `../layers/development.nix`
- `../../packages/platform/darwin.nix`

### `platforms/nixos.nix`

Composes:

- `../layers/development.nix`
- `../../packages/platform/nixos.nix`

## Host Usage

Hosts import one platform profile and `home/programs/default.nix`, then add optional capabilities.

macOS host with the development layer plus optional SOPS and Kubernetes:

```nix
{
  imports = [
    ../../home/profiles/platforms/darwin.nix
    ../../home/programs
    ../../home/profiles/capabilities/kubernetes.nix
    ./sops.nix
  ];
}
```

NixOS host with the shared development layer:

```nix
{
  imports = [
    ../../home/profiles/platforms/nixos.nix
    ../../home/programs
  ];
}
```

Capability modules are import-only. Import Kubernetes, Redis, SOPS, or agent development when you want their behavior or services. Remove the import when you want that capability disabled. SOPS host wrappers live in host-local `sops.nix` files so a host can opt into encrypted secrets with one import.
