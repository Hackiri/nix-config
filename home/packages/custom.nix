# Custom packages from /pkgs/ directory
# This file imports packages built from custom overlays and local builds
# located in the top-level /pkgs/ directory
{pkgs, ...}: let
  # Import all custom packages from /pkgs/
  customPkgs = import ../../pkgs {inherit pkgs;};
in {
  home.packages = [
    # Development tools helper script
    customPkgs.dev-tools

    # Development shell script
    customPkgs.devshell.script

    # Add more custom packages as they're created in /pkgs/
    # customPkgs.my-custom-tool
    # customPkgs.project-specific-scripts
  ];
}
