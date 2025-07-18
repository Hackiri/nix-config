{
  config,
  lib,
  pkgs,
  ...
}: {
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
    ];

    # Homebrew taps (repositories)
    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/core"
      # Add more taps as needed
    ];

    # GUI Applications (Casks)
    casks = [
      # Browsers
      "firefox"
      "google-chrome"
      "brave-browser"

      # Development
      "visual-studio-code"
      "iterm2"
      "ghostty"

      # Utilities
      "rectangle" # Window manager
      "raycast" # Spotlight replacement
      "shottr" # Screenshot tool

      # Communication
      "slack"
      "discord"
      "telegram"

      # Media
      "vlc"
      "spotify"
      "iina"

      # Productivity
      "obsidian"
      "hammerspoon"
    ];

    # Mac App Store applications
    masApps = {
      # Format: "App Name" = app_id;
      "The Unarchiver" = 425424353;
      "Amphetamine" = 937984704;
      # Add more Mac App Store apps as needed

      # Apple productivity apps
      "Keynote" = 409183694;
      "Numbers" = 409203825;
      "Pages" = 409201541;

      # Apple developer tools
      "xcode" = 497799835;
    };
  };
}
