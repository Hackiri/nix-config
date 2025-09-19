# Homebrew service module
{
  config,
  lib,
  pkgs,
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
    # Homebrew configuration
    homebrew = {
      enable = true;
      onActivation = {
        cleanup = "zap"; # Uninstall packages not in Brewfile
        autoUpdate = true;
        upgrade = true;
      };
      global.autoUpdate = true;

      # Homebrew brews (CLI tools)
      brews = [
        # CLI tools that work better with Homebrew than Nix on macOS
        "mas" # Mac App Store CLI
        "bitwarden-cli" # Password manager CLI
        "coreutils" # Core utilities
        "webp" # WebP image format
        "podman-compose" # Podman Compose
        "podman" # Podman
        "wordnet" # Wordnet dictionary
      ] ++ config.services.homebrew.extraBrews;

      # Homebrew taps (repositories)
      taps = [
        # Add custom taps here if needed
      ];

      # Homebrew casks (GUI applications)
      casks = [
        # Browsers
        "firefox"
        "brave-browser"

        # Development tools
        "visual-studio-code"

        # Terminal emulators
        "iterm2"
        "ghostty"

        # Productivity
        "rectangle" # Window management
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

        # Creative
        "blender"
      ] ++ config.services.homebrew.extraCasks;

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
