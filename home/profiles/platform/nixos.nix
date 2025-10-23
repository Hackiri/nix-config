# NixOS-specific profile - includes Linux desktop environment and tools
# Inherits from features/desktop.nix -> features/development.nix -> base/minimal.nix
# Adds NixOS-specific applications, X11/Wayland utilities, and system integration.
{...}: {
  imports = [
    # Features: Desktop environment (includes development + minimal)
    ../features/desktop.nix

    # Platform: Linux-specific packages and settings
    ./nixos-pkgs.nix
  ];

  # NixOS-specific profile configurations
  # Add any NixOS-specific profile settings here

  # This profile is designed for NixOS systems and includes:
  # - Essential cross-platform tools (from base/minimal.nix)
  # - All development tools (from features/development.nix)
  # - Desktop applications and media tools (from features/desktop.nix)
  # - Linux-specific packages and configurations (from nixos-pkgs.nix)
  # - X11/Wayland utilities (xclip, xsel)
  # - XDG desktop configuration
  # - Linux-specific services and environment
}
