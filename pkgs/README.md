# Custom Packages Collection

This directory contains custom Nix packages and tools designed to enhance development workflows and system administration tasks.

## 🎯 Overview

The packages are organized into focused, reusable modules that can be used independently or combined for comprehensive development environments.

## 📦 Available Packages

### Core Development Tools

#### `dev-tools.nix` - Intelligent Development Assistant
A comprehensive, language-aware development tool that automatically detects project types and provides contextual commands.

**Features:**
- **Smart Project Detection**: Automatically identifies Python, JavaScript/TypeScript, Rust, Go, Lua, Nix, and shell projects
- **Contextual Commands**: Adapts behavior based on detected languages and frameworks
- **Modular Architecture**: Organized tool categories for maintainability
- **Enhanced Output**: Colorized logging with clear status indicators

**Usage:**
```bash
# Get help (shows detected project types)
dev-tools help

# Auto-format code (detects languages)
dev-tools format

# Smart linting (language-aware)
dev-tools lint

# Clean artifacts (project-specific)
dev-tools clean

# Project information
dev-tools info

# Web server with auto-detection
dev-tools web-serve 8080

# Image optimization
dev-tools optimize
```

**Tool Categories:**
- **Formatters**: black, prettier, rustfmt, gofmt, stylua, alejandra, shfmt
- **Linters**: ruff, eslint, clippy, golangci-lint, statix, shellcheck, stylelint
- **Web Tools**: Python HTTP server, Caddy, live-server
- **Media Tools**: imagemagick, optipng, jpegoptim, WebP conversion

#### `kubernetes-tools.nix` - Comprehensive K8s Ecosystem
A curated collection of Kubernetes and cloud-native tools organized by function.

**Tool Categories:**
- **Core**: kubectl, helm, kustomize
- **Context Management**: kubectx, kubecolor
- **Observability**: stern, k9s, popeye, kubectl-tree
- **Security**: kube-bench, kube-hunter, kubesec
- **GitOps**: argocd, flux, skaffold, tektoncd-cli
- **Service Mesh**: istioctl, linkerd, cilium-cli
- **Local Development**: kind, minikube, k3d, tilt
- **Container Tools**: docker, podman, buildah, skopeo, dive, crane
- **Infrastructure as Code**: terraform, terragrunt, pulumi, ansible
- **Cloud CLIs**: awscli2, google-cloud-sdk, azure-cli

**Predefined Tool Sets:**
```nix
# Access specific tool sets
kubernetesTools.sets.minimal      # Basic K8s operations
kubernetesTools.sets.developer    # Local development
kubernetesTools.sets.operations   # Cluster management
kubernetesTools.sets.devops       # CI/CD and GitOps
kubernetesTools.sets.security-focused  # Security tools
kubernetesTools.sets.complete     # Everything
```

#### `devshell/` - Enhanced Development Environments
Configurable development shells with language-specific tooling and optimizations.

**Features:**
- **Language-Specific Environments**: Python, Rust, Go, Node.js, Lua, Nix
- **Enhanced Tooling**: Language servers, formatters, linters, and development utilities
- **Modular Design**: Mix and match language environments
- **Shell Integration**: Works with bash, zsh, and fish

**Configuration:**
```nix
# In devshell/config.nix
{
  programs.devshell = {
    enable = true;
    features = {
      python = true;
      rust = true;
      go = true;
      node = true;
      lua = false;  # Optional languages
      nix = true;   # Enabled by default
    };
  };
}
```

**Language Environments:**
- **Python**: python3, pip, poetry, black, ruff, mypy, pytest, python-lsp-server
- **Rust**: rustc, cargo, clippy, rust-analyzer, cargo-watch, cargo-edit
- **Go**: go, gopls, golangci-lint, delve, go-tools
- **Node.js**: nodejs, npm, yarn, pnpm, typescript, prettier, eslint
- **Lua**: lua, luarocks, lua-language-server, stylua
- **Nix**: nil, alejandra, statix, deadnix, nix-tree

## 🚀 Usage

### Using Individual Packages

```nix
# In your configuration
{
  home.packages = with pkgs; [
    (import ./path/to/nix-config/pkgs/dev-tools.nix { inherit pkgs; })
  ];
}
```

### Using the Package Collection

```nix
# Import the entire collection
let
  customPkgs = import ./path/to/nix-config/pkgs { inherit pkgs; };
in {
  home.packages = with customPkgs; [
    dev-tools
    kubernetes-tools
    devshell.script
  ];
}
```

