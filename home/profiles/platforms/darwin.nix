# macOS-specific profile - includes macOS desktop environment and tools
# Inherits from layers/development.nix -> layers/foundation.nix
# Adds macOS-specific applications, window management, and system integration.
_: {
  imports = [
    # Features: Development environment (includes minimal)
    ../layers/development.nix

    # Packages: macOS-specific packages
    ../../packages/platform/darwin.nix
  ];

  # nix-darwin installs fonts from modules/system/shared/fonts.nix system-wide.
  # Home Manager's Darwin target also derives a font bundle from every
  # home.packages entry and rsyncs it into ~/Library/Fonts/HomeManager. On recent
  # Determinate Nix this evaluation can intermittently fail with
  # "polling file descriptor: Invalid argument" at
  # home.file."Library/Fonts/.home-manager-fonts-version". Disable the redundant
  # per-user font sync and leave font installation to nix-darwin.
  home.file."Library/Fonts/.home-manager-fonts-version".enable = false;
}
