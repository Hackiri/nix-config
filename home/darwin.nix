# Home Manager config for macOS
{
  config,
  pkgs,
  ...
}: {
  # Note: macOS-specific packages moved to home/packages/system.nix and network.nix
  # Note: aerospace configuration is now handled through programs/utilities/default.nix
  # This keeps darwin.nix focused on macOS-specific system configurations
}
