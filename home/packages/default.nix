# Main package collection - imports all package categories
{pkgs, ...}: {
  imports = [
    ./cli-tools.nix
    ./build-tools.nix
    ./languages.nix
    ./code-quality.nix
    ./utilities.nix
    ./custom.nix
  ];
}
