# macOS-specific profile - includes macOS desktop environment and tools
# Inherits from desktop.nix -> development.nix -> minimal.nix
# Adds macOS-specific applications, window management, and system integration.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Foundation: Desktop environment (includes development + minimal)
    ./desktop.nix

    # macOS-specific configurations
    ../darwin.nix

    # macOS-specific program configurations
    ../programs/utilities/aerospace # Window manager (macOS only)
  ];

  # macOS-specific profile configurations
  # Add any macOS-specific profile settings here

  # This profile is designed for macOS systems and includes:
  # - Essential cross-platform tools (from minimal.nix)
  # - All development tools (from development.nix)
  # - Desktop applications and media tools (from desktop.nix)
  # - macOS-specific packages and configurations (from darwin.nix)
  # - macOS window management (aerospace)
  # - macOS-specific utilities (mkalias, pam-reattach, etc.)
}
