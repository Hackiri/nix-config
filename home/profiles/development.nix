# Development profile - includes all development tools and editors
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Editors
    ../programs/editors/neovim
    ../programs/editors/emacs
    ../programs/editors/neovide

    # Development tools
    ../programs/development/git/git-hooks.nix
    ../programs/development/direnv
    ../programs/development/kube/kube.nix
    ../programs/development/kube/kube-config.nix
    ../programs/development/python/python-pkg.nix

    # Terminal and shell enhancements
    ../programs/terminals/tmux
    ../programs/terminals/default.nix
    ../programs/shells/starship

    # Utilities
    ../programs/utilities/btop
    ../programs/utilities/yazi
    ../programs/utilities/sops-nix/sops.nix

    # Package collections
    ../packages
  ];

  # Development-specific home configuration
  home.packages = with pkgs; [
    # Additional development packages can be added here
  ];
}
