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

This configuration provides a comprehensive Zsh environment optimized for development workflows. It integrates Oh My Zsh, custom plugins, and shell functions to create a powerful and user-friendly shell experience.

## Features

### Core Configuration
- Home Manager integration for declarative configuration
- Extended globbing and case-insensitive completion
- Custom environment variables for development tools
- Optimized history management
- Modern theme configuration with Tokyo Night color scheme
- Yazi file manager integration

### Plugin Integration

#### Oh My Zsh
- Git integration for enhanced repository management
- Directory navigation with `z` jump
- macOS-specific optimizations
- Clipboard operations (`copypath`, `copyfile`)
- Archive extraction utilities
- Sudo command line editing
- Directory-specific environment management

#### Additional Plugins
- Auto-suggestions with smart history completion
- Syntax highlighting for commands and arguments
- Integration with direnv for environment management
- Fuzzy finding capabilities with fzf

### Command Aliases

#### System Management
```bash
# Nix Operations
swnix        # Rebuild and switch configuration (verbose)
drynix       # Dry-build configuration
bootnix      # Rebuild and set for next boot
rbnix        # Rollback to previous build
updatanix    # Update and rebuild configuration
cleanix      # Clean Nix store
nix-store-du # Print dead store entries

# Development Environment
nixdev       # Enter Nix development shell
```

#### Container Operations
```bash
# Podman Management
pps          # List containers (formatted table)
pclean       # Clean stopped containers
piclean      # Remove dangling images
pcomp        # Podman compose shorthand
prestart     # Restart compose services
pi           # List images
```

#### Kubernetes Operations
```bash
# Cluster Management
k            # kubectl shorthand
kg           # Get resources
kd           # Describe resources
kap          # Apply resources
kgaa         # Get all resources
kgpsn        # Get pods in namespace
krestartpo   # Restart deployment
ktop         # Show pod resource usage
ktopnodes    # Show node resource usage
kdebug       # Start debug container
```

#### Version Control
```bash
# Git Operations
gaa          # Git add all
gcmsg        # Git commit with message
gst          # Show status
gitsave      # Quick save changes
gco          # Checkout
gcb          # Create and checkout new branch
gcm          # Checkout main branch
gl           # Show log graph
gpull        # Pull with rebase
gpush        # Push to current branch
```

### Keyboard Shortcuts (Keymaps)

The configuration includes powerful keyboard shortcuts for Git operations and file navigation using FZF integration.

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
- **Files**: Syntax-highlighted content (first 500 lines)
- **Directories**: Tree structure (first 200 lines)
- **Git diffs**: Color-coded changes
- **Git commits**: Full commit details and diff
- **Git branches**: Commit history graph

Press `Ctrl+/` in any FZF window to toggle preview visibility.

### Shell Functions

#### Configuration Management
- `dots()`: Navigate to Nix configuration
- `savedots [message]`: Save configuration changes
- `rebuild()`: Rebuild system configuration

#### Maintenance
- `sfu()`: Update Nix flake
- `garbage()`: Run store optimization
- `news()`: Check Home Manager updates

## Configuration

### Directory Structure
```
zsh/
├── aliases.nix       # Command shortcuts
├── default.nix       # Shell and plugin settings
├── lib               # oh-my-zsh Library functions
├── oh-my-zsh.sh      # oh-my-zsh installer
├── themes                  # Prompt themes
│   ├── agnoster.zsh-theme
│   └── powerlevel10k
└── tools             # oh-my-zsh Utility scripts
```

### Required Components
- Nix package manager
- Home Manager
- Git

### Core Packages
- `direnv`: Environment management
- `fzf`: Fuzzy finding
- `zoxide`: Smart directory jumping
- `bat`: Modern cat replacement
- `jq`: JSON processor
- `starship`: Modern shell prompt
- Essential Unix utilities

## Usage

### Installation
Add to your Home Manager configuration:
```nix
{
  programs.zsh.enable = true;
  imports = [ ./zsh/default.nix ];
}
```

### Updates
```bash
swnix        # Full rebuild with verbose output
drynix       # Test configuration changes
updatanix    # Update and rebuild system
```

## Maintenance

### Configuration Files
- `default.nix`: Shell configuration and theme settings
- `aliases.nix`: Command shortcuts
- `scripts.nix`: Shell functions
- `themes/jetpack.toml`: Prompt configuration

### Update Process
1. Modify configuration files as needed
2. Test changes with `drynix`
3. Apply changes with `swnix`
4. Monitor `news()` for updates

## Troubleshooting

### Common Issues
1. **Plugin Loading Failures**
   - Verify plugin configuration in `default.nix`
   - Check package availability

2. **Performance Issues**
   - Review enabled plugins
   - Monitor startup time with `zprof`
   - Check for conflicting configurations

3. **Prompt Display Problems**
   - Verify oh-my-zsh installation
   - Check font compatibility
   - Review theme configuration
