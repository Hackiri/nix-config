{
  config,
  pkgs,
  lib,
  ...
}: {
  # Import hardware configuration
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader Configuration
  boot = {
    initrd = {
      availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk"];
      supportedFilesystems = ["nfs"];
      kernelModules = ["nfs"];
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    loader.timeout = 60;
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
      # timeout = 60;
    };
  };

  # Filesystems
  fileSystems = {
    "/mnt/share" = {
      device = "truenas.lab.internal:/mnt/ztank_M48A1DB/media";
      fsType = "nfs";
    };
    "/mnt/share2" = {
      device = "truenas.lab.internal:/mnt/ztank2A7A1/ztank/storage";
      fsType = "nfs";
    };
    "/mnt/share3" = {
      device = "truenas.lab.internal:/mnt/ztank_M1A2SEPv3/Media/Media";
      fsType = "nfs";
    };
    "/mnt/share4" = {
      device = "truenas.lab.internal:/mnt/ztank_M48A1DB/usenet";
      fsType = "nfs";
    };
  };

  # Networking Configuration
  networking = {
    hostName = "origin-nix";
    usePredictableInterfaceNames = false;
    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.0.10.108";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "10.0.10.1";
    nameservers = ["10.0.254.3"];
    domain = "lab.internal";
    search = ["lab.internal"];

    firewall = {
      enable = true;
      allowedTCPPorts = [22 8084 7878 8989];
      allowedUDPPorts = [];
    };
  };

  # Timezone and Localization
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

  # X11 and Display Manager
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # User Configuration
  users.users.hackiri = {
    isNormalUser = true;
    description = "hackiri";
    extraGroups = ["networkmanager" "wheel"];
    # shell = pkgs.zsh;  # moved all user packages to home-manager, will cuz error????
    packages = with pkgs; [];
  };
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # System Packages and Configuration
  environment = {
    systemPackages = import ../apps/default.nix {inherit pkgs;};
    shells = with pkgs; [zsh]; # Shells
    etc."current-system-packages".text = let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
      formatted;
  };

  # Fonts Configuration
  fonts.packages = with pkgs; [
    ibm-plex
    (nerdfonts.override {fonts = ["JetBrainsMono" "IBMPlexMono" "Iosevka"];})
  ];

  environment.shellAliases = {
    pps = "podman ps --format 'table {{ .Names }}\t{{ .Status }}' --sort names";
    pclean = "podman ps -a | grep -v 'CONTAINER\|_config\|_data\|_run' | cut -c-12 | xargs podman rm 2>/dev/null";
    piclean = "podman images | grep '<none>' | grep -P '[1234567890abcdef]{12}' -o | xargs -L1 podman rmi 2>/dev/null";
  };

  # Virtualization
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
    # containers.cdi.dynamic.nvidia.enable = true; # Uncomment if host has a nvidia GPU
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

  # Services
  services = {
    spice-vdagentd.enable = true;
    spice-autorandr.enable = true;
    qemuGuest.enable = true;
    openssh.enable = true;
    gvfs.enable = true;
  };

  # Allow Unfree Packages
  nixpkgs.config.allowUnfree = true;

  # Experimental Features
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # System State Version
  system.stateVersion = "24.05";
}
