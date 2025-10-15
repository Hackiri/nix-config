# Home Manager config for Darwin (macOS)
{
  config,
  pkgs,
  ...
}: {
  # Note: Program imports moved to home/profiles/darwin.nix for better organization

  # Darwin-specific packages
  home.packages = with pkgs; [
    # Darwin-specific utilities
    mkalias # Tool for creating macOS aliases
    pam-reattach # Enables Touch ID support in tmux
    reattach-to-user-namespace # macOS clipboard integration for tmux

    # Darwin-specific applications
    aerospace # AeroSpace tiling window manager for macOS
    # mas                       # Mac App Store CLI (if needed)
    # dockutil                  # Dock management utility
  ];

  # Note: Darwin system defaults are configured at system level in:
  # modules/system/darwin/defaults.nix (via nix-darwin)
  # This provides better integration and avoids conflicts
}
