# This file defines an overlay that adds custom packages to nixpkgs
final: prev: 

let
  # Import all packages from the pkgs directory
  customPkgs = import ../pkgs { pkgs = prev; };
in
{
  # Add all custom packages to the 'custom' namespace
  custom = customPkgs;
  
  # You can also add individual packages directly to nixpkgs if needed
  # For example:
  # dev-tools = customPkgs.dev-tools;
}
