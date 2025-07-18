# Common packages with no configuration
{pkgs, ...}: {
  # Common packages for all systems that don't require specific configuration
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Core Development Tools
    #--------------------------------------------------

    # Version control
    git # Distributed version control system
    git-crypt # Transparent file encryption in git
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
    bat # Cat clone with syntax highlighting

    # Shell enhancements
    direnv # Environment switcher for the shell

    # Network utilities
    curl # Command line tool for transferring data with URLs
    wget # Non-interactive network downloader

    #--------------------------------------------------
    # Build tools and compilers
    #--------------------------------------------------
    gnumake # Build automation tool
    gcc # GNU Compiler Collection
    lldb_17 # Next generation debugger
    cmake # Cross-platform build system generator
    libtool # Generic library support script
    pkg-config # Helper tool for compiling applications

    #--------------------------------------------------
    # Media and document processing
    #--------------------------------------------------
    imagemagick # Image manipulation programs
    ghostscript # PostScript and PDF interpreter

    #--------------------------------------------------
    # Programming Languages and Runtimes
    #--------------------------------------------------

    # Node.js ecosystem
    nodejs # JavaScript runtime environment
    yarn # Fast, reliable, and secure dependency management
    pnpm # Fast, disk space efficient package manager

    # Python ecosystem (core tools)
    uv # Fast Python package installer and resolver

    # PHP
    php84Packages.composer # Dependency manager for PHP

    #--------------------------------------------------
    # Code Quality and Formatting
    #--------------------------------------------------
    pre-commit # Framework for managing git pre-commit hooks
    shellcheck # Static analysis tool for shell scripts

    # Nix-specific tools
    nixd # Language server for Nix
    alejandra # Opinionated Nix code formatter
    deadnix # Find unused variables and functions in Nix code
    statix # Lints and suggestions for Nix code

    # Language-specific formatters
    stylua # Opinionated Lua code formatter

    #--------------------------------------------------
    # Applications
    #--------------------------------------------------
  ];
}
