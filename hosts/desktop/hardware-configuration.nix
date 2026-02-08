# ╔══════════════════════════════════════════════════════════════════╗
# ║  WARNING: PLACEHOLDER HARDWARE CONFIGURATION                   ║
# ║                                                                ║
# ║  This file contains PLACEHOLDER UUIDs that MUST be replaced    ║
# ║  with actual values from your target system before deploying.  ║
# ║                                                                ║
# ║  To generate real values, run on the target machine:           ║
# ║    nixos-generate-config --show-hardware-config                ║
# ║                                                                ║
# ║  Then replace ALL "REPLACE-WITH-YOUR-*-UUID" strings below.   ║
# ║  An assertion in configuration.nix will prevent deployment     ║
# ║  until all placeholders are replaced.                          ║
# ╚══════════════════════════════════════════════════════════════════╝
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Example configuration - replace with your actual hardware
  boot = {
    initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  # Example filesystem configuration - replace with your actual setup
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-ROOT-UUID";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-BOOT-UUID";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  # Example swap configuration
  swapDevices = [
    {device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-SWAP-UUID";}
  ];

  # Enables DHCP on each ethernet and wireless interface.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
