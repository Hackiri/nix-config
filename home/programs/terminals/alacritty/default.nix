{...}: {
  programs.alacritty.enable = true;

  xdg.configFile."alacritty/alacritty.toml" = {
    source = ./alacritty.toml;
  };

  # Add macOS font smoothing setting
  home.file.".config/alacritty/macos.yml".text = ''
    font:
      use_thin_strokes: false
  '';
}