### Language-Specific Development Environments

```nix
# Python development environment
let
  customPkgs = import ./path/to/nix-config/pkgs { inherit pkgs; };
in {
  home.packages = [ customPkgs.devshell.environments.python ];
}
```

## 🔧 Configuration Examples

### Custom Development Workflow

```bash
# 1. Enter a project directory
cd my-python-project

# 2. Check project info
dev-tools info
# Output: Detected Python, Poetry project

# 3. Format and lint
dev-tools fix

# 4. Start development server
dev-tools web-serve 3000

# 5. Clean up when done
dev-tools clean
```

### Kubernetes Development Setup

```nix
# Add to your home-manager configuration
{
  home.packages = with (import ./pkgs { inherit pkgs; }); [
    # Get the developer-focused K8s tools
    (pkgs.buildEnv {
      name = "k8s-dev-tools";
      paths = kubernetes-tools.sets.developer;
    })
  ];
}
```

## 🏗️ Architecture

### Package Organization

```
pkgs/
├── README.md              # This documentation
├── default.nix           # Package collection exports
├── dev-tools.nix         # Smart development assistant
├── kubernetes-tools.nix  # K8s ecosystem tools
├── devshell/             # Development environments
│   ├── default.nix       # Environment builder
│   ├── config.nix        # Feature configuration
│   └── devshell.sh       # Shell script
└── scripts/              # Additional utility scripts
    └── default.nix       # Script collection
```

### Design Principles

1. **Modularity**: Each package is self-contained and reusable
2. **Composability**: Packages can be combined for complex workflows
3. **Intelligence**: Tools adapt to project context automatically
4. **Performance**: Optimized for fast loading and execution
5. **Maintainability**: Clear organization and comprehensive documentation

## 🔍 Advanced Features

### Smart Project Detection

The `dev-tools` package uses sophisticated project detection:

```bash
# Detects based on files present
*.py + pyproject.toml → Python + Poetry
*.js + package.json → JavaScript + Node.js
*.rs + Cargo.toml → Rust + Cargo
*.go + go.mod → Go + Go modules
flake.nix → Nix flake project
```

### Kubernetes Tool Categories

Tools are organized for easy selection:

```nix
# Access specific categories
kubernetesTools.core           # Essential tools
kubernetesTools.security       # Security-focused tools
kubernetesTools.observability  # Monitoring and debugging
kubernetesTools.gitops         # GitOps and CI/CD
kubernetesTools.localDev       # Local development tools
```

### Development Environment Customization

```nix
# Create custom environment combinations
let
  customPkgs = import ./pkgs { inherit pkgs; };
  myDevEnv = pkgs.buildEnv {
    name = "my-dev-environment";
    paths = with customPkgs.devshell; [
      # Core tools always included
      (builtins.head (builtins.attrValues environments))
    ] ++ [
      # Add custom tools
      pkgs.docker
      pkgs.postgresql
    ];
  };
in {
  home.packages = [ myDevEnv ];
}
```

## 🚨 Troubleshooting

### Common Issues

1. **Tool Not Found**: Ensure the package is properly imported and the tool category is enabled
2. **Permission Errors**: Check that scripts have proper executable permissions
3. **Path Issues**: Verify that tools are in your PATH after installation

### Debugging

```bash
# Check if tools are available
which dev-tools
which kubectl

# Verify package installation
nix-store -q --references $(which dev-tools)

# Check tool categories
dev-tools help  # Shows detected project types and available commands
```

## 🔄 Maintenance

### Adding New Tools

1. **For dev-tools**: Add to the appropriate tool category in the `toolCategories` attribute set
2. **For kubernetes-tools**: Add to the relevant category (core, security, etc.)
3. **For devshell**: Add to the appropriate language package list

### Updating Configurations

When updating package configurations:

1. Test with multiple project types
2. Verify backward compatibility
3. Update documentation
4. Consider performance implications

## 📚 References

- [Nix Package Manager](https://nixos.org/manual/nix/stable/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Kubernetes Tools Ecosystem](https://kubernetes.io/docs/reference/tools/)
- [Development Environment Best Practices](https://12factor.net/dev-prod-parity)

---

*These packages are designed to provide a comprehensive, intelligent, and maintainable development toolkit while leveraging Nix's reproducibility and composability features.*
