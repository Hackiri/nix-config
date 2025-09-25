# Home Manager config for macOS
{
  config,
  pkgs,
  ...
}: {
  # Note: Program imports moved to home/profiles/macos.nix for better organization

  # macOS-specific packages
  home.packages = with pkgs; [
    # macOS-specific utilities
    mkalias                    # Tool for creating macOS aliases
    pam-reattach              # Enables Touch ID support in tmux
    reattach-to-user-namespace # macOS clipboard integration for tmux
    
    # macOS-specific applications
    aerospace                  # AeroSpace tiling window manager for macOS
    # mas                       # Mac App Store CLI (if needed)
    # dockutil                  # Dock management utility
  ];

  # Note: macOS system defaults are configured at system level in:
  # modules/system/darwin/defaults.nix (via nix-darwin)
  # This provides better integration and avoids conflicts
}
