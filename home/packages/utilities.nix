# General system utilities and tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Media and document processing
    imagemagick # Image manipulation programs
    ghostscript # PostScript and PDF interpreter
    
    #--------------------------------------------------
    # Additional Utilities (add as needed)
    #--------------------------------------------------
  ];
}
