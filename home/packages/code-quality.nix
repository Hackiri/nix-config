# Code quality tools, formatters, and linters
{pkgs, ...}: {
  home.packages = with pkgs; [
    # General code quality
    pre-commit # Framework for managing git pre-commit hooks
    shellcheck # Static analysis tool for shell scripts

    # Nix-specific tools
    nixd # Language server for Nix
    alejandra # Opinionated Nix code formatter
    deadnix # Find unused variables and functions in Nix code
    statix # Lints and suggestions for Nix code

    # Language-specific formatters
    stylua # Opinionated Lua code formatter
  ];
}
