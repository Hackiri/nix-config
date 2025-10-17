# Development profile - comprehensive development environment
# This profile includes all tools and configurations needed for software development,
# including editors, development tools, terminals, and package collections.
# Inherits from minimal.nix for essential cross-platform tools.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Profiles: Foundation layer (minimal tools)
    ./minimal.nix

    # Programs: Text editors and IDEs
    ../programs/editors

    # Programs: Development tools and configurations
    ../programs/development
    ../programs/kubernetes

    # Programs: Terminal emulators and multiplexers
    ../programs/terminals

    # Programs: System utilities and file managers
    ../programs/utilities

    # Packages: Build tools and compilers
    ../packages/build-tools.nix
    ../packages/code-quality.nix
    ../packages/databases.nix
    ../packages/languages.nix
    ../packages/network.nix
    ../packages/security.nix
    ../packages/terminals.nix
    ../packages/web-dev.nix
    ../packages/custom.nix # Custom packages from /pkgs/
  ];

  # Development-specific home configuration
  home.packages = with pkgs; [
    # Additional development packages can be added here
    # These are for packages that don't fit into the organized categories
  ];
}
