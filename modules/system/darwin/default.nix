# Darwin system configuration
{lib, ...}: {
  imports = [
    # Shared system modules
    ../shared/device.nix
    ../shared/configuration-revision.nix
    ../shared/fonts.nix
    ../shared/nix-index.nix
    ../shared/nix-settings.nix
    ../shared/users.nix

    # Darwin-specific modules
    ./networking.nix
    ./nix-daemon.nix
    ./defaults
    ./activation.nix
    ./security.nix
  ];

  # Enable features
  features.fonts.enable = lib.mkDefault true;

  # Disable doc output to avoid builtins.toFile warning with options.json
  # Man pages and info pages remain enabled (their defaults)
  documentation.doc.enable = false;

  # Power management
  power.sleep = {
    display = 15;
    computer = 30;
  };
}
