# Home Manager configuration for <HOST_NAME>
# Copy this to hosts/<name>/home.nix and edit
{
  pkgs,
  username,
  ...
}: {
  imports = [
    # Pick your platform profile (includes development -> minimal chain):
    # ../../home/profiles/platforms/darwin.nix
    # ../../home/profiles/platforms/nixos.nix

    # Pick one terminal emulator module:
    # ../../home/programs/terminals/kitty
    # ../../home/programs/terminals/alacritty
    # ../../home/programs/terminals/ghostty
    # ../../home/programs/terminals/wezterm

    # Optional feature profiles:
    # ../../home/profiles/layers/development.nix
    # ../../home/profiles/capabilities/kubernetes.nix
    # ../../home/profiles/capabilities/sops.nix
  ];

  # Platform-specific home directory
  # Darwin: /Users/${username}
  # NixOS:  /home/${username}
  home.homeDirectory = "/Users/${username}";

  # Add user-level packages here
  home.packages = with pkgs; [];
}
