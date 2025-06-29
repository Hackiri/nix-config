{
  config,
  pkgs,
  lib,
  system,
  username,
  ...
}: {
  imports = [
    # Import the Homebrew module
    ../darwin/homebrew.nix
    # Import the fonts module
    ../darwin/fonts.nix
  ];
  # System configuration
  system = {
    stateVersion = 6;
  };

  # Nixpkgs configuration
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "${system}";
  };

  # Nix configuration
  nix = {
    enable = true;
    settings = {
      experimental-features = ["nix-command" "flakes" "ca-derivations"];
      warn-dirty = "false";
      # auto-optimise-store has been removed as it can corrupt the Nix store
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    # Garbage collection settings
    gc = {
      automatic = true;
      options = "--delete-older-than 30d"; # Keep generations for 30 days
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      }; # Run GC weekly on Sundays at 3am
    };
    # Use optimise instead of auto-optimise-store
    optimise = {
      automatic = true;
    };
  };

  # Enable nix-index for command-not-found functionality
  programs.nix-index.enable = true;

  # Common system packages
  environment.systemPackages = with pkgs; [
    vim
    ripgrep # Required for Neovim plugins (telescope, etc.)
    # Add more common system packages here
  ];

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = false;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # macOS configuration
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Always";
      NSUseAnimatedFocusRing = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      NSDocumentSaveNewDocumentsToCloud = false;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 25;
      KeyRepeat = 2;
      "com.apple.mouse.tapBehavior" = 1;
      NSWindowShouldDragOnGesture = true;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
    LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
    loginwindow.GuestEnabled = false;
    finder.FXPreferredViewStyle = "Nlsv";
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
      DisableAllAnimations = true;
      NewWindowTarget = "PfDe";
      NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowStatusBar = true;
      ShowPathbar = true;
      WarnOnEmptyTrash = false;
    };
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.dock" = {
      autohide = false;
      launchanim = false;
      static-only = false;
      show-recents = false;
      show-process-indicators = true;
      orientation = "left";
      tilesize = 36;
      minimize-to-application = true;
      mineffect = "scale";
      enable-window-tool = false;
    };
    "com.apple.ActivityMonitor" = {
      OpenMainWindow = true;
      IconType = 5;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;
    # Turn on app auto-update
    "com.apple.commerce".AutoUpdate = true;
    "com.googlecode.iterm2".PromptOnQuit = false;
    "com.google.Chrome" = {
      AppleEnableSwipeNavigateWithScrolls = true;
      DisablePrintPreview = true;
      PMPrintingExpandedStateForPrint2 = true;
    };
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      # Check for software updates daily, not just once per week
      ScheduleFrequency = 1;
      # Download newly available updates in background
      AutomaticDownload = 1;
      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };
  };

  # Configure activation scripts
  system.activationScripts = {
    postActivation.text = ''
      # Add pam_reattach to enable TouchID for tmux
      sudo mkdir -p /usr/local/lib/pam
      sudo cp ${pkgs.pam-reattach}/lib/pam/pam_reattach.so /usr/local/lib/pam/

      # Add pam_reattach to sudo config if not already present
      if ! grep -q "pam_reattach.so" /etc/pam.d/sudo; then
        sudo sed -i "" '2i\
      auth    optional    pam_reattach.so
      ' /etc/pam.d/sudo
      fi
    '';

    # Add Podman Docker compatibility setup
    podmanDockerCompat.text = ''
            # Set up Podman for Docker compatibility
            echo "Setting up Podman for Docker compatibility..." >&2

            # Create Docker compatibility symlinks
            mkdir -p $HOME/.local/bin
            ln -sf $(which podman) $HOME/.local/bin/docker
            ln -sf $(which podman-compose) $HOME/.local/bin/docker-compose

            # Ensure the bin directory is in PATH
            if ! grep -q "$HOME/.local/bin" $HOME/.zshrc; then
              echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.zshrc
            fi

            # Set up Docker socket compatibility
            mkdir -p $HOME/.docker

            # Create systemd user directory if it doesn't exist
            mkdir -p $HOME/.config/systemd/user

            # Create the service file for podman socket
            cat > $HOME/.config/systemd/user/podman.socket << EOF
      [Unit]
      Description=Podman API Socket
      Documentation=man:podman-system-service(1)

      [Socket]
      ListenStream=%t/podman/podman.sock
      SocketMode=0660

      [Install]
      WantedBy=sockets.target
      EOF

            # Create the service file
            cat > $HOME/.config/systemd/user/podman.service << EOF
      [Unit]
      Description=Podman API Service
      Requires=podman.socket
      After=podman.socket
      Documentation=man:podman-system-service(1)

      [Service]
      Type=simple
      ExecStart=/usr/local/bin/podman system service --time=0

      [Install]
      WantedBy=default.target
      EOF

            # Add Docker environment variables to zshrc if not already present
            if ! grep -q "DOCKER_HOST" $HOME/.zshrc; then
              echo 'export DOCKER_HOST="unix://$HOME/.local/share/containers/podman/machine/qemu/podman.sock"' >> $HOME/.zshrc
            fi
    '';
  };

  # Home Manager configuration
  home-manager.users.${username} = _: {
    home.sessionPath = [
      "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
    ];
  };
}
