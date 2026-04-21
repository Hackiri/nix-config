# NixOS-specific profile - includes Linux desktop environment and tools
# Inherits from features/development.nix -> base/minimal.nix
# Adds NixOS-specific applications, X11/Wayland utilities, and system integration.
{...}: {
  imports = [
    # Features: Development environment (includes minimal)
    ../features/development.nix

    # Packages: NixOS-specific packages
    ../../packages/nixos.nix
  ];

  # XDG configuration (Linux desktop standard)
  xdg.enable = true;
}
