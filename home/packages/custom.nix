# Custom packages from /pkgs/ directory
{pkgs, ...}: let
  customPkgs = import ../../pkgs {inherit pkgs;};
in {
  home.packages = [
    customPkgs.dev-tools
    customPkgs.devshell.script
  ];
}
