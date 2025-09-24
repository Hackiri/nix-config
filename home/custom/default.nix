# Custom packages and configurations
# This directory contains packages built from your custom overlays
# and other non-standard package configurations
{...}: {
  imports = [
    ./packages.nix    # Custom overlay packages (dev-tools, devshell, etc.)
    # Add more custom configurations here as needed
    # ./scripts.nix   # Custom scripts and utilities
    # ./overlays.nix  # Package overlays and modifications
  ];
}
