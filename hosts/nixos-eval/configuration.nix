# Evaluation-only NixOS host.
#
# This host exists so the NixOS module tree is type-checked by
# `just check-all-systems`. Without it `nixosConfigurations` is empty and
# modules/system/nixos, modules/services/nixos, and the NixOS home profile are
# never evaluated by any check.
#
# It is not deployed to a machine. The boot loader and file system settings
# below are the smallest set that lets a NixOS configuration evaluate; replace
# them with output from `nixos-generate-config` before deploying anything.
_: {
  imports = [
    ../../modules/system/nixos
    ../../modules/system/nixos/roles/workstation.nix
    ../../modules/services/nixos/desktop-gnome.nix
    ../../modules/services/nixos/pipewire.nix
    ../../modules/services/nixos/printing.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  system.stateVersion = "26.05";
}
