# Shared base configuration for all hosts
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  # Common user configuration
  users.users.${username} = {
    description = username;
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Common system packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
  ];

  # Enable flakes and new command
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
