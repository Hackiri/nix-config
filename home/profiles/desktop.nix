# Desktop profile - GUI applications and desktop environment tools
# Inherits from development.nix which includes minimal.nix foundation.
# Adds desktop applications, media tools, and GUI utilities.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Foundation: Development environment (includes minimal.nix)
    ./development.nix

    # Desktop-specific package collections
    ../packages/desktop.nix # GUI applications (currently minimal)
    ../packages/utilities.nix # Media processing (imagemagick, ghostscript)
  ];

  # Desktop-specific home configuration
  home.packages = with pkgs; [
    # Additional desktop packages can be added here
    # These are for packages that don't fit into the organized categories
    # libreoffice # Office suite
    # gimp        # Image editor
  ];
}
