{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/nixos
    ../../modules/services/nixos/hermes-agent.nix
    ../../modules/services/nixos/desktop-gnome.nix
    ../../modules/services/nixos/pipewire.nix
    ../../modules/services/nixos/printing.nix
  ];

  assertions = let
    hasPlaceholder = s: builtins.match ".*REPLACE-WITH-YOUR.*" s != null;
    devices =
      map (fs: fs.device or "") (builtins.attrValues config.fileSystems)
      ++ map (sw: sw.device or "") config.swapDevices;
  in [
    {
      assertion = !(builtins.any hasPlaceholder devices);
      message = "templates/nixos-desktop/hardware-configuration.nix contains placeholder UUIDs; replace them with values from `nixos-generate-config` before deploying";
    }
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/New_York";

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

  environment.systemPackages = with pkgs; [
    firefox
  ];

  system.stateVersion = "25.05";
}
