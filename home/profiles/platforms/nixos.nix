# NixOS-specific profile - includes Linux desktop environment and tools
# Inherits from layers/development.nix -> layers/foundation.nix
# Adds NixOS-specific applications, X11/Wayland utilities, and system integration.
{...}: {
  imports = [
    # Features: Development environment (includes minimal)
    ../layers/development.nix

    # Packages: NixOS-specific packages
    ../../packages/platform/nixos.nix
  ];

  # XDG configuration (Linux desktop standard)
  xdg.enable = true;
}
