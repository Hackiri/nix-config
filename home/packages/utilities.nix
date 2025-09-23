# General system utilities and tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Note: Network utilities (curl, wget, cachix) moved to network.nix
    
    # Media and document processing
    imagemagick # Image manipulation programs
    ghostscript # PostScript and PDF interpreter
    
    #--------------------------------------------------
    # Additional Utilities (add as needed)
    #--------------------------------------------------
    # ffmpeg # Multimedia framework
    # pandoc # Universal document converter
    # zip # Archive utility
    # unzip # Archive extraction utility
  ];
}
