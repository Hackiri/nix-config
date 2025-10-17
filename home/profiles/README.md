# Home Manager Profiles

This directory contains the layered profile system for Home Manager configurations.

## Profile Hierarchy

Profiles are organized in an inheritance chain, with each level building upon the previous:

```
minimal.nix (foundation)
    ↓
development.nix (adds dev tools)
    ↓
desktop.nix (adds GUI apps)
    ↓
darwin.nix / nixos.nix (platform-specific)
```

## Profile Descriptions

### `minimal.nix` - Foundation Profile
**Purpose**: Essential cross-platform tools available everywhere  
**Includes**:
- Basic CLI tools (bat, eza, fd, fzf, jq, ripgrep, tree, zoxide)
- Network essentials (curl, wget)
- System utilities (vim, htop, neofetch)
- File processing (zip, unzip, gzip)
- Shell configuration (zsh with oh-my-zsh)
- Essential utilities (btop)

**Used by**: All other profiles  
**Imports**: Programs (shells, utilities/btop)

---

### `development.nix` - Development Profile
**Purpose**: Comprehensive development environment  
**Includes**:
- Text editors (Neovim, Emacs, Neovide)
- Development tools (Git, direnv)
- Kubernetes tools and configuration
- Terminal emulators (Alacritty, Ghostty, Tmux)
- Build tools and compilers
- Code quality tools (linters, formatters)
- Database clients
- Programming language runtimes
- Web development tools
- Security tools

**Inherits from**: `minimal.nix`  
**Used by**: `desktop.nix`  
**Imports**: 
- Programs: editors, development, kubernetes, terminals, utilities
- Packages: build-tools, code-quality, databases, languages, network, security, terminals, web-dev, custom

---

### `desktop.nix` - Desktop Profile
**Purpose**: GUI applications and desktop environment tools  
**Includes**:
- Desktop applications
- Media processing tools (imagemagick, ghostscript)

**Inherits from**: `development.nix` (which includes `minimal.nix`)  
**Used by**: `darwin.nix`, `nixos.nix`  
**Imports**:
- Packages: desktop, utilities

---

### `darwin.nix` - macOS Profile
**Purpose**: macOS-specific configuration entry point  
**Includes**:
- All tools from desktop → development → minimal chain
- macOS-specific packages and settings
- macOS window management (AeroSpace)

**Inherits from**: `desktop.nix`  
**Platform**: macOS (Darwin)  
**Imports**:
- Platform: platform/darwin.nix
- Programs: utilities/aerospace

---

### `nixos.nix` - NixOS Profile
**Purpose**: NixOS-specific configuration entry point
**Includes**:
- All tools from desktop → development → minimal chain
- Linux-specific packages and settings
- X11/Wayland utilities

**Inherits from**: `desktop.nix`
**Platform**: NixOS (Linux)
**Imports**:
- Platform: platform/nixos.nix

---

### `kube-dev.nix` - Kubernetes Development Profile
**Purpose**: Kubernetes engineer workflow with configurable toolsets
**Includes**:
- Remote cluster management tools (kubectl, helm, kubectx, kubecolor)
- GitOps and CI/CD tools (ArgoCD, Flux, Skaffold, Tekton)
- Infrastructure as Code (Terraform, Pulumi, Ansible)
- Cloud provider CLIs (AWS, GCP, Azure)
- Local development cluster tools (kind, tilt, kubeconform)
- K9s terminal UI with custom configuration
- 60+ kubectl/helm shell aliases
- Neovim Kubernetes snippets

**Standalone profile**: Can be imported into any configuration
**Configuration options**:
```nix
profiles.kube-dev = {
  enable = true;
  toolset = "devops";      # Options: "devops" or "complete"
  includeLocalDev = true;  # Include kind, tilt, kubeconform
};
```

**Toolset options**:
- `devops`: CI/CD and GitOps workflows (recommended for remote clusters)
  - Core: kubectl, helm, kustomize, kubectx, kubecolor
  - GitOps: argocd, flux, skaffold, tekton
  - IaC: terraform, pulumi, ansible
  - Cloud: AWS, GCP, Azure CLIs
  - Containers: skopeo, dive, crane
  - CNI: cilium-cli
  - Distributions: talosctl, k0sctl

