{
  config,
  lib,
  ...
}: {
  config =
    lib.mkIf
    (
      (config.profiles.workspace.enable or true)
      && (config.profiles.workspace.terminals.enable or true)
      && (config.profiles.workspace.terminals.default or "kitty") == "alacritty"
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
