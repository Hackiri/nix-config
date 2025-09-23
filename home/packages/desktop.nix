# Desktop applications and GUI tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Window Management (macOS)
    #--------------------------------------------------
    aerospace # AeroSpace tiling window manager for macOS
    
    #--------------------------------------------------
    # Additional Desktop Applications (add as needed)
    #--------------------------------------------------
    # firefox # Web browser
    # vscode # Visual Studio Code
    # discord # Discord chat application
    # slack # Slack communication platform
    # spotify # Music streaming
    # obsidian # Note-taking application
  ];
}
