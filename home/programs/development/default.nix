# Development tools and configurations
# Note: Sops-enhanced git is enabled through each host's local sops.nix import.
_: {
  imports = [
    ./git
    ./direnv
  ];
}
