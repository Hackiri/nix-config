# General system utilities and tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Media and document processing
    # imagemagick - Moved to neovim/default.nix (only needed for Neovim plugins)
    ghostscript # PostScript and PDF interpreter

    #--------------------------------------------------
    # Additional Utilities (add as needed)
    #--------------------------------------------------
  ];
}
