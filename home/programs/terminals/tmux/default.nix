{
  config,
  lib,
  pkgs,
  ...
}: let
  homeDir = config.home.homeDirectory;
  tmux_config = builtins.readFile ./tmux.conf;
  catppuccin_plugin = "${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin";

  truncate_path = pkgs.writeScriptBin "truncate_path" ''
    #!/bin/sh

    path="$1"
    max_length="''${2:-50}"  # Default to 50 if not specified
    user_home="${homeDir}"

    # Exit if no path is provided
    if [ -z "$path" ]; then
        echo "Usage: $0 <path> [max_length]"
        exit 1
    fi

    # Replace $user_home with ~ in the path
    path="''${path/#$user_home/\~}"

    # Truncate path if it's longer than max_length
    if [ "''${#path}" -gt "$max_length" ]; then
        # Keep the last $max_length characters
        path="...''${path:$(( ''${#path} - $max_length + 3 ))}"

        # Ensure we don't break directory separators
        if ! echo "$path" | grep -q "^/\|^\\.\\./" ; then
            path="''${path#*/}"
            path=".../$path"
        fi
    fi

    echo "$path"
  '';

  git_branch = pkgs.writeScriptBin "git_branch" ''
    #!/bin/sh
    cd "$1" 2>/dev/null || exit 0
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
    if [ -n "$(git status --porcelain 2>/dev/null | head -1)" ]; then
      echo "''${branch}*"
    else
      echo "$branch"
    fi
  '';
in {
  config = lib.mkIf (config.profiles.development.terminals.enable or true) {
    home.packages = [
      truncate_path # Custom path truncation script
      git_branch # Git branch for tmux status bar
    ];

    programs.tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "tmux-256color";
      historyLimit = 1000000;
      keyMode = "vi";
      customPaneNavigationAndResize = false;
      escapeTime = 0;
      baseIndex = 1;
      mouse = true;

      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        better-mouse-mode
        yank
        sensible
        resurrect
        continuum
        tmux-thumbs # Quick pattern-copy from terminal (prefix+F)
        fzf-tmux-url # Quick URL opening from terminal (prefix+U)
        # catppuccin is loaded manually in tmux.conf to control option ordering
      ];

      extraConfig = ''
        ${tmux_config}

        # Load catppuccin AFTER options are set (home-manager runs plugins before extraConfig)
        run-shell ${catppuccin_plugin}/catppuccin.tmux

        # Custom git_branch module (defined after catppuccin creates theme variables)
        %hidden MODULE_NAME="git_branch"
        set -ogq "@catppuccin_''${MODULE_NAME}_icon" "󰊢 "
        set -ogq "@catppuccin_''${MODULE_NAME}_color" "#04d1f9"
        set -ogq "@catppuccin_''${MODULE_NAME}_text" " #(git_branch #{pane_current_path})"
        source "${catppuccin_plugin}/utils/status_module.conf"

        # Status line must be set AFTER all modules (built-in + custom) are defined
        # Left: prefix-aware session (red on prefix, catppuccin pill otherwise) + dir + zoom
        set -g  status-left "#{?client_prefix,#{#[bg=#{@thm_red},fg=#{@thm_crust},bold]  #S },#{E:@catppuccin_status_session}}"
        set -ga status-left "#[bg=default,fg=#{@thm_overlay_0},none]│"
        set -ga status-left "#[bg=default,fg=#{@thm_blue}]  #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} "
        set -ga status-left "#[bg=default,fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"
        set -ga status-left "#[bg=default,fg=#{@thm_yellow}]#{?window_zoomed_flag,  zoom ,}"
        set -g status-right "#{E:@catppuccin_status_git_branch}#{E:@catppuccin_status_date_time}"
      '';
    };
  };
}
