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
    ../../home/profiles/nixos.nix  # Use NixOS-specific profile instead of common.nix + nixos.nix
  ];

  # Platform-specific home directory
  home.homeDirectory = "/home/${username}";

  # NixOS-specific home configuration
  # Add any NixOS-specific home-manager configuration here
}
