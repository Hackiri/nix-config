# General system utilities and tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Network utilities
    curl # Command line tool for transferring data with URLs
    wget # Non-interactive network downloader

    # Media and document processing
    imagemagick # Image manipulation programs
    ghostscript # PostScript and PDF interpreter
  ];
}
