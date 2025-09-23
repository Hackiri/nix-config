# System-specific utilities and tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # macOS-Specific Utilities
    #--------------------------------------------------
    mkalias # Tool for creating macOS aliases
    pam-reattach # Enables Touch ID support in tmux
    
    #--------------------------------------------------
    # Essential System Tools
    #--------------------------------------------------
    vim # Basic text editor (for minimal systems)
    
    #--------------------------------------------------
    # Additional System Tools (add as needed)
    #--------------------------------------------------
    # htop # Interactive process viewer
    # neofetch # System information tool
    # lsof # List open files
    # ps # Process status
  ];
}
