# Homebrew service module
{
  config,
  lib,
  inputs,
  pkgs,
  username,
  ...
}: let
  isAppleSiliconDarwin = pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isDarwin;
  managedTaps =
    {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "nikitabobko/homebrew-tap" = inputs.homebrew-aerospace;
      "FelixKratz/homebrew-formulae" = inputs.homebrew-felixkratz;
    }
    // lib.optionalAttrs isAppleSiliconDarwin {
      "slp/homebrew-krun" = inputs.homebrew-krun;
    };
  trustedTapNames =
    [
      "FelixKratz/homebrew-formulae"
      "nikitabobko/homebrew-tap"
    ]
    ++ lib.optionals isAppleSiliconDarwin [
      "slp/homebrew-krun"
    ];
  renderTap = name:
    if builtins.elem name trustedTapNames
    then {
      inherit name;
      trusted = true;
    }
    else name;
in {
  options.services.homebrew = {
    enable = lib.mkEnableOption "Homebrew package manager";

    extraBrews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional Homebrew packages to install";
    };

    extraCasks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional Homebrew casks to install";
    };
  };

  config = lib.mkIf config.services.homebrew.enable {
    # nix-homebrew configuration (moved from flake.nix for encapsulation)
    nix-homebrew = {
      enable = true;
      user = username;
      autoMigrate = true;
      taps = managedTaps;
      mutableTaps = false;
      trust.taps = trustedTapNames;
    };

    homebrew = {
      enable = true;
      global.autoUpdate = false;
      taps = map renderTap (builtins.attrNames config.nix-homebrew.taps);
      caskArgs = {
        appdir = "~/Applications";
        require_sha = true;
      };
      onActivation = {
        # Report unmanaged packages and abort activation rather than deleting
        # applications or their support files.
        cleanup = "check";
        # Disabled for reproducibility -- brew updates are independent of flake.lock pins.
        # Update Homebrew metadata by updating the flake inputs.
        autoUpdate = false;
        # Keep activation idempotent; update Homebrew packages by updating the flake inputs.
        upgrade = false;
        extraEnv = {
          HOMEBREW_NO_ANALYTICS = "1";
          HOMEBREW_NO_ENV_HINTS = "1";
          HOMEBREW_NO_UPDATE_REPORT_NEW = "1";
        };
      };

      # Formulae that need Homebrew's macOS-specific packaging or third-party taps.
      # Generic CLI tools are managed through Nix/Home Manager.
      brews =
        [
          # Explicitly include the installed dependency closure because
          # `brew bundle cleanup` check mode treats undeclared dependencies as drift.
          "ca-certificates"
          "dav1d"
          "libyaml"
          "dtc"
          "mpg123"
          "lame"
          "libvmaf"
          "libvpx"
          "openssl@3"
          "opus"
          "sdl3"
          "sdl2-compat"
          "svt-av1"
          "x264"
          "x265"
          "ffmpeg"
          "gitleaks"
          "libepoxy"
          "molten-vk"
          "xz"
          "podman" # Podman
          "kdash" # Kubernetes dashboard TUI (removed from nixpkgs 2026-06-11)
        ]
        ++ lib.optionals isAppleSiliconDarwin [
          "slp/krun/gvproxy"
          "slp/krun/libkrunfw"
          "slp/krun/virglrenderer"
          "slp/krun/libkrun"
          "krunkit"
        ]
        ++ config.services.homebrew.extraBrews;

      # GUI applications
      casks =
        [
          # Browsers
          "firefox"
          "librewolf"

          # Development tools
          "visual-studio-code"
          "podman-desktop"
          "opencode-desktop" # Open source IDE
          "codex"
          "supacode"

          # Productivity
          "raycast" # Spotlight replacement
          "shottr" # Screenshot tool

          # Communication
          "slack"
          "discord"

          # Media
          "vlc"
          "iina" # Video player

          # Utilities
          "obsidian" # Note-taking
          "hammerspoon" # Automation
          "pika" # Color picker

          # Creative
          "blender"
        ]
        ++ config.services.homebrew.extraCasks;

      # MAS installs are mutable and non-reproducible: Apple controls the
      # delivered version and availability independently of flake.lock.
      masApps = {
        "Amphetamine" = 937984704;
        "Keynote" = 409183694;
        "Numbers" = 409203825;
        "Pages" = 409201541;
        "The Unarchiver" = 425424353;
      };
    };
  };
}
