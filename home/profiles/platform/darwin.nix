# macOS-specific profile - includes macOS desktop environment and tools
# Inherits from features/desktop.nix -> features/development.nix -> base/minimal.nix
# Adds macOS-specific applications, window management, and system integration.
{...}: {
  imports = [
    # Features: Desktop environment (includes development + minimal)
    ../features/desktop.nix

    # Platform: macOS-specific packages and settings
    ./darwin-pkgs.nix

    # Programs: macOS window management
    ../../programs/utilities/aerospace
  ];

  # Ensure nix-darwin and user profile paths are on PATH
  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];
}
