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
    ../../home/profiles/nixos.nix # NixOS-specific profile (includes desktop -> development -> minimal chain)
  ];

  # Platform-specific home directory
  home.homeDirectory = "/home/${username}";

  # NixOS-specific home configuration
  # Add any NixOS-specific home-manager configuration here
}
