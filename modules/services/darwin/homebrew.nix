# Homebrew service module
{
  config,
  lib,
  inputs,
  pkgs,
  username,
  ...
}: {
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
      taps =
        {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "nikitabobko/homebrew-tap" = inputs.homebrew-aerospace;
          "FelixKratz/homebrew-formulae" = inputs.homebrew-felixkratz;
        }
        // lib.optionalAttrs (pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isDarwin) {
          "slp/homebrew-krun" = inputs.homebrew-krun;
        };
      mutableTaps = false;
    };

    homebrew = {
      enable = true;
      global.autoUpdate = false;
      taps = builtins.attrNames config.nix-homebrew.taps;
      caskArgs = {
        appdir = "~/Applications";
        require_sha = true;
      };
      onActivation = {
        cleanup = "zap"; # Remove packages not in config, including cask support files
        # Disabled for reproducibility -- brew updates are independent of flake.lock pins.
        # Run `brew update` manually when you want to update formulas/casks.
        autoUpdate = false;
        # Homebrew 5.1 rejects fetching casks from nix-homebrew's store-backed
        # taps; avoid activation-time cask upgrades until upstreams align.
        upgrade = false;
        extraEnv = {
          HOMEBREW_NO_ANALYTICS = "1";
          HOMEBREW_NO_ENV_HINTS = "1";
          # Homebrew 5.1 requires explicit trust for non-official taps, which
          # does not compose well with nix-homebrew's store-backed taps.
          HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
          HOMEBREW_NO_UPDATE_REPORT_NEW = "1";
        };
        extraFlags = ["--force-cleanup"];
      };

      # Formulae that need Homebrew's macOS-specific packaging or third-party taps.
      # Generic CLI tools are managed through Nix/Home Manager.
      brews =
        [
          "podman" # Podman
          "FelixKratz/formulae/borders" # JankyBorders - window border highlighting for AeroSpace
        ]
        ++ lib.optionals (pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isDarwin) [
          "krunkit"
        ]
        ++ config.services.homebrew.extraBrews;

      # GUI applications
      casks =
        [
          # Browsers
          "firefox"
          "brave-browser"

          # Development tools
          "visual-studio-code"
          "podman-desktop"
          "opencode-desktop" # Open source IDE
          "codex"

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
          "nikitabobko/tap/aerospace" # AeroSpace tiling window manager
          "pika" # Color picker

          # Creative
          "blender"
        ]
        ++ config.services.homebrew.extraCasks;

      # Mac App Store apps
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
