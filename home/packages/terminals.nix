# Terminal applications and related tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Tmux Session Management
    #--------------------------------------------------
    tmuxinator # For managing complex tmux sessions
    
    #--------------------------------------------------
    # Terminal Dependencies (cross-platform)
    #--------------------------------------------------
    fzf # Required for tmux-sessionizer (fuzzy finder)
    moreutils # For sponge command used in tmux-resurrect
    # Note: reattach-to-user-namespace moved to home/darwin.nix (macOS-specific)
    
    #--------------------------------------------------
    # Additional Terminal Tools (add as needed)
    #--------------------------------------------------
  ];
}
