# Home Manager configuration for <HOST_NAME>
# Copy this to hosts/<name>/home.nix and edit
{
  pkgs,
  username,
  ...
}: let
  programRegistry = import ../../home/programs;
in {
  imports =
    [
      # Pick your platform profile for behavior and platform defaults:
      # ../../home/profiles/platforms/darwin.nix
      # ../../home/profiles/platforms/nixos.nix

      # Optional capability profiles:
      # ../../home/profiles/capabilities/kubernetes.nix
      # ../../home/profiles/capabilities/sops.nix

      # Package bundles:
      # ../../home/packages/development
    ]
    # Pick one program suite:
    # ++ programRegistry.suites.workstation.darwin
    # ++ programRegistry.suites.workstation.nixos
    ;

  home.homeDirectory = "/Users/${username}";
  home.packages = with pkgs; [];
}
