# Network utilities and tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # HTTP/Web Tools
    #--------------------------------------------------
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
