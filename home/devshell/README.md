# Development Shell Environment

A comprehensive, reproducible development environment powered by Nix and Home Manager, providing a consistent toolset across multiple programming languages and development workflows.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Maintenance](#maintenance)

## Overview

The DevShell environment provides a declarative, version-controlled development setup that ensures consistency across different machines and team members. It integrates multiple programming languages, development tools, and productivity utilities into a cohesive environment.

## Features

### Programming Languages

#### Python Development

- Python 3 with pip and pipx integration
- Virtual environment management
- Package management tools
- Development utilities and linters

#### Rust Development

- Rustup toolchain management
- Latest stable compiler and tools
- Cargo package ecosystem
- Cross-compilation support

#### Go Development

- Go toolchain and compiler
- Standard library and tools
- Build and test utilities
- Cross-platform support

#### Node.js Development

- Node.js runtime with npm
- Package management tools
- Build and development utilities
- JavaScript/TypeScript support

### Development Tools

#### Version Control

```bash
# Core Git functionality
git          # Version control
git-lfs      # Large file support
git-delta    # Enhanced diffs
git-crypt    # File encryption

# Additional tools
pre-commit   # Git hooks framework
```

#### Code Quality Tools

```bash
# Formatters and Linters
alejandra    # Nix formatter
deadnix      # Dead code detector
statix       # Static analyzer
ruff         # Python linter
```

#### Shell Environment

```bash
# Core Tools
zsh          # Modern shell
fzf          # Fuzzy finder
bat          # Enhanced cat
eza          # Modern ls
direnv       # Env management

# Additional Features
- Syntax highlighting
- Auto-suggestions
- History search
```

#### Build System

```bash
# Core Build Tools
make         # Build automation
cmake        # Build generator
ninja        # Build system
gcc          # Compiler collection

# Support Tools
pkg-config   # Library helper
autoconf     # Configure scripts
automake     # Makefile generator
libtool      # Library tools
```

#### Productivity Tools

```bash
# Search and Navigation
ripgrep      # Fast search
fd           # Modern find
tree         # Directory viewer

# Data Processing
jq           # JSON processor
yq           # YAML processor
```

#### Debugging Tools

```bash
# Core Debuggers
gdb          # GNU Debugger
lldb_17         # LLVM Debugger

# Process Management
htop         # Process viewer
```

## Installation

### Prerequisites

- Nix package manager
- Home Manager
- Git

### Basic Setup

Add to your Home Manager configuration:

```nix
{
  programs.devshell = {
    enable = true;
    # Optional: Configure specific features
    features = {
      python = true;
      rust = true;
      go = true;
      node = true;
    };
  };
}
```

## Usage

### Entering the Environment

```bash
# Enter development shell
nix develop

# With specific features
nix develop --arg features '{ python = true; }'
```

### Pre-commit Hooks

```bash
# Install hooks
pre-commit install

# Run hooks manually
pre-commit run --all-files
```

## Configuration

### Directory Structure

```
devshell/
├── default.nix    # Main configuration
└── README.md      # Documentation
```

### Customization

Modify `default.nix` to:

- Enable/disable features
- Add custom packages
- Configure tool settings
- Set environment variables

## Maintenance

### Updates

```bash
# Update all tools
nix flake update

# Update specific inputs
nix flake lock --update-input nixpkgs
```

### Monitoring

- Check tool versions regularly
- Monitor disk usage
- Review dependency updates
- Test environment reproducibility

For issues or suggestions, please open an issue in the repository.
