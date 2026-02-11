# Development profile - comprehensive development environment
# This profile includes all tools and configurations needed for software development,
# including editors, development tools, terminals, and package collections.
# Inherits from base/minimal.nix for essential cross-platform tools.
#
# Git Configuration:
# ------------------
# By default, uses basic git (no sops dependency, works out of the box).
# For sops-encrypted git credentials, import features/sops.nix and set
# profiles.sops.enable = true in your host config.
#
# Example (hosts/mbp/home.nix):
#   imports = [
#     ../../home/profiles/platform/darwin.nix
#     ../../home/profiles/features/sops.nix  # Add this
#   ];
#   profiles.sops.enable = true;
{...}: {
  imports = [
    # Base: Foundation layer (minimal tools)
    ../base/minimal.nix

    # Programs: Shell configuration and enhancements (zsh, starship, bash)
    ../../programs/shells

    # Git: Basic configuration (no sops dependency)
    # For sops-encrypted git, import features/sops.nix and set profiles.sops.enable = true
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
  ];
}
