{pkgs, ...}: let
  cfg = {
    package = pkgs.neovide;
    settings = {
      fork = false;
      frame = "transparent";
      idle = true;
      maximized = false;
      noMultigrid = false;
      srgb = false;
      tabs = true;
      theme = "auto";
      titleHidden = true;
      vsync = false;
      wsl = false;
      font = {
        normal = [];
        size = 14.0;
      };
    };
  };
in {
  config = {
    # Use HM's programs.neovide with our custom TOML config
    programs.neovide = {
      enable = true;
      inherit (cfg) package;
    };

    xdg.configFile."neovide/config.toml".source = (pkgs.formats.toml {}).generate "neovide-config" {
      inherit
        (cfg.settings)
        fork
        frame
        idle
        maximized
        srgb
        tabs
        theme
        vsync
        wsl
        ;
      no-multigrid = cfg.settings.noMultigrid;
      title-hidden = cfg.settings.titleHidden;
      font = {
        inherit (cfg.settings.font) normal size;
      };
    };
  };
}
