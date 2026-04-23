# CLI essentials - core command-line tools used across all profiles
# These are the fundamental tools that should be available on any system.
# Imported by: home/profiles/layers/foundation.nix
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # System Utilities
    #--------------------------------------------------
    fastfetch # System information tool
    htop # Interactive process viewer

    #--------------------------------------------------
    # File Processing & Archives
    #--------------------------------------------------
    unzip # Extract ZIP archives
    zip # Create ZIP archives
    gzip # GNU compression utility

    #--------------------------------------------------
    # Modern CLI Replacements
    #--------------------------------------------------
    bat # Cat with syntax highlighting and Git integration
    eza # Modern replacement for ls with colors and Git status
    fd # Simple, fast alternative to find
    ripgrep # Fast text search tool (rg)

    #--------------------------------------------------
    # Navigation and Search
    #--------------------------------------------------
    zoxide # Smarter cd command that learns your habits
    tree # Display directories as trees

    #--------------------------------------------------
    # Text and Data Processing
    #--------------------------------------------------
    jq # Lightweight JSON processor
    glow # Terminal markdown renderer

    #--------------------------------------------------
    # Media and Reference
    #--------------------------------------------------
    libwebp # WebP image format tools
    wordnet # Lexical database for English
    moreutils # sponge and other small utilities (used by tmux-resurrect)
  ];
}
