# Home Manager config for macOS
{
  config,
  pkgs,
  ...
}: {
  # macOS-specific packages
  home.packages = with pkgs; [
    # macOS-specific utilities
    mkalias # Tool for creating macOS aliases
    pam-reattach # Enables Touch ID support in tmux
    cachix # Nix binary cache client

    # Note: Python packages have been moved to python-pkg.nix
  ];
}
