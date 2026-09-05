# Utility programs and configurations
_: {
  imports = [
    ./btop
    ./claude
    ./yazi
    ./aerospace
    # Note: sops config is enabled through each host's local sops.nix import.
  ];
}
