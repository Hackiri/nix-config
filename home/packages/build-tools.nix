# Build tools, compilers, and core development utilities
# Note: CLI essentials (bat, eza, fd, fzf, etc.) are in cli-essentials.nix
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Build Tools and Compilers
    #--------------------------------------------------
    gnumake # Build automation tool
    gcc # GNU Compiler Collection
    lldb # Next generation debugger
    cmake # Cross-platform build system generator
    libtool # Generic library support script
    pkg-config # Helper tool for compiling applications
    #--------------------------------------------------
    # Version Control and Git Tools
    #--------------------------------------------------
    # Note: git managed via programs.git
    lazygit # Simple terminal UI for git commands
    meld # Visual diff and merge tool (used by git difftool/mergetool)

    delta # Syntax-highlighted git diffs
    colordiff # Colorized diff output

    #--------------------------------------------------
    # Developer Workflow Tools
    #--------------------------------------------------
    hyperfine # Command benchmarking
    watchexec # File watcher for dev workflows
    tldr # Simplified man pages
    sd # Simpler sed alternative
  ];
}
