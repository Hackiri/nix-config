# Minimal profile - basic tools only
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Basic shell enhancements
    ../programs/shells/starship

    # Essential utilities
    ../programs/utilities/btop
  ];

  # Minimal package set
  home.packages = with pkgs; [
    # Only essential packages
    curl
    wget
    git
    vim
  ];
}
