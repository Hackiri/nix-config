{username, ...}: let
  programRegistry = import ../../home/programs;
in {
  imports =
    [
      ../../home/profiles/platforms/nixos.nix
      ../../home/packages/development
    ]
    ++ programRegistry.suites.workstation.nixos;

  home.homeDirectory = "/home/${username}";
}
