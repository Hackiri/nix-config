# Development tools and utilities
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Build Tools and Compilers
    #--------------------------------------------------
    gnumake # Build automation tool
    gcc # GNU Compiler Collection
    lldb_17 # Next generation debugger
    cmake # Cross-platform build system generator
    libtool # Generic library support script
    pkg-config # Helper tool for compiling applications

    #--------------------------------------------------
    # Version Control and Git Tools
    #--------------------------------------------------
    # Note: git managed via programs.git
    lazygit # Simple terminal UI for git commands
    gh # GitHub CLI for managing GitHub repos

    #--------------------------------------------------
    # Search and Navigation Tools
    #--------------------------------------------------
    # Note: ripgrep installed system-wide
    fd # Simple, fast and user-friendly alternative to find
    fzf # Command-line fuzzy finder
    zoxide # Smarter cd command that learns your habits

    #--------------------------------------------------
    # Text Processing and Display
    #--------------------------------------------------
    bat # Cat clone with syntax highlighting
    eza # Modern replacement for ls
    colordiff # Wrapper for diff with colorized output
    jq # Lightweight JSON processor

    #--------------------------------------------------
    # File and Directory Management
    #--------------------------------------------------
    tree # List directory contents in a tree-like format

    # Note: direnv managed via programs.direnv
    # Note: Shell enhancements and other tools in separate package files
  ];
}
