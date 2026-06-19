# macOS-specific profile - includes macOS desktop environment and tools
# Inherits from layers/development.nix -> layers/foundation.nix
# Adds macOS-specific applications, window management, and system integration.
{...}: {
  imports = [
    # Features: Development environment (includes minimal)
    ../layers/development.nix

    # Packages: macOS-specific packages
    ../../packages/platform/darwin.nix

    # Programs: macOS window management
    ../../programs/utilities/aerospace
  ];

  profiles.development.editors.neovide.enable = true;
}
