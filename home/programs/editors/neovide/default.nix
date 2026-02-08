{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.neovide;
in {
  options.modules.neovide = {
    enable = lib.mkEnableOption "neovide";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.neovide;
      description = "The neovide package to use.";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          fork = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to fork the process.";
          };

          frame = lib.mkOption {
            type = lib.types.str;
            default = "transparent";
            description = "Window frame style (full, none, transparent, buttonless).";
          };

          idle = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable idle animations.";
          };

          maximized = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to start maximized.";
          };

          noMultigrid = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Disable multigrid.";
          };

          srgb = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Use sRGB colors.";
          };

          tabs = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Show tabs.";
          };

          theme = lib.mkOption {
            type = lib.types.str;
            default = "auto";
            description = "Theme to use.";
          };

          titleHidden = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Hide window title.";
          };

          vsync = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable vsync.";
          };

          wsl = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable WSL mode.";
          };

          font = lib.mkOption {
            type = lib.types.submodule {
              options = {
                normal = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [];
                  description = "List of normal fonts to use.";
                };

                size = lib.mkOption {
                  type = lib.types.float;
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

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        neovide
      ];
    };

    # Enable neovide in home-manager
    programs.neovide = {
      enable = true;
    };

    xdg.configFile."neovide/config.toml".source = (pkgs.formats.toml {}).generate "neovide-config" {
      inherit (cfg.settings) fork frame idle maximized srgb tabs theme vsync wsl;
      no-multigrid = cfg.settings.noMultigrid;
      title-hidden = cfg.settings.titleHidden;
      font = {
        inherit (cfg.settings.font) normal size;
      };
    };
  };
}
