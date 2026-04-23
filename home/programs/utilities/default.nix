# Utility programs and configurations
{...}: {
  imports = [
    ./btop
    ./claude
    ./yazi
    # Note: sops config is in home/profiles/capabilities/sops.nix (gated by profiles.sops.enable)
    # Note: aerospace config is in home/profiles/platforms/darwin.nix (platform-specific)
  ];
}
