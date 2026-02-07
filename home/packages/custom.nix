# Custom packages from /pkgs/ directory
{
  config,
  lib,
  pkgs,
  ...
}: let
  customPkgs = import ../../pkgs {inherit pkgs;};
in {
  config = lib.mkIf config.features.development.packages.custom.enable {
    home.packages = [
      customPkgs.dev-tools
      customPkgs.devshell.script
    ];
  };
}
