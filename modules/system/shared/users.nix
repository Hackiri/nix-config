# Shared user configuration
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  # Essential system packages (minimal set for system-wide availability)
  # Note: Most packages are now provided via home-manager profiles
  environment.systemPackages = with pkgs; [
    # Essential system tools (needed for root, system recovery, etc.)
    vim          # Basic editor for system administration
    curl         # Essential for system operations and package management
    
    # Core utilities that should be available system-wide
    coreutils    # Basic file, shell and text manipulation utilities
    findutils    # find, locate, updatedb, xargs
    
    # Note: ripgrep moved to home-manager profiles (minimal.nix)
    # Note: Other development tools are in home-manager profiles
  ];

  # Common user settings that apply to both Darwin and NixOS
  users.users.${username} = {
    description = username;
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;
}
