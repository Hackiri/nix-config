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
    # mas                       # Mac App Store CLI (if needed)
    # dockutil                  # Dock management utility
  ];

  # macOS-specific configurations
  targets.darwin.defaults = {
    # Add macOS system defaults here if needed
    # "com.apple.dock" = {
    #   autohide = true;
    #   orientation = "bottom";
    # };
  };
}
