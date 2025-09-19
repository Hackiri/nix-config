{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}: {
  # Import shared home-manager modules
  imports = [
    ../../home/shared/base.nix
    ../../home/common.nix
    ../../home/nixos.nix
  ];

  # Platform-specific home directory
  home.homeDirectory = "/home/${username}";

  # NixOS-specific home configuration
  # Add any NixOS-specific home-manager configuration here
}
