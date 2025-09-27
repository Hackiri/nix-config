# System-agnostic utilities and tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Essential System Tools (cross-platform)
    #--------------------------------------------------
    vim # Basic text editor (for minimal systems)

    #--------------------------------------------------
    # Additional System Tools (add as needed)
    #--------------------------------------------------
    neofetch # System information tool
  ];
}
