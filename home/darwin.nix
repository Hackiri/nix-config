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
    sketchybar # Highly customizable macOS status bar replacement
    aerospace # i3-like tiling window manager for macOS

    # Note: Python packages have been moved to python-pkg.nix
  ];
}
