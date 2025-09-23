# Terminal applications and related tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Tmux Session Management
    #--------------------------------------------------
    tmuxinator # For managing complex tmux sessions
    truncate_path # Path truncation utility for tmux
    tmux-sessionizer # Fuzzy finder for tmux sessions
    
    #--------------------------------------------------
    # Terminal Dependencies
    #--------------------------------------------------
    fzf # Required for tmux-sessionizer (fuzzy finder)
    moreutils # For sponge command used in tmux-resurrect
    reattach-to-user-namespace # macOS clipboard integration for tmux
    
    #--------------------------------------------------
    # Additional Terminal Tools (add as needed)
    #--------------------------------------------------
    # screen # Alternative terminal multiplexer
    # byobu # Enhanced terminal multiplexer
  ];
}
