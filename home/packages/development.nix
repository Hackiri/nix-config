# Core development tools and utilities
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Version control
    git # Distributed version control system
    lazygit # Simple terminal UI for git commands
    gh # GitHub CLI for managing GitHub repos

    # Search and navigation tools
    ripgrep # Fast grep alternative with better syntax
    fd # Simple, fast and user-friendly alternative to find
    fzf # Command-line fuzzy finder
    zoxide # Smarter cd command that learns your habits

    # Text processing and display
    bat # Cat clone with syntax highlighting
    eza # Modern replacement for ls
    colordiff # Wrapper for diff with colorized output
    jq # Lightweight JSON processor

    # File and directory management
    tree # List directory contents in a tree-like format

    # Shell enhancements
    direnv # Environment switcher for the shell
  ];
}
