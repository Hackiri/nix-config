# macOS-specific packages - only available or needed on Darwin
#
# Platform Differences from NixOS:
# --------------------------------
# - AeroSpace: macOS-only tiling window manager (NixOS has no equivalent configured)
# - pam-reattach: Enables Touch ID in tmux sessions (Linux uses different auth)
# - mkalias: Creates macOS .app aliases (Linux uses .desktop files)
# - reattach-to-user-namespace: macOS clipboard in tmux (Linux uses xclip/xsel)
#
# GUI applications are installed via Homebrew (see modules/services/homebrew.nix)
# System defaults are configured via nix-darwin (see modules/system/darwin/preferences.nix)
{pkgs, ...}: {
  home.packages = with pkgs; [
    # macOS clipboard integration for tmux
    reattach-to-user-namespace

    # macOS utilities
    mkalias # Tool for creating macOS aliases

    # Window management
    aerospace # AeroSpace tiling window manager for macOS
  ];
}
