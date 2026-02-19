# Code quality tools, formatters, and linters
{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    # General code quality
    shellcheck # Static analysis tool for shell scripts

    # Nix-specific tools
    pkgs-unstable.nixd # Language server for Nix (unstable for latest features)
    alejandra # Opinionated Nix code formatter
    deadnix # Find unused variables and functions in Nix code
    statix # Lints and suggestions for Nix code

    # Language-specific formatters
    stylua # Opinionated Lua code formatter

    # Code statistics
    tokei # Fast code statistics

    # Note: pre-commit hooks are now managed by git-hooks.nix in flake.nix
    # The tools above are still available for standalone use
  ];
}
