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
    ../../modules/system/darwin/roles/workstation.nix
  ];

  system.primaryUser = username;
  # New Darwin installations should use the current nix-darwin state version.
  system.stateVersion = 7;
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
#     ../../modules/system/nixos/roles/workstation.nix
#     # Add host-specific service modules here, e.g.:
#     # ../../modules/services/nixos/desktop-gnome.nix
#   ];
#
#   boot.loader.systemd-boot.enable = true;
#   boot.loader.efi.canTouchEfiVariables = true;
#
#   environment.systemPackages = with pkgs; [];
#   system.stateVersion = "26.05";
# }

