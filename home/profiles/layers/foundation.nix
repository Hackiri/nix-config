# Foundation layer - essential cross-platform tools and configurations
# This layer provides the foundation that all other profiles inherit from.
# It includes only the most essential tools that should be available everywhere.
{
  config,
  lib,
  programRegistry,
  username,
  ...
}: let
  nixConfigPath = "${config.home.homeDirectory}/nix-config";
in {
  imports = [
    # Theme: Centralized color palette (used by starship, terminals, etc.)
    programRegistry.theme

    # Packages: Core CLI tools (bat, eza, fd, fzf, ripgrep, etc.)
    ../../packages/core/cli.nix

    # Packages: Network essentials (wget, cachix)
    ../../packages/core/networking.nix

    # Programs: Security hardening (SSH, etc.)
    programRegistry.security.ssh

    # Programs: Essential system monitoring utilities
    programRegistry.utilities.btop
  ];

  # Common home-manager configuration (replaces home/shared/base.nix)
  home = {
    inherit username;
    stateVersion = "25.05";
  };

  # Essential programs that work everywhere
  programs = {
    home-manager.enable = true;
    nh = {
      enable = true;
      flake = lib.mkDefault nixConfigPath;
      darwinFlake = lib.mkDefault nixConfigPath;
      homeFlake = lib.mkDefault nixConfigPath;
      osFlake = lib.mkDefault nixConfigPath;
    };
  };
}
