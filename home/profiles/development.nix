# Development profile - comprehensive development environment
# This profile includes all tools and configurations needed for software development,
# including editors, development tools, terminals, and package collections.
# Inherits from minimal.nix for essential cross-platform tools.
{pkgs, ...}: {
  imports = [
    # Profiles: Foundation layer (minimal tools)
    ./minimal.nix

    # Profiles: Secrets management (OPTIONAL - comment out if not using sops)
    # Requires age key setup - see README section 5 for instructions
    # If you're a new user, comment this out until you set up sops-nix
    ./secrets.nix

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
