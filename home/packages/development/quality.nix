# Code quality tools, formatters, and linters
{pkgs, ...}: {
  home.packages = with pkgs; [
    # General code quality
    shellcheck # Static analysis tool for shell scripts

    # Nix-specific tools
    nixd # Language server for Nix
    alejandra # Opinionated Nix code formatter
    deadnix # Find unused variables and functions in Nix code
    statix # Lints and suggestions for Nix code

    # Go tools (gopls needs go at build time; Nix provides it pre-compiled)
    gopls # Go language server

    # Language-specific formatters
    stylua # Opinionated Lua code formatter

    # Code statistics
    tokei # Fast code statistics

    # Git hook runner. Kept persistent (not just in devShells) so
    # .git/hooks/pre-commit keeps working outside `nix develop` and
    # survives nix-collect-garbage.
    pre-commit
  ];
}
