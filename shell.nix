# Flake-compat shim: provides the flake's default devShell for non-flake users
# Usage: nix-shell (without flakes) or direnv
(builtins.getFlake (toString ./.)).devShells.${builtins.currentSystem}.default
