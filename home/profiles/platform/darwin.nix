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

  # macOS-specific profile configurations
  # Add any macOS-specific profile settings here

  # This profile is designed for macOS systems and includes:
  # - Essential cross-platform tools (from base/minimal.nix)
  # - All development tools (from features/development.nix)
  # - Desktop applications and media tools (from features/desktop.nix)
  # - macOS-specific packages and configurations (from darwin-pkgs.nix)
  # - macOS window management (aerospace)
  # - macOS-specific utilities (mkalias, pam-reattach, etc.)
}
