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
      # Keep taps writable so explicit `brew update` can initialize and update
      # Homebrew's tap Git repositories. Declarative activation still seeds the
      # known taps from the flake inputs.
      mutableTaps = true;
    };

    homebrew = {
      enable = true;
      # Prevent implicit updates during install/upgrade commands; explicit
      # `brew update` remains available via nix-homebrew.mutableTaps.
      global.autoUpdate = false;
      taps = builtins.attrNames config.nix-homebrew.taps;
      caskArgs = {
        appdir = "~/Applications";
        require_sha = true;
      };
      onActivation = {
        # Leave manually installed Homebrew packages and casks in place.
        cleanup = "none";
        # Keep darwin-rebuild idempotent. Run `brew update` manually when you
        # want to update formula/cask metadata.
        autoUpdate = false;
        # Avoid activation-time package churn; upgrade Homebrew packages
        # explicitly after updating metadata.
        upgrade = false;
        extraEnv = {
          HOMEBREW_NO_ANALYTICS = "1";
          HOMEBREW_NO_ENV_HINTS = "1";
          # Keep third-party taps usable during noninteractive activation.
          HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
          HOMEBREW_NO_UPDATE_REPORT_NEW = "1";
        };
      };

      # Formulae that need Homebrew's macOS-specific packaging or third-party taps.
      # Generic CLI tools are managed through Nix/Home Manager.
      brews =
        [
          "podman" # Podman
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
