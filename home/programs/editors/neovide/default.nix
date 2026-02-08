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
