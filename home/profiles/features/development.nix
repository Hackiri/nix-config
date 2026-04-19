# Development profile - comprehensive development environment
# This profile includes all tools and configurations needed for software development,
# including editors, development tools, terminals, and package collections.
# Inherits from base/minimal.nix for essential cross-platform tools.
#
# Feature Flags:
# All flags default to true. Set false in your host home.nix to opt out:
#
#   profiles.development.git.enable = false;      # first setup or sops-managed git
#   profiles.development.editors.enable = false;  # disable neovim, emacs, neovide
#   profiles.development.terminals.enable = false; # headless or CI hosts
#   profiles.development.shells.enable = false;   # minimal shell environments
#   profiles.development.utilities.enable = false; # disable claude statusline, yazi
#   profiles.development.devPackages.enable = false; # minimal package footprint
#
# Note: btop is always-on (imported by base/minimal.nix).
# Note: For sops-encrypted git credentials, import features/sops.nix and set
#       profiles.sops.enable = true in your host config.
{lib, ...}: {
  options.profiles.development = with lib; {
    git.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Git config: gpg, delta, difftool, mergetool, signing setup. Disable on first setup or when sops.nix manages credentials.";
    };

    editors.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Text editors: neovim (always), emacs (when features.emacs.enable), neovide (when profiles.neovide.enable).";
    };

    terminals.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Terminal emulators and multiplexers: alacritty, ghostty, kitty, wezterm, sesh, tmux.";
    };

    shells.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Shell config: zsh (with plugins, completions, fzf integrations), bash, starship prompt, aliases, direnv hook.";
    };

    utilities.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Development utilities: claude statusline script, yazi file manager. (btop is always-on via base/minimal.nix.)";
    };

    devPackages.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Development package collections: build-tools, code-quality, databases, languages, security, web-dev.";
    };
  };

  imports = [
    # Base: Foundation layer (minimal tools, btop, cli-essentials)
    ../base/minimal.nix

    # Programs: Shell configuration and enhancements (zsh, starship, bash)
    ../../programs/shells

    # Git: Basic configuration (no sops dependency)
    # For sops-encrypted git, import features/sops.nix and set profiles.sops.enable = true
    ../../programs/development/git/default.nix

    # Programs: Text editors and IDEs
    ../../programs/editors

    # Programs: Development tools and configurations (direnv - always on)
    ../../programs/development

    # Programs: Terminal emulators and multiplexers
    ../../programs/terminals

    # Programs: System utilities and file managers
    ../../programs/utilities

    # Packages: Development package collections (build tools, languages, etc.)
    ../../packages
  ];
}
