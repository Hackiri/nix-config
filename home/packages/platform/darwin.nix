# macOS-specific packages - only available or needed on Darwin
# Imported by: home/profiles/platforms/darwin.nix
#
# AeroSpace + JankyBorders installed via Homebrew (see modules/services/homebrew.nix)
# GUI applications installed via Homebrew (see modules/services/homebrew.nix)
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # macOS Clipboard & Tmux Integration
    #--------------------------------------------------
    reattach-to-user-namespace

    #--------------------------------------------------
    # macOS Utilities
    #--------------------------------------------------
    mkalias # Creates macOS .app aliases

    #--------------------------------------------------
    # Nix-managed replacements for generic Homebrew formulae
    #--------------------------------------------------
    bitwarden-cli # Password manager CLI
    gemini-cli # Google Gemini CLI
    gettext # GNU internationalization utilities
    gh # GitHub CLI
    mas # Mac App Store CLI used by nix-darwin's Homebrew activation
    podman-compose # Podman Compose
    tree-sitter # Tree-sitter CLI for syntax parsing
  ];
}
