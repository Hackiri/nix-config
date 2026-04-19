# macOS-specific packages - only available or needed on Darwin
# Imported by: home/profiles/platform/darwin.nix
#
# AeroSpace + JankyBorders installed via Homebrew (see modules/services/homebrew.nix)
# GUI applications installed via Homebrew (see modules/services/homebrew.nix)
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # macOS Clipboard & Tmux Integration
    #--------------------------------------------------
    reattach-to-user-namespace

    #--------------------------------------------------
    # macOS Utilities
    #--------------------------------------------------
    mkalias # Creates macOS .app aliases
  ];
}
