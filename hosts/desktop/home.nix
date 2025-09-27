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
    ../../home/profiles/nixos.nix # NixOS-specific profile (includes development + nixos configs)
  ];

  # Platform-specific home directory
  home.homeDirectory = "/home/${username}";

  # NixOS-specific home configuration
  # Add any NixOS-specific home-manager configuration here
}
