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
    # Foundation: Essential cross-platform tools
    ./minimal.nix

    # Text editors and IDEs
    ../programs/editors # Neovim, Emacs, Neovide

    # Development tools and configurations
    ../programs/development # Git, direnv
    ../programs/kubernetes # Kubernetes tools and config

    # Terminal and shell enhancements
    ../programs/terminals # Tmux, Alacritty, Ghostty

    # Utility programs
    ../programs/utilities # btop, yazi, sops

    # Development-specific package collections
    ../packages/build-tools.nix    # gcc, cmake, make, etc.
    ../packages/code-quality.nix   # linters, formatters
    ../packages/languages.nix     # nodejs, python, php
    ../packages/terminals.nix     # tmuxinator, moreutils
    ../packages/security.nix      # sops, age
    ../packages/network.nix       # cachix (nix-specific)

    # Custom overlay packages
    ../packages/custom # Custom overlay packages
  ];

  # Development-specific home configuration
  home.packages = with pkgs; [
    # Additional development packages can be added here
    # These are for packages that don't fit into the organized categories
  ];
}
