# Development package collections — aggregator for all dev-layer packages
# Core packages are imported directly by profiles/layers/foundation.nix
_: {
  imports = [
    ./build.nix
    ./quality.nix
    ./databases.nix
    ./languages.nix
    ./security.nix
    ./web.nix
  ];
}
