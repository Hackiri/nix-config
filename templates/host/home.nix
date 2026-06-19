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
      # Darwin default. For NixOS, replace this with:
      # ../../home/profiles/platforms/nixos.nix
      ../../home/profiles/platforms/darwin.nix

      # Optional capability profiles:
      # ../../home/profiles/capabilities/kubernetes.nix
      # ../../home/profiles/capabilities/sops.nix

      # Package bundles:
      ../../home/packages/development
    ]
    # For NixOS, replace this with programRegistry.suites.workstation.nixos.
    ++ programRegistry.suites.workstation.darwin;

  # Darwin default. For NixOS, use "/home/${username}".
  home.homeDirectory = "/Users/${username}";
  home.packages = with pkgs; [];
}
