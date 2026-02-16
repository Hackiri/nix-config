# Darwin system configuration
{
  lib,
  system,
  ...
}: {
  imports = [
    # Shared system modules
    ../shared/nix-index.nix
    ../shared/users.nix

    # Darwin-specific modules
    ./networking.nix
    ./nix-daemon.nix
    ./preferences.nix
    ./security.nix

    # Optional feature modules
    ../../optional-features/fonts.nix

    # Service modules
    ../../services/homebrew.nix
  ];

  # Enable features
  features.fonts.enable = true;
  services.homebrew.enable = true;

  # Disable doc output to avoid builtins.toFile warning with options.json
  # Man pages and info pages remain enabled (their defaults)
  documentation.doc.enable = false;

  # System configuration
  system = {
    stateVersion = 6;
  };

  # Platform-specific nixpkgs configuration
  nixpkgs = {
    hostPlatform = lib.mkDefault "${system}";
  };

}
