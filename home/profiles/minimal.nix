# Minimal profile - basic tools only
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Basic shell enhancements
    ../programs/shells/default.nix

    # Essential utilities
    ../programs/utilities/btop
  ];

  # Note: Essential packages are now provided by home/packages/system.nix
  # This keeps the minimal profile focused on importing essential modules
}
