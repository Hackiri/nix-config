# Build tools, compilers, and core development utilities
# Note: CLI essentials (bat, eza, fd, fzf, etc.) are in cli-essentials.nix
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
    meld # Visual diff and merge tool (used by git difftool/mergetool)

    # Note: direnv managed via programs.direnv
    # Note: CLI essentials (bat, eza, fd, fzf, ripgrep, etc.) in cli-essentials.nix
  ];
}
