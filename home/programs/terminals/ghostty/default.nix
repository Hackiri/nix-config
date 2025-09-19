{
  config,
  lib,
  pkgs,
  ...
}: {
  # Ensure the config directory exists
  home.file = {
    # Main ghostty config file
    ".config/ghostty/config".source = ./config;

    # Theme configuration
    ".config/ghostty/ghostty-theme".source = ./ghostty-theme;

    # Reload script
    ".config/ghostty/reload-config.scpt".source = ./reload-config.scpt;

    # Shader directory
    ".config/ghostty/shaders" = {
      source = ./shaders;
      recursive = true;
    };
  };
}
