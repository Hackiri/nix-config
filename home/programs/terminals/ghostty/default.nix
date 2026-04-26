{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
    config.allowDeprecatedx86_64Darwin = true;
  };
in {
  config =
    lib.mkIf
    (
      (config.profiles.development.enable or true)
      && (config.profiles.development.terminals.enable or true)
      && (config.profiles.development.terminals.default or "kitty") == "ghostty"
    )
    {
      # Use the binary package because source-built Ghostty is not available on
      # Darwin in the currently pinned nixpkgs channels.
      home.packages = [unstablePkgs.ghostty-bin];

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
    };
}
