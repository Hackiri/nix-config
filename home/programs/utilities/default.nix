# Utility programs and configurations
{...}: {
  imports = [
    ./btop
    ./yazi
    ./sops-nix/sops.nix
    # Note: aerospace moved to home/darwin.nix for proper platform separation
  ];
}
