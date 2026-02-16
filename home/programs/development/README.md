# Development Programs Configuration

This directory contains enhanced Nix configurations for development tools and environments, designed for maximum productivity and reliability.

## Overview

The development configuration is organized into focused modules:

- **`direnv/`** - Direnv configuration with custom layout helpers (use_flake provided by nix-direnv)
- **`git/`** - Basic Git configuration (no sops dependency)

SOPS-enhanced Git (hooks, GPG, aliases) is in `home/profiles/features/sops.nix`, gated by `profiles.sops.enable`.

## Directory Structure

```
development/
├── README.md           # This documentation
├── default.nix        # Main module imports (direnv only)
├── direnv/
│   └── default.nix    # Enhanced direnv with smart caching
└── git/
    └── default.nix    # Basic git configuration (no sops dependency)
```

## Key Features

### Direnv Configuration

- **nix-direnv integration**: `use_flake` is provided by nix-direnv (GC roots, profile caching, fallback on failure)
- **Custom layout helpers**: Support for Python (Poetry), Node.js, Rust, and Go
- **Auto-detect hook**: A zsh chpwd hook detects project markers and offers to create `.envrc` + cached `flake.nix`

#### Available Layouts

```bash
# In your .envrc file:
use flake                    # Flake environment (provided by nix-direnv)
use flake /path/to/flake     # Remote flake reference (e.g. cache dir)
layout poetry               # Python Poetry projects
layout node                 # Node.js projects (auto-detects package manager)
layout rust                 # Rust projects with isolated target directory
layout go                   # Go projects with isolated GOPATH
```

### Git Configuration

Two git configurations are available:

**`git/default.nix`** - Basic git (default, no sops dependency):

- Standard git configuration with difftool/mergetool
- GPG integration for commit signing
- Works out of the box for new users

**`home/profiles/features/sops.nix`** - Git with sops integration (optional):

- Secret Management: User credentials managed via sops
- Enhanced Hooks: post-checkout and post-merge hooks for sops secrets
- Error Handling: Comprehensive validation and fallback mechanisms

To enable sops integration, set `profiles.sops.enable = true` in your host config.


## Usage Examples

### Setting up a Python Project

1. Create `.envrc` in your project:
   ```bash
   layout poetry
   ```

2. Initialize Poetry project:
   ```bash
   poetry init
   poetry add requests
   ```

3. The environment will automatically activate when you enter the directory

### Setting up a Node.js Project

1. Create `.envrc`:
   ```bash
   layout node
   ```

2. The layout will auto-detect your package manager (npm, yarn, pnpm, bun)


## Configuration

### Direnv Settings

The direnv configuration includes optimized settings in `~/.config/direnv/direnv.toml`:

- `warn_timeout = "10s"` - Increased timeout for complex environments
- `strict_env = true` - More secure environment handling
- `load_dotenv = false` - Opt-in via explicit `dotenv` in .envrc

### Git Hooks (SOPS mode only)

When `profiles.sops.enable = true`, git hooks are installed via the git template system:

- **post-checkout**: Updates git config from sops secrets
- **post-merge**: Refreshes git config after merges

## Troubleshooting

### Direnv Issues

If direnv environments fail to load:

1. Run `nix-direnv-reload` from the project directory to force a cache rebuild
2. Verify flake.nix syntax: `nix flake check`
3. Clear the direnv layout dir: `rm -rf "$(direnv_layout_dir)"` and re-enter the directory

### Git Hook Issues (SOPS mode)

If git hooks fail:

1. Check sops secrets exist: `ls ~/.config/git/`
2. Verify age key: `ls ~/.config/sops/age/keys.txt`
3. Test sops decryption: `sops -d secrets/secrets.yaml`

## Related Documentation

- [direnv Documentation](https://direnv.net/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [sops-nix](https://github.com/Mic92/sops-nix)
- [Kubernetes Tools](../../../pkgs/collections/kubernetes-tools.nix)
