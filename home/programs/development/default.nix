# Development tools and configurations
# Note: Basic git is in programs/development/git/default.nix (selected through home/programs/default.nix).
# Note: Sops-enhanced git is enabled through each host's local sops.nix import.
_: {
  imports = [
    ./direnv
  ];
}
