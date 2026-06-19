{
  config,
  lib,
  ...
}: {
  config =
    lib.mkIf
    (
      (config.profiles.development.enable or true)
      && (config.profiles.development.terminals.enable or true)
      && (config.profiles.development.terminals.default or "kitty") == "alacritty"
    )
    {
      programs.alacritty.enable = true;

      xdg.configFile."alacritty/alacritty.toml" = {
        source = ./alacritty.toml;
      };

      # Add macOS font smoothing setting
      home.file.".config/alacritty/macos.yml".text = ''
        font:
          use_thin_strokes: false
      '';
    };
}
