# System configuration for <HOST_NAME>
# Copy to hosts/<name>/configuration.nix and edit.
# Choose one of the two templates below.
# ── Darwin ────────────────────────────────────────────────────────────────────
{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../modules/system/darwin
    # Add host-specific service modules here, e.g.:
    # ../../modules/services/darwin/hermes-agent-package.nix
  ];

  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  environment.systemPackages = with pkgs; [];
}
# ── NixOS ─────────────────────────────────────────────────────────────────────
# {
#   pkgs,
#   ...
# }: {
#   imports = [
#     ./hardware-configuration.nix
#     ../../modules/system/nixos
#     # Add host-specific service modules here, e.g.:
#     # ../../modules/services/nixos/desktop-gnome.nix
#   ];
#
#   boot.loader.systemd-boot.enable = true;
#   boot.loader.efi.canTouchEfiVariables = true;
#
#   environment.systemPackages = with pkgs; [];
#   system.stateVersion = "25.05";
# }

