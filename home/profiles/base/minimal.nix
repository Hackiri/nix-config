# Minimal profile - essential cross-platform tools and configurations
# This profile provides the foundation that all other profiles inherit from.
# It includes only the most essential tools that should be available everywhere.
{username, ...}: {
  imports = [
    # Theme: Centralized color palette (used by starship, terminals, etc.)
    ../../programs/theme

    # Packages: Core CLI tools (bat, eza, fd, fzf, ripgrep, etc.)
    ../../packages/cli-essentials.nix

    # Packages: Network essentials (wget, cachix)
    ../../packages/network.nix

    # Programs: Security hardening (SSH, etc.)
    ../../programs/security

    # Programs: Essential system monitoring utilities
    ../../programs/utilities/btop
  ];

  # Common home-manager configuration (replaces home/shared/base.nix)
  home = {
    inherit username;
    stateVersion = "25.05";
  };

  # Essential programs that work everywhere
  programs = {
    home-manager.enable = true;
  };
}
