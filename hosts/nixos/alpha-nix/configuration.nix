{ config, pkgs, lib, inputs, ... }:

{
  # Import hardware configuration
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader configuration
  boot.initrd.availableKernelModules =
    [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.supportedFilesystems = [ "nfs" ];
  boot.initrd.kernelModules = ["nfs" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
    timeout = 60;
  };

  fileSystems."/mnt/share" = {
    device = "truenas.lab.internal:/mnt/ztank_M48A1DB/media";
    fsType = "nfs";
  };

  fileSystems."/mnt/share2" = {
    device = "truenas.lab.internal:/mnt/ztank2A7A1/ztank/storage";
    fsType = "nfs";
  };

  fileSystems."/mnt/share3" = {
    device = "truenas.lab.internal:/mnt/ztank_M1A2SEPv3/Media/Media";
    fsType = "nfs";
  };

  # Networking configuration
  networking = {
    hostName = "alpha-nix";
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "10.0.10.102";
      prefixLength = 24;
    }];
    defaultGateway = "10.0.10.1";
    nameservers = [ "10.0.254.3" ];
    domain = "lab.internal";
    search = [ "lab.internal" ];

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 32400 ];  # Allow SSH and Plex
      allowedUDPPorts = [];
    };
  };

  # Timezone and localization
  time.timeZone = "America/New_York";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  }

  # X11 keyboard configuration
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # User configuration
  users.users.hackiri = {
    isNormalUser = true;
    description = "hackiri";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;  

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System packages
  environment.systemPackages = import ../apps/default.nix {inherit pkgs;};

  environment.shells = with pkgs; [zsh]; # Shells

  # List all packages and their versions in /etc/current-system-packages
  environment.etc."current-system-packages".text = let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;
  
  # Enable Spice 
  services.spice-vdagentd.enable = true;
  services.spice-autorandr.enable = true;
  
  # Enable QEMU guest agent for Proxmox
  services.qemuGuest.enable = true;

  # Enable OpenSSH daemon
  services.openssh.enable = true;

  # mysql(mariadb)
  services.mysql = {
      enable = true;
      package = pkgs.mariadb;
  };

  services.gvfs.enable = true;

  fonts.packages = with pkgs; [
    (ibm-plex)
    (nerdfonts.override {fonts = ["JetBrainsMono" "IBMPlexMono" "Iosevka"];})
  ];

  # Podman configuration
  virtualisation = {
    containers.enable = true;
    containers.storage.settings = {
      storage = {
        driver = "overlay";
        runroot = "/run/containers/storage";
        graphroot = "/var/lib/containers/storage";
        rootless_storage_path = "/tmp/containers-$USER";
        options.overlay.mountopt = "nodev,metacopy=on";
      };
    };

    oci-containers.backend = "podman";
    podman = {
      enable = true;
      dockerCompat = true;
      # extraPackages = [ pkgs.zfs ]; # Uncomment if the host is running ZFS
    };
    #containers.cdi.dynamic.nvidia.enable = true;
  };

  # Set DOCKER_HOST for Podman Docker compatibility
  environment.extraInit = ''
    if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
      export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
    fi
  '';

  # Enable linger for some user
  systemd.tmpfiles.rules = [
    "f /var/lib/systemd/linger/hackiri"
  ];

  # Enable programs
  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  
  # Set the system state version
  system.stateVersion = "24.05";
}
