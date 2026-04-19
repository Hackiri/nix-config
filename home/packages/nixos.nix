# NixOS-specific packages - only available or needed on Linux
# Imported by: home/profiles/platform/nixos-pkgs.nix
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # System Utilities (available via Homebrew on macOS)
    #--------------------------------------------------
    coreutils
    gettext
    gh # GitHub CLI

    #--------------------------------------------------
    # X11 Clipboard (macOS uses reattach-to-user-namespace)
    #--------------------------------------------------
    xclip
    xsel
  ];
}
