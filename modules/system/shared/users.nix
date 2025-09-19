# Shared user configuration
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  # Common system packages
  environment.systemPackages = with pkgs; [
    vim
    ripgrep # Required for Neovim plugins (telescope, etc.)
    # Add more common system packages here
  ];

  # Common user settings that apply to both Darwin and NixOS
  users.users.${username} = {
    description = username;
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;
}
