# This file defines overlays that add custom packages to nixpkgs
final: prev: let
  # Import all packages from the pkgs directory
  customPkgs = import ../pkgs {pkgs = prev;};
  
  # Import emacs overlay
  emacsOverlay = import ./emacs.nix;
in {
  # Add all custom packages to the 'custom' namespace
  custom = customPkgs;

  # Use inherit syntax to avoid warnings
  inherit (customPkgs) dev-tools devshell;
} 
// (emacsOverlay final prev) # Merge emacs overlay
