# Development profile - comprehensive development environment
# This profile includes all tools and configurations needed for software development,
# including editors, development tools, terminals, and package collections.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Text editors and IDEs
    ../programs/editors # Neovim, Emacs, Neovide

    # Development tools and configurations
    ../programs/development # Git, direnv, Kubernetes tools

    # Terminal and shell enhancements
    ../programs/terminals # Tmux, Alacritty, Ghostty
    ../programs/shells # Zsh, Bash, Starship

    # Utility programs
    ../programs/utilities # btop, yazi, sops

    # Package collections
    ../packages # Standard nixpkgs packages
    ../custom # Custom overlay packages
  ];

  # Development-specific home configuration
  home.packages = with pkgs; [
    # Additional development packages can be added here
    # These are for packages that don't fit into the organized categories
  ];
}
