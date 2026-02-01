# CLI essentials - core command-line tools used across all profiles
# These are the fundamental tools that should be available on any system.
# Imported by: home/profiles/base/minimal.nix
{pkgs, ...}: {
  home.packages = with pkgs; [
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
    fzf # Command-line fuzzy finder
    zoxide # Smarter cd command that learns your habits
    tree # Display directories as trees

    #--------------------------------------------------
    # Text and Data Processing
    #--------------------------------------------------
    jq # Lightweight JSON processor
  ];
}
