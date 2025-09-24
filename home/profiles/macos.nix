# macOS-specific profile - includes macOS desktop environment and tools
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Base development profile (cross-platform)
    ./development.nix
    
    # macOS-specific configurations
    ../darwin.nix
    
    # macOS-specific program configurations
    ../programs/utilities/aerospace  # Window manager (macOS only)
  ];

  # macOS-specific profile configurations
  # Add any macOS-specific profile settings here
  
  # This profile is designed for macOS systems and includes:
  # - All development tools (from development.nix)
  # - macOS-specific packages and configurations (from darwin.nix)
  # - macOS window management (aerospace)
  # - macOS-specific utilities (mkalias, pam-reattach, etc.)
}
