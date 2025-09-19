# Shared base home-manager configuration
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  # Common home-manager configuration
  home = {
    inherit username;
    stateVersion = "25.05";

    # Common packages for all systems
    packages = with pkgs; [
      # Add common packages here that should be available on all systems
    ];
  };

  # Enable some useful programs
  programs = {
    home-manager.enable = true;
  };
}
