# Development layer - comprehensive development workspace behavior
# This layer composes the program modules and defaults needed for software development,
# including editors, development tools, and terminals.
# Inherits from layers/foundation.nix for essential cross-platform tools.
#
# Feature Flags:
# All flags default to true unless noted. Configure them in your host home.nix:
#
#   profiles.development.enable = false;                     # opt out of the entire dev layer
#   profiles.development.editors.enable = false;            # disable all editor modules
#   profiles.development.editors.neovim.enable = false;     # disable Neovim
#   profiles.development.editors.emacs.enable = false;      # disable Doom Emacs
#   profiles.development.editors.neovide.enable = false;    # disable Neovide
#   profiles.development.shells.enable = false;             # minimal shell environments
#   profiles.development.utilities.enable = false;          # disable claude statusline, yazi
#   profiles.development.terminals.enable = false;          # disable terminal app + tmux + sesh
#   profiles.development.terminals.default = "ghostty";     # choose a terminal app
#
# Note: btop is always-on (imported by layers/foundation.nix).
# Note: For sops-encrypted git credentials, import capabilities/sops.nix and set
#       profiles.sops.enable = true in your host config.
{lib, programRegistry, ...}: {
  options.profiles.development = with lib; {
    enable =
      mkEnableOption "development profile"
      // {
        default = true;
      };

    editors = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Text editors: neovim, emacs, and neovide.";
      };

      neovim.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Neovim.";
      };

      emacs.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Doom Emacs.";
      };

      neovide.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Neovide.";
      };
    };

    shells.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Shell config: zsh (with plugins, completions, fzf integrations), bash, starship prompt, aliases, direnv hook.";
    };

    utilities.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Development utilities: claude statusline script, yazi file manager. (btop is always-on via layers/foundation.nix.)";
    };

    terminals = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Terminal tooling: the selected terminal app plus tmux and sesh.";
      };

      default = mkOption {
        type = types.enum [
          "kitty"
          "ghostty"
          "wezterm"
          "alacritty"
          "none"
        ];
        default = "kitty";
        description = "Standalone terminal app to configure for the development profile. Use \"none\" to skip the terminal app while keeping tmux and sesh; set terminals.enable = false to disable the entire terminal layer.";
      };
    };
  };

  imports =
    [
      (lib.mkAliasOptionModule [ "profiles" "workspace" ] [ "profiles" "development" ])

      # Base: Foundation layer (minimal tools, btop, cli-essentials)
      ./foundation.nix
    ]
    ++ programRegistry.suites.shell
    ++ programRegistry.suites.editors
    ++ programRegistry.suites.development
    ++ programRegistry.suites.terminals.all
    ++ [
      # Programs: System utilities and file managers
      programRegistry.utilities.claude
      programRegistry.utilities.yazi
    ];
}
