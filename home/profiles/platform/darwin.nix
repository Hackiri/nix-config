# macOS-specific profile - includes macOS desktop environment and tools
# Inherits from features/development.nix -> base/minimal.nix
# Adds macOS-specific applications, window management, and system integration.
{...}: {
  imports = [
    # Features: Development environment (includes minimal)
    ../features/development.nix

    # Packages: macOS-specific packages
    ../../packages/darwin.nix

    # Programs: macOS window management
    ../../programs/utilities/aerospace
  ];

  # Ensure nix-darwin and user profile paths are on PATH
  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];

  profiles.neovide.enable = true;
}