- `complete`: All available Kubernetes tools (includes observability, security, service mesh)
  - Everything in devops + k9s, stern, popeye, kube-bench, istio, linkerd, helm plugins, etc.

**Usage example**:
```nix
# hosts/mbp/home.nix
{
  imports = [
    ../../home/profiles/darwin.nix
    ../../home/profiles/kube-dev.nix
  ];

  profiles.kube-dev = {
    enable = true;
    toolset = "devops";
    includeLocalDev = true;
  };
}
```

---

## Platform-Specific Configurations

Platform-specific packages and settings are located in `platform/`:

### `platform/darwin.nix`
macOS-specific packages:
- `mkalias` - macOS alias creation
- `pam-reattach` - Touch ID support in tmux
- `reattach-to-user-namespace` - macOS clipboard integration
- `aerospace` - Tiling window manager

### `platform/nixos.nix`
Linux-specific packages:
- `xclip` - X11 clipboard utility
- `xsel` - X11 selection utility
- XDG desktop configuration

---

## Import Convention

All imports follow a standardized format with category prefixes:

```nix
imports = [
  # Profiles: [description]
  ./minimal.nix

  # Programs: [description]
  ../programs/editors
  ../programs/development

  # Packages: [description]
  ../packages/build-tools.nix
  ../packages/web-dev.nix

  # Platform: [description]
  ./platform/darwin.nix
];
```

**Rules**:
1. **Directory imports**: Omit `default.nix` → `../programs/shells`
2. **File imports**: Include `.nix` extension → `../packages/web-dev.nix`
3. **Relative paths**: Use `../` for parent, `./` for same level
4. **Categories**: Prefix comments with `Profiles:`, `Programs:`, `Packages:`, or `Platform:`

---

## Adding New Packages

### To add packages available everywhere:
→ Add to `minimal.nix` `home.packages`

### To add development-specific packages:
1. Add to appropriate package file in `../packages/`
2. If new category needed, create new `.nix` file
3. Import in `development.nix`

### To add desktop-specific packages:
1. Add to `../packages/desktop.nix` or `../packages/utilities.nix`
2. Ensure imported in `desktop.nix`

### To add platform-specific packages:
→ Add to `platform/darwin.nix` or `platform/nixos.nix`

---

## Package Organization

Package collections are in `../packages/`:
- `build-tools.nix` - Compilers, build systems, dev tools
- `code-quality.nix` - Linters, formatters, analyzers
- `custom/` - Custom overlay packages
- `databases.nix` - Database clients (psql, redis-cli, etc.)
- `desktop.nix` - GUI applications
- `languages.nix` - Language runtimes (Node, Python, Go, etc.)
- `network.nix` - Network tools (cachix)
- `security.nix` - Security tools (sops, age)
- `system.nix` - System utilities
- `terminals.nix` - Terminal tools (tmuxinator, moreutils)
- `utilities.nix` - Media processing (imagemagick, ghostscript)
- `web-dev.nix` - Web dev tools (httpie, curl, grpcurl, caddy)

See `../packages/default.nix` for complete documentation.

---

## Program Configurations

Program-specific configurations are in `../programs/`:
- `development/` - Git, direnv
- `editors/` - Neovim, Emacs, Neovide
- `kubernetes/` - Kubernetes tools
- `shells/` - Zsh, oh-my-zsh
- `terminals/` - Alacritty, Ghostty, Tmux
- `utilities/` - AeroSpace, btop, yazi, sops

---

## Usage in Flake

Profiles are imported via host-specific home configurations:

```nix
# hosts/mbp/home.nix
{
  imports = [
    ../../home/profiles/darwin.nix  # macOS profile
  ];
}
```

```nix
# hosts/desktop/home.nix
{
  imports = [
    ../../home/profiles/nixos.nix  # NixOS profile
  ];
}
```

---

## Architecture Principles

1. **Layered Inheritance**: Each profile builds on the previous, avoiding duplication
2. **Clear Separation**: Profiles vs Programs vs Packages vs Platform configs
3. **Explicit Imports**: Import specific files rather than aggregators
4. **Consistent Naming**: Category prefixes in comments for clarity
5. **Documentation**: Each file has clear purpose and usage notes
