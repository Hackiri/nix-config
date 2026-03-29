# Development package collections — aggregator for all dev-layer packages
# Base-layer packages (cli-essentials, network) are imported directly by profiles/base/minimal.nix
_: {
  imports = [
    ./build-tools.nix
    ./code-quality.nix
    ./databases.nix
    ./languages.nix
    ./security.nix
    ./terminals.nix
    ./web-dev.nix
  ];
}
