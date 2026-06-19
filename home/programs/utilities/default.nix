# Utility programs and configurations
_: {
  imports = [
    ./btop
    ./claude
    ./yazi
    # Note: sops config is enabled through each host's local sops.nix import.
    # Note: Aerospace is in ./aerospace (selected through home/programs/default.nix).
  ];
}
