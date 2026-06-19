# Home Manager configuration for <HOST_NAME>
# Copy this to hosts/<name>/home.nix and edit
{
  pkgs,
  username,
  ...
}: {
  imports = [
    # Pick your platform profile for behavior and platform defaults:
    # ../../home/profiles/platforms/darwin.nix
    # ../../home/profiles/platforms/nixos.nix

    # Optional capability profiles:
    # ../../home/profiles/capabilities/kubernetes.nix
    # ../../home/profiles/capabilities/sops.nix

    # Package bundles are selected with direct imports:
    # ../../home/packages/development          # full development bundle
    # ../../home/packages/development/build.nix
    # ../../home/packages/development/languages.nix
    # ../../home/packages/development/web.nix
  ];

  # Platform-specific home directory
  # Darwin: /Users/${username}
  # NixOS:  /home/${username}
  home.homeDirectory = "/Users/${username}";

  # Add user-level packages here
  home.packages = with pkgs; [];
}
