# Homebrew service module
{
  config,
  lib,
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
    homebrew = {
      enable = true;
      onActivation = {
        cleanup = "uninstall"; # Remove packages not in config (preserves app data)
        autoUpdate = true;
        upgrade = true;
      };

      # CLI tools that work better with Homebrew than Nix on macOS
      brews =
        [
          "mas" # Mac App Store CLI
          "bitwarden-cli" # Password manager CLI
          "webp" # WebP image format
          "podman-compose" # Podman Compose
          "podman" # Podman
          "wordnet" # Wordnet dictionary
          "gh" # GitHub CLI
          "coreutils" # GNU coreutils (provides grealpath for yazi.nvim)
          "gettext" # GNU internationalization utilities
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

          # Terminal emulators
          "iterm2"
          "ghostty"

          # Productivity
          "raycast" # Spotlight replacement
          "shottr" # Screenshot tool

          # Communication
          "slack"
          "discord"
          "telegram"

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
