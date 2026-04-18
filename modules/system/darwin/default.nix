# Darwin system configuration
{
  config,
  lib,
  ...
}: {
  imports = [
    # Shared system modules
    ../shared/device.nix
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

    # Service modules
    ../../services/darwin/homebrew.nix
  ];

  # Enable features
  features.fonts.enable = lib.mkDefault true;
  services.homebrew.enable = true;

  # Disable doc output to avoid builtins.toFile warning with options.json
  # Man pages and info pages remain enabled (their defaults)
  documentation.doc.enable = false;

  # System configuration
  system = {
    stateVersion = 6;
  };

  # Power management
  power.sleep =
    {
      display = 15;
      computer = 30;
    }
    // lib.optionalAttrs config.device.isIntel {
      harddisk = 10; # No-op on Apple Silicon
    };
}
