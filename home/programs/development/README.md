# Development Programs Configuration

This directory contains enhanced Nix configurations for development tools and environments, designed for maximum productivity and reliability.

## 🚀 Overview

The development configuration is organized into focused modules:

- **`direnv/`** - Enhanced direnv configuration with intelligent caching and multi-language support
- **`git/`** - Robust git configuration with sops-managed secrets and enhanced hooks
- **`kube/`** - Comprehensive Kubernetes tooling and configuration

## 📁 Directory Structure

```
development/
├── README.md           # This documentation
├── default.nix        # Main module imports
├── direnv/
│   └── default.nix    # Enhanced direnv with smart caching
├── git/
│   └── git-hooks.nix  # Git hooks with error handling
└── kube/
    ├── kube.nix       # Kubernetes program enablement
    └── kube-config.nix # K8s tools and shell integration
```

## ✨ Key Features

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

### Git Configuration with Sops Integration

- **Secret Management**: User credentials managed via sops
- **Enhanced Hooks**: Robust pre-commit, post-checkout, and post-merge hooks
- **Error Handling**: Comprehensive validation and fallback mechanisms
- **GPG Integration**: Automatic commit and tag signing

### Kubernetes Tooling

- **Comprehensive Toolset**: 40+ Kubernetes and cloud-native tools
- **Organized Categories**: Tools grouped by function (core, security, observability, etc.)
- **Shell Integration**: Enhanced completions and aliases
- **k9s Configuration**: Pre-configured with optimized settings and themes

## 🛠️ Usage Examples

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

### Using Kubernetes Tools

All tools are available in your shell with enhanced features:

```bash
# Colorized kubectl output
kubectl get pods

# Fast context switching
kubectx production
kubens monitoring

# Multi-pod log tailing
stern app-name

# Terminal Kubernetes dashboard
k9s
```

## 🔧 Configuration

### Direnv Settings

The direnv configuration includes optimized settings in `~/.config/direnv/direnv.toml`:

- `warn_timeout = "10s"` - Increased timeout for complex environments
- `strict_env = true` - Enhanced security
- `load_dotenv = true` - Automatic .env file loading

### Git Hooks

Git hooks are automatically installed via the git template system:

- **pre-commit**: Runs pre-commit hooks with timeout protection
- **post-checkout**: Updates git config from sops secrets
- **post-merge**: Refreshes git config after merges

### Kubernetes Shell Integration

Enhanced shell completions and aliases are automatically configured:

```bash
# Kubecolor integration
alias kubectl="kubecolor"

# Helm completions
source <(helm completion zsh)

# Additional kubectl aliases (via oh-my-zsh kubectl plugin)
k get pods    # kubectl get pods
kgp          # kubectl get pods
kdp          # kubectl describe pods
```

## 🚨 Troubleshooting

### Direnv Issues

If direnv environments fail to load:

1. Check the build log: `~/.cache/direnv/layouts/<project>/build.log`
2. Verify flake.nix syntax: `nix flake check`
3. Clear cache: `rm -rf ~/.cache/direnv/layouts/<project>`

### Git Hook Issues

If git hooks fail:

1. Check sops secrets exist: `ls ~/.config/git/`
2. Verify age key: `ls ~/.config/sops/age/keys.txt`
3. Test sops decryption: `sops -d secrets/secrets.yaml`

### Kubernetes Tools

If kubectl completions don't work:

1. Verify oh-my-zsh kubectl plugin is enabled
2. Check kubecolor installation: `which kubecolor`
3. Reload shell configuration: `source ~/.zshrc`

## 🔄 Updates and Maintenance

### Updating Direnv Layouts

When you modify direnv layouts, existing projects will automatically detect changes and rebuild their environments on next access.

### Refreshing Git Configuration

Git configuration is automatically refreshed on checkout and merge. To manually refresh:

```bash
git config --get user.name   # Should show your configured name
```

### Kubernetes Tools Updates

Tools are updated with your Nix configuration. To see available tools:

```bash
# List all kubernetes tools
nix-env -qaP -A nixpkgs.kubernetes-tools

# Check installed versions
kubectl version --client
helm version --client
```

## 📚 Related Documentation

- [direnv Documentation](https://direnv.net/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [sops-nix](https://github.com/Mic92/sops-nix)
- [Kubernetes Tools](../../../pkgs/kubernetes-tools.nix)
- [Development Tools](../../../pkgs/dev-tools.nix)

## 🤝 Contributing

When adding new development tools or configurations:

1. Follow the existing modular structure
2. Add comprehensive error handling
3. Include documentation and examples
4. Test with multiple project types
5. Consider performance implications

---

*This configuration is designed to provide a robust, efficient, and user-friendly development environment while maintaining the flexibility and reproducibility that Nix provides.*
