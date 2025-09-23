# Utility programs and configurations
{...}: {
  imports = [
    ./btop
    ./yazi
    ./sops-nix/sops.nix
    ./aerospace  # macOS window manager (conditionally enabled)
  ];
}
