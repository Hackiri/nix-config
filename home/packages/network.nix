# Network utilities and tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # HTTP/Web Tools
    #--------------------------------------------------
    curl # Command line tool for transferring data with URLs
    wget # Non-interactive network downloader

    #--------------------------------------------------
    # Nix Infrastructure
    #--------------------------------------------------
    cachix # Nix binary cache client

    #--------------------------------------------------
    # Additional Network Tools (add as needed)
    #--------------------------------------------------
  ];
}
