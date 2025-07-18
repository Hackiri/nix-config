{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.neovide;
in {
  options.modules.neovide = {
    enable = mkEnableOption "neovide";

    package = mkOption {
      type = types.package;
      default = pkgs.neovide;
      description = "The neovide package to use.";
    };

    settings = mkOption {
      type = types.submodule {
        options = {
          fork = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to fork the process.";
          };

          frame = mkOption {
            type = types.str;
            default = "transparent";
            description = "Window frame style (full, none, transparent, buttonless).";
          };

          idle = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to enable idle animations.";
          };

          maximized = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to start maximized.";
          };

          noMultigrid = mkOption {
            type = types.bool;
            default = false;
            description = "Disable multigrid.";
          };

          srgb = mkOption {
            type = types.bool;
            default = false;
            description = "Use sRGB colors.";
          };

          tabs = mkOption {
            type = types.bool;
            default = true;
            description = "Show tabs.";
          };

          theme = mkOption {
            type = types.str;
            default = "auto";
            description = "Theme to use.";
          };

          titleHidden = mkOption {
            type = types.bool;
            default = true;
            description = "Hide window title.";
          };

          vsync = mkOption {
            type = types.bool;
            default = false;
            description = "Enable vsync.";
          };

          wsl = mkOption {
            type = types.bool;
            default = false;
            description = "Enable WSL mode.";
          };

          font = mkOption {
            type = types.submodule {
              options = {
                normal = mkOption {
                  type = types.listOf types.str;
                  default = [];
                  description = "List of normal fonts to use.";
                };

                size = mkOption {
                  type = types.float;
                  default = 14.0;
                  description = "Font size.";
                };
              };
            };
            default = {};
            description = "Font settings.";
          };
        };
      };
      default = {};
      description = "Neovide settings.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    # Enable neovide in home-manager
    programs.neovide = {
      enable = true;
    };

    xdg.configFile."neovide/config.toml" = {
      source = pkgs.writeText "neovide-config.toml" ''
        fork = ${
          if cfg.settings.fork
          then "true"
          else "false"
        }
        frame = "${cfg.settings.frame}"
        idle = ${
          if cfg.settings.idle
          then "true"
          else "false"
        }
        maximized = ${
          if cfg.settings.maximized
          then "true"
          else "false"
        }
        no-multigrid = ${
          if cfg.settings.noMultigrid
          then "true"
          else "false"
        }
        srgb = ${
          if cfg.settings.srgb
          then "true"
          else "false"
        }
        tabs = ${
          if cfg.settings.tabs
          then "true"
          else "false"
        }
        theme = "${cfg.settings.theme}"
        title-hidden = ${
          if cfg.settings.titleHidden
          then "true"
          else "false"
        }
        vsync = ${
          if cfg.settings.vsync
          then "true"
          else "false"
        }
        wsl = ${
          if cfg.settings.wsl
          then "true"
          else "false"
        }

        [font]
        normal = ${builtins.toJSON cfg.settings.font.normal}
        size = ${toString cfg.settings.font.size}
      '';
    };
  };
}
