# NixOS-specific profile - includes Linux desktop environment and tools
# Inherits from desktop.nix -> development.nix -> minimal.nix
# Adds NixOS-specific applications, X11/Wayland utilities, and system integration.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Profiles: Desktop environment (includes development + minimal)
    ./desktop.nix

    # Platform: Linux-specific packages and settings
    ./platform/nixos-pkgs.nix
  ];

  # NixOS-specific profile configurations
  # Add any NixOS-specific profile settings here

  # This profile is designed for NixOS systems and includes:
  # - Essential cross-platform tools (from minimal.nix)
  # - All development tools (from development.nix)
  # - Desktop applications and media tools (from desktop.nix)
  # - Linux-specific packages and configurations (from nixos.nix)
  # - X11/Wayland utilities (xclip, xsel)
  # - XDG desktop configuration
  # - Linux-specific services and environment
}
