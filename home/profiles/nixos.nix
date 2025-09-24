# NixOS-specific profile - includes Linux desktop environment and tools
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Base development profile (cross-platform)
    ./development.nix
    
    # NixOS-specific configurations
    ../nixos.nix
  ];

  # NixOS-specific profile configurations
  # Add any NixOS-specific profile settings here
  
  # This profile is designed for NixOS systems and includes:
  # - All development tools (from development.nix)
  # - Linux-specific packages and configurations (from nixos.nix)
  # - X11/Wayland utilities (xclip, xsel)
  # - XDG desktop configuration
  # - Linux-specific services and environment
}
