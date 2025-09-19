{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}: {
  # Import shared home-manager modules
  imports = [
    ../../../home
  ];

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release which your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # NixOS-specific home configuration
  # Add any NixOS-specific home-manager configuration here
}
