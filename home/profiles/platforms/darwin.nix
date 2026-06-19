# macOS-specific profile - includes macOS desktop environment and tools
# Inherits from layers/development.nix -> layers/foundation.nix
# Adds macOS-specific applications, window management, and system integration.
{programRegistry, ...}: {
  imports = [
    # Features: Development environment (includes minimal)
    ../layers/development.nix

    # Packages: macOS-specific packages
    ../../packages/platform/darwin.nix

    # Programs: macOS window management
    programRegistry.utilities.aerospace
  ];

  profiles.development.editors.neovide.enable = true;
}
