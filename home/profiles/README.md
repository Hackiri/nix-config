# Home Manager Profiles

This directory organizes Home Manager modules by role instead of by history. Hosts combine these profiles with package bundles and a static program suite from `home/programs/default.nix`.

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
- `capabilities/`: optional add-ons that can be imported independently for behavior, services, and secrets
- `platforms/`: OS-specific entry points that compose layers plus platform extras
- `home/packages/*`: plain package bundles imported directly from hosts/templates
- `home/programs/*`: static program suites selected by hosts, not imported by profiles

## Hierarchy

```text
layers/foundation.nix
  ->
layers/development.nix
  ->
platforms/darwin.nix or platforms/nixos.nix
  ->
hosts/*/home.nix imports package bundles and selects one program suite
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

Provides:

- Behavior, defaults, and feature flags for the development workspace
- The actual editor, shell, terminal, git, and utility modules come from the host-selected suite in `home/programs/default.nix`

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

### `platforms/nixos.nix`

Composes:

- `../layers/development.nix`
- `../../packages/platform/nixos.nix`

## Host Usage

Hosts select a program suite from `home/programs/default.nix` and compose it with profile and package imports.

macOS host with full development package bundles plus optional SOPS and Kubernetes:

```nix
let
  programRegistry = import ../../home/programs;
in {
  imports = [
    ../../home/profiles/platforms/darwin.nix
    ../../home/packages/development
    ../../home/profiles/capabilities/kubernetes.nix
    ../../home/profiles/capabilities/sops.nix
  ] ++ programRegistry.suites.workstation.darwin;
}
```

NixOS host with selected package bundles:

```nix
let
  programRegistry = import ../../home/programs;
in {
  imports = [
    ../../home/profiles/platforms/nixos.nix
    ../../home/packages/development/build.nix
    ../../home/packages/development/languages.nix
  ] ++ programRegistry.suites.workstation.nixos;
}
```

Capability modules remain profile-based. Keep importing capability profiles such as Kubernetes, SOPS, Redis, and agent development when you want their behavior or services.
