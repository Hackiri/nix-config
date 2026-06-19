# Utility programs and configurations
{...}: {
  imports = [
    ./btop
    ./claude
    ./yazi
    # Note: sops config is in home/profiles/capabilities/sops.nix (gated by profiles.sops.enable)
    # Note: Aerospace is in ./aerospace (selected through home/programs/default.nix and host workstation suites)
  ];
}
