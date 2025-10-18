# Zsh Configuration

A modern, feature-rich Zsh configuration managed through Home Manager, providing an enhanced shell environment with integrated tools and productivity features.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Configuration](#configuration)
- [Usage](#usage)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)

## Overview

This configuration provides a comprehensive Zsh environment optimized for development workflows. It integrates Oh My Zsh, custom plugins, and FZF keybindings to create a powerful and user-friendly shell experience.

## Features

### Core Configuration
- Home Manager integration for declarative configuration
- Extended globbing and case-insensitive completion
- Custom environment variables for development tools
- Optimized history management (50,000 entries)
- Modern theme configuration with Tokyo Night color scheme
- Starship prompt for fast, customizable shell prompt

### Plugin Integration

#### Oh My Zsh
- Git integration for enhanced repository management
- Sudo command line editing
- Directory-specific environment management with direnv
- Archive extraction utilities
- Colored man pages for better readability
- Kubectl, Docker, and Docker Compose integration
- macOS-specific optimizations
- JSON tools for JSON manipulation

#### Additional Plugins
- Auto-suggestions with smart history completion
- Syntax highlighting for commands and arguments
- History substring search for better history navigation
- Integration with zoxide for smart directory jumping

### Command Aliases

#### System Management (Nix Darwin)
```bash
# Basic Operations
nixb         # Base darwin-rebuild command
nixbuild     # Build only (no activation)
nixswitch    # Build and activate configuration
nixcheck     # Check configuration for errors
nixdry       # Dry build (test without changes)
nixedit      # Open configuration in $EDITOR

# System Management
nixlist      # List all system generations
nixrollback  # Rollback to previous generation
nixclean     # Clean old generations and free space

# Debugging
nixtrace     # Show trace for debugging
nixverbose   # Verbose output during build

# Nix Utilities
nxsearch     # Search nixpkgs for packages
nxrepl       # Interactive Nix REPL
nxdev        # Enter development shell
```

#### Container Operations (Podman)
```bash
# Podman Management
pps          # List containers (formatted table)
pclean       # Clean stopped containers
piclean      # Remove dangling images
pi           # List images
pcomp        # Podman compose shorthand
prestart     # Restart compose services

# Docker aliases (mapped to Podman)
docker       # Alias to podman
docker-compose # Alias to podman-compose
```

#### Kubernetes Operations
```bash
# Basic Commands
k            # kubectl shorthand
kns          # Set namespace for current context

# Resource Operations
kg           # Get resources
kd           # Describe resources
kl           # View logs
ke           # Edit resources
kx           # Execute command in container
ka           # Apply configuration file

# Pod Management
kgp          # Get pods
kgps         # Get pods (sorted by name)
kgpsn        # Get pods in namespace
kexec        # Execute command in pod
kshell       # Open shell in pod

# Service and Deployment
kgs          # Get services
kgsvc        # Get services (sorted by name)
kgd          # Get deployments
krestartpo   # Restart deployment

# Other Resources
kgn          # Get nodes
kgnodes      # Get nodes (wide output)
kgc          # Get configmaps
kgsec        # Get secrets
kgns         # Get namespaces
kgaa         # Get all resources in all namespaces

# Monitoring and Debugging
ktop         # Show pod resource usage
ktopnodes    # Show node resource usage
kdebug       # Start debug container
klogs        # View logs
kevents      # Get events (sorted by creation time)

# Context Management
kusectx      # Switch context
kgctx        # Get available contexts
knschange    # Change namespace

# Deployment Management
kroll        # Rollout restart
kstatus      # Rollout status
kscale       # Scale replicas

# Advanced Operations
kfwd         # Port forward
kapplyd      # Apply kustomization in current directory
```

#### Helm Operations
```bash
h            # Helm shorthand
hi           # Helm install
hu           # Helm upgrade
hl           # Helm list
hd           # Helm delete
hr           # Helm repo
hru          # Helm repo update
hs           # Helm search
```

#### Version Control (Git)
```bash
# Basic Operations
gaa          # Git add all
gcmsg        # Git commit with message
gst          # Show status
gco          # Checkout
gcb          # Create and checkout new branch
gcm          # Checkout main branch

# History and Logs
gl           # Show log graph (oneline)
glast        # Show last commit

# Remote Operations
gpull        # Pull with rebase
gpush        # Push to current branch
```

#### Modern Unix Replacements
```bash
cat          # bat (syntax highlighting)
ls           # eza (icons, tree view)
l            # ls -l
ll           # ls -alh
lsa          # ls -a
find         # fd (modern find)
grep         # rg (ripgrep)
ps           # procs (modern ps)
top          # btm (bottom - system monitor)
du           # dust (disk usage)
df           # duf (disk free)
diff         # colordiff (colored diff)
```

#### File Management
```bash
files        # yazi (terminal file manager)
lg           # lazygit (terminal git UI)
vi           # nvim (Neovim)
vif          # Open file with FZF preview
fin          # Find and open in nvim
```

#### FZF Combinations
```bash
fcd          # Fuzzy cd to directory
fh           # Fuzzy search history
fkill        # Fuzzy kill process
fenv         # Fuzzy search environment variables
frg          # Fuzzy ripgrep with preview
```

#### Tmux
```bash
ta           # Attach to session
tad          # Attach to session (detach others)
ts           # Create new session
tl           # List sessions
tksv         # Kill server
tkss         # Kill session
```

#### Other Utilities
```bash
dots         # cd to ~/nix-config
ai           # aichat (AI assistant)
pcmit        # Run pre-commit on all files
md           # glow (markdown viewer)
```

### Keyboard Shortcuts (Keymaps)

The configuration includes powerful keyboard shortcuts for Git, Kubernetes, Talos, and Cilium operations using FZF integration.

#### Git Integration Keymaps

All Git keymaps use `Ctrl+G` followed by another key combination. These only work inside Git repositories.

**File and Status Management:**
```bash
Ctrl+G Ctrl+F    # Git File Status Browser
                 # Shows modified/untracked files with diff preview
                 # Multi-select with TAB

Ctrl+G Ctrl+ST   # Enhanced Git Status (interactive)
                 # Press Ctrl+A to add/unstage files
                 # Press Ctrl+C to commit
                 # Live diff preview

Ctrl+G Ctrl+A    # Interactive Git Add
                 # Multi-select files to stage (TAB to select)
                 # Shows diff for modified files, content for new files
```

**Branch and Tag Management:**
```bash
Ctrl+G Ctrl+B    # Git Branch Browser
                 # Lists local and remote branches
                 # Shows commit history for selected branch
                 # Multi-select supported

Ctrl+G Ctrl+T    # Git Tag Browser
                 # Lists all tags with version sorting
                 # Shows tag details and associated commits
```

**History and Commits:**
```bash
Ctrl+G Ctrl+H    # Git History Browser
                 # Interactive commit history with diff preview
                 # Press Ctrl+S to toggle sort order
                 # Multi-select commits

Ctrl+G Ctrl+C    # Interactive Git Commit
                 # Opens editor for commit message
                 # Shows staged files and their status
                 # Auto-filters out comments
```

**Remote and Stash:**
```bash
Ctrl+G Ctrl+R    # Git Remote Browser
                 # Lists remotes with their URLs
                 # Shows commit history for each remote

Ctrl+G Ctrl+S    # Git Stash Browser
                 # Browse stashed changes
                 # Preview stash contents
```

#### Kubectl Integration Keymaps

Kubernetes operations with `Ctrl+K` prefix. Includes FZF-powered resource browsing.

#### Talos Integration Keymaps

Talos operations with FZF integration for cluster management.

#### Cilium Integration Keymaps

Cilium operations with FZF integration for network policy and troubleshooting.

#### FZF Navigation Keymaps

Built-in FZF shortcuts for file and directory navigation:

```bash
Ctrl+T           # Fuzzy file/directory finder
                 # Search recursively from current directory
                 # Preview files with syntax highlighting (bat)
                 # Preview directories with tree structure (eza)

Alt+C            # Fuzzy directory finder + cd
                 # Quickly navigate to any subdirectory
                 # Preview directory structure

Ctrl+R           # Command history search
                 # Fuzzy find previous commands
                 # Execute or edit selected command
```

#### Preview Features

All FZF keymaps include intelligent previews:
- **Files**: Syntax-highlighted content (first 500 lines) using bat
- **Directories**: Tree structure (first 200 lines) using eza
- **Git diffs**: Color-coded changes
- **Git commits**: Full commit details and diff
- **Git branches**: Commit history graph

Press `Ctrl+/` in any FZF window to toggle preview visibility.

## Configuration

### Directory Structure
```
zsh/
├── aliases.nix       # Command shortcuts and aliases
├── default.nix       # Shell and plugin settings
├── fzf-cilium.nix    # FZF keybindings for Cilium operations
├── fzf-git.nix       # FZF keybindings for Git operations
├── fzf-kubectl.nix   # FZF keybindings for Kubectl operations
├── fzf-talos.nix     # FZF keybindings for Talos operations
└── themes/           # Custom Zsh themes
    ├── agnoster.zsh-theme
    └── jonathan.zsh-theme
```

### Required Components
- Nix package manager
- Home Manager
- Git
- Darwin (for macOS system management)

### Core Packages
The following packages are automatically installed and configured:
- `oh-my-zsh`: Zsh framework with plugins
- `zsh-autosuggestions`: Command suggestions from history
- `zsh-syntax-highlighting`: Real-time syntax highlighting
- `zsh-history-substring-search`: Better history search
- `direnv`: Environment management
- `fzf`: Fuzzy finding
- `zoxide`: Smart directory jumping (replaces `cd`)
- `bat`: Modern cat replacement with syntax highlighting
- `eza`: Modern ls replacement with icons
- `fd`: Modern find replacement
- `ripgrep`: Fast grep alternative
- `starship`: Cross-shell prompt

## Usage

### Installation
This configuration is automatically loaded through the Nix configuration. The Zsh configuration is integrated into the Home Manager setup.

### Daily Usage
```bash
# Navigate directories
cd <partial-path>  # Uses zoxide smart jumping
Ctrl+T             # Fuzzy find files
Alt+C              # Fuzzy find directories

# Git operations
Ctrl+G Ctrl+F      # Browse and stage files
Ctrl+G Ctrl+B      # Browse branches
Ctrl+G Ctrl+H      # Browse commit history

# System management
nixswitch          # Apply configuration changes
nixdry             # Test configuration changes
nixclean           # Clean old generations
```

### Updates
The configuration is declaratively managed through Nix, so updates are applied by modifying the configuration files and rebuilding:

```bash
nixdry             # Test configuration changes
nixswitch          # Apply changes
```

## Maintenance

### Configuration Files
- `default.nix`: Main shell configuration, plugins, and initialization
- `aliases.nix`: All command aliases
- `fzf-git.nix`: Git FZF keybindings
- `fzf-kubectl.nix`: Kubectl FZF keybindings
- `fzf-talos.nix`: Talos FZF keybindings
- `fzf-cilium.nix`: Cilium FZF keybindings
- `themes/`: Custom Zsh prompt themes (Starship is used by default)

### Update Process
1. Modify configuration files as needed
2. Test changes with `nixdry` to verify no errors
3. Apply changes with `nixswitch`
4. If issues occur, use `nixrollback` to revert

### Performance Optimization
The configuration includes several performance optimizations:
- Completion cache rebuilt only once per day
- Async auto-suggestions
- Limited auto-suggest buffer size (20 characters)
- Disabled magic functions for faster startup
- Optimized completion loading with `compinit -C`

## Troubleshooting

### Common Issues

1. **Plugin Loading Failures**
   - Verify plugin configuration in [default.nix](default.nix)
   - Check that required packages are installed
   - Ensure Oh My Zsh is properly initialized

2. **Performance Issues**
   - Review enabled plugins in [default.nix](default.nix#L111-L122)
   - Monitor startup time: Add `zmodload zsh/zprof` at the start of initContent and `zprof` at the end
   - Check for conflicting configurations
   - Ensure completion cache is being used

3. **Prompt Display Problems**
   - Verify Starship is installed and initialized
   - Check font compatibility (requires Nerd Fonts for icons)
   - Review theme configuration
   - Ensure `$TERM` is set correctly

4. **FZF Keybindings Not Working**
   - Verify FZF is installed: `fzf --version`
   - Check that FZF initialization scripts are sourced
   - Ensure no conflicting keybindings in other configurations
   - Test in a clean shell: `zsh -f`

5. **Oh My Zsh Not Found**
   - Check that `$ZSH` environment variable points to correct location
   - Verify Oh My Zsh package is installed via Nix
   - Ensure oh-my-zsh.sh exists at `$ZSH/oh-my-zsh.sh`

6. **Zoxide Not Working**
   - Verify initialization: `which cd` should show zoxide wrapper
   - Check that zoxide is installed: `zoxide --version`
   - Rebuild database: `zoxide query --list`
