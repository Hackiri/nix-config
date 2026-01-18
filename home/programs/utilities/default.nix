# Utility programs and configurations
{...}: {
  imports = [
    ./btop
    ./claude
    ./yazi
    # Note: sops-nix moved to base/secrets.nix for optional inclusion
    # Note: aerospace moved to home/darwin.nix for proper platform separation
  ];
}
