# Shared user configuration
{
  pkgs,
  username,
  ...
}: {
  # Essential system packages (minimal set for system-wide availability)
  # Most packages are provided via home-manager profiles
  environment.systemPackages = with pkgs; [
    vim # Basic editor for system administration
    curl # Essential for system operations and package management
    coreutils # Basic file, shell and text manipulation utilities
    findutils # find, locate, updatedb, xargs
  ];

  # Common user settings that apply to both Darwin and NixOS
  users.users.${username} = {
    description = username;
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;
}
