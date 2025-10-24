# Development profile - comprehensive development environment
# This profile includes all tools and configurations needed for software development,
# including editors, development tools, terminals, and package collections.
# Inherits from base/minimal.nix for essential cross-platform tools.
{pkgs, ...}: {
  imports = [
    # Base: Foundation layer (minimal tools)
    ../base/minimal.nix

    # ═══════════════════════════════════════════════════════════════
    # Git Configuration Options (Choose ONE):
    # ═══════════════════════════════════════════════════════════════
    #
    # OPTION 1: Git with sops-integrated hooks (RECOMMENDED)
    # - Automatically reads Git credentials from encrypted sops secrets
    # - Requires: age key setup + secrets.yaml configuration
    # - Also import base/secrets.nix below for sops CLI utilities
    ../base/git.nix
    #
    # OPTION 2: Basic Git without sops (SIMPLE)
    # - Manual Git configuration via: git config --global user.name/email
    # - No sops integration, no automatic credential management
    # - Uncomment the line below and comment out base/git.nix above:
    # ../../programs/development/git/default.nix
    # ═══════════════════════════════════════════════════════════════

    # Base: SOPS utilities (OPTIONAL - only needed if using base/git.nix)
    # Provides sops CLI commands: sops-edit, sops-encrypt, sops-decrypt
    # Comment out if using basic Git (OPTION 2 above)
    # ../base/secrets.nix

    # Programs: Text editors and IDEs
    ../../programs/editors

    # Programs: Development tools and configurations
    ../../programs/development
    ../../programs/kubernetes

    # Programs: Terminal emulators and multiplexers
    ../../programs/terminals

    # Programs: System utilities and file managers
    ../../programs/utilities

    # Packages: Build tools and compilers
    ../../packages/build-tools.nix
    ../../packages/code-quality.nix
    ../../packages/databases.nix
    ../../packages/languages.nix
    ../../packages/network.nix
    ../../packages/security.nix
    ../../packages/terminals.nix
    ../../packages/web-dev.nix
    ../../packages/custom.nix # Custom packages from /pkgs/
  ];

  # Development-specific home configuration
  home.packages = with pkgs; [
    # Additional development packages can be added here
    # These are for packages that don't fit into the organized categories
  ];
}
