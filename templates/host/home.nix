# Home Manager configuration for <HOST_NAME>
# Copy this to hosts/<name>/home.nix and edit
{
  pkgs,
  username,
  ...
}: {
  imports = [
    # Darwin default. For NixOS, replace this with:
    # ../../home/profiles/platforms/nixos.nix
    ../../home/profiles/platforms/darwin.nix

    # Program modules are managed from home/programs/default.nix.
    ../../home/programs

    # Optional capability profiles:
    # ../../home/profiles/capabilities/kubernetes.nix
    # ../../home/profiles/capabilities/sops.nix

    # Package bundles:
    ../../home/packages/development
  ];

  # Darwin default. For NixOS, use "/home/${username}".
  home.homeDirectory = "/Users/${username}";
  home.packages = with pkgs; [];
}
