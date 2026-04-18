{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix

    # Import improved NixOS modules
    ../../modules/system/nixos

    # Host services
    ../../modules/services/nixos/hermes-agent.nix
    ../../modules/services/nixos/desktop-gnome.nix
    ../../modules/services/nixos/pipewire.nix
    ../../modules/services/nixos/printing.nix
  ];

  # Prevent accidental deployment with placeholder UUIDs from hardware-configuration.nix
  assertions = let
    hasPlaceholder = s: builtins.match ".*REPLACE-WITH-YOUR.*" s != null;
    devices =
      map (fs: fs.device or "") (builtins.attrValues config.fileSystems)
      ++ map (sw: sw.device or "") config.swapDevices;
  in [
    {
      assertion = !(builtins.any hasPlaceholder devices);
      message = "hosts/desktop/hardware-configuration.nix contains placeholder UUIDs — replace with actual values from `nixos-generate-config` before deploying";
    }
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-desktop";

  # Set your time zone
  time.timeZone = "America/New_York";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Additional desktop-specific packages
  environment.systemPackages = with pkgs; [
    firefox
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.05";
}
