# Development profile - comprehensive development environment
# This profile includes all tools and configurations needed for software development,
# including editors, development tools, terminals, and package collections.
# Inherits from base/minimal.nix for essential cross-platform tools.
#
# Git Configuration:
# ------------------
# By default, uses basic git (no sops dependency, works out of the box).
# For sops-encrypted git credentials, also import ../base/git.nix in your host config.
#
# Example (hosts/mbp/home.nix):
#   imports = [
#     ../../home/profiles/platform/darwin.nix
#     ../../home/profiles/base/git.nix      # Add this for sops git
#     ../../home/profiles/base/secrets.nix  # Add this for sops utilities
#   ];
{...}: {
  imports = [
    # Base: Foundation layer (minimal tools)
    ../base/minimal.nix

    # Programs: Shell configuration and enhancements (zsh, starship, bash)
    ../../programs/shells

    # Git: Basic configuration (no sops dependency)
    # For sops-encrypted git, import base/git.nix in your host config instead
    ../../programs/development/git/default.nix

    # Programs: Text editors and IDEs
    ../../programs/editors

    # Programs: Development tools and configurations
    ../../programs/development

    # Programs: Terminal emulators and multiplexers
    ../../programs/terminals

    # Programs: System utilities and file managers
    ../../programs/utilities

    # Packages: Build tools and compilers
    ../../packages/build-tools.nix
    ../../packages/code-quality.nix
    ../../packages/databases.nix
    ../../packages/languages.nix
    ../../packages/security.nix
    ../../packages/terminals.nix
    ../../packages/web-dev.nix
    ../../packages/custom.nix # Custom packages from /pkgs/
  ];
}
