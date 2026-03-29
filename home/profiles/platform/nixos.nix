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
}
