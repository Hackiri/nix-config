# Desktop profile - includes GUI applications and desktop utilities
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include development profile as base
    ./development.nix

    # Desktop-specific utilities
    ../programs/utilities/aerospace
  ];

  # Desktop-specific packages
  home.packages = with pkgs; [
    # GUI applications and desktop tools can be added here
  ];
}
