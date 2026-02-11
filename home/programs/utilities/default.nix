# Utility programs and configurations
{...}: {
  imports = [
    ./btop
    ./claude
    ./yazi
    # Note: sops config is in home/profiles/features/sops.nix (gated by profiles.sops.enable)
    # Note: aerospace config is in home/profiles/platform/darwin.nix (platform-specific)
  ];
}
