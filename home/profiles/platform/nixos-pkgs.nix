# NixOS-specific packages - only available or needed on Linux
#
# Platform Differences from Darwin:
# ---------------------------------
# - xclip/xsel: X11 clipboard utilities (macOS uses reattach-to-user-namespace)
# - XDG: Linux desktop specification (macOS uses different conventions)
# - gpg-agent: Linux service management (macOS uses launchd)
#
# Note: No window manager configured here (darwin has AeroSpace)
# Note: GUI apps installed via nixpkgs (darwin uses Homebrew)
# Note: System services in modules/system/nixos/ (darwin in modules/system/darwin/)
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Tools installed via Homebrew on macOS
    coreutils
    gettext
    gh # GitHub CLI

    # X11 clipboard utilities (equivalent to macOS clipboard integration)
    xclip
    xsel

    # Uncomment as needed:
    # gdb       # GNU debugger (Linux-specific debugging)
    # valgrind  # Memory debugging tool (Linux-only)
  ];

  # XDG configuration (Linux desktop standard)
  xdg.enable = true;
}
