# Desktop profile - cross-platform GUI applications and desktop utilities
# Note: This profile is platform-agnostic. Use macos.nix or nixos.nix for platform-specific desktop setups.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include development profile as base
    ./development.nix

    # Note: Platform-specific desktop tools (like aerospace) are now in:
    # - home/profiles/macos.nix for macOS-specific desktop setup
    # - home/profiles/nixos.nix for NixOS-specific desktop setup
  ];

  # Cross-platform desktop packages
  home.packages = with pkgs; [
    # Add cross-platform GUI applications here
    # Examples:
    # firefox     # Web browser (if not using system-wide)
    # thunderbird # Email client
    # libreoffice # Office suite
    # gimp        # Image editor
  ];
}
