# Development Programs Configuration

This directory contains enhanced Nix configurations for development tools and environments, designed for maximum productivity and reliability.

## Overview

The development configuration is organized into focused modules:

- **`direnv/`** - Enhanced direnv configuration with intelligent caching and multi-language support
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

### Enhanced direnv Configuration

- **Smart Caching**: Flake environments are cached with hash-based invalidation
- **Multi-Language Layouts**: Support for Python (Poetry), Node.js, Rust, and Go
- **Robust Error Handling**: Comprehensive validation and error reporting
- **Performance Optimized**: Faster subsequent loads with intelligent caching

#### Available Layouts

```bash
# In your .envrc file:
use flake                    # Standard flake environment
use flake --impure          # Impure flake environment
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
- `strict_env = true` - Enhanced security
- `load_dotenv = true` - Automatic .env file loading

### Git Hooks (SOPS mode only)

When `profiles.sops.enable = true`, git hooks are installed via the git template system:

- **post-checkout**: Updates git config from sops secrets
- **post-merge**: Refreshes git config after merges

## Troubleshooting

### Direnv Issues

If direnv environments fail to load:

1. Check the build log: `~/.cache/direnv/layouts/<project>/build.log`
2. Verify flake.nix syntax: `nix flake check`
3. Clear cache: `rm -rf ~/.cache/direnv/layouts/<project>`

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
