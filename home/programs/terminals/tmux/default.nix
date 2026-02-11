{
  config,
  pkgs,
  ...
}: let
  homeDir = config.home.homeDirectory;
  tmux_config = builtins.readFile ./tmux.conf;

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

  tmux-sessionizer = pkgs.writeScriptBin "tmux-sessionizer" ''
    #!/usr/bin/env bash

    # Check if one argument is being provided
    if [[ $# -eq 1 ]]; then
      # Use the provided argument as the selected directory
      selected=$1
    elif [[ $# -eq 0 ]]; then
      # Use TMUX_SESSIONIZER_DIRS env var if set, otherwise use platform defaults
      if [[ -n "$TMUX_SESSIONIZER_DIRS" ]]; then
        IFS=' ' read -ra search_dirs <<< "$TMUX_SESSIONIZER_DIRS"
      else
        search_dirs=(~/github ${
      if pkgs.stdenv.isDarwin
      then ''"$HOME/Library/Mobile Documents/com~apple~CloudDocs/github" "/System/Volumes/Data/mnt"''
      else ""
    })
      fi
      selected=$(find "''${search_dirs[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | ${pkgs.fzf}/bin/fzf)
    elif [[ $# -eq 2 ]]; then
      # Use the second argument as the directory path for the find command
      dir_to_search="$2"
      # Make sure the directory exists
      if [[ -d "$dir_to_search" ]]; then
        selected=$(find "$dir_to_search" -mindepth 1 -maxdepth 1 -type d | ${pkgs.fzf}/bin/fzf)
      else
        tmux display-message -d 3000 "Directory does not exist: $dir_to_search"
        exit 1
      fi
    else
      tmux display-message -d 3000 "This script expects zero, one or two arguments."
      exit 1
    fi

    # Exit the script if no directory is selected
    if [[ -z $selected ]]; then
      exit 0
    fi

    # replace '.' and '-' with '_'
    selected_name=$(basename "$selected" | tr '.-' '__')

    # If a tmux session with the desired name does not already exist, create it in detached mode
    if ! tmux has-session -t=$selected_name 2>/dev/null; then
      tmux new-session -ds $selected_name -c "$selected"
    fi

    # If we're already inside tmux, switch to the session
    if [[ -n $TMUX ]]; then
      tmux switch-client -t $selected_name
    else
      # Otherwise attach to the session
      tmux attach-session -t $selected_name
    fi

    # If Neovim is not already running in this session, start it
    if ! tmux list-panes -t "$selected_name" -F "#{pane_current_command}" | grep -q "nvim"; then
      tmux send-keys -t "$selected_name" "nvim" C-m
    fi
  '';
in {
  imports = [];

  # Install custom tmux scripts and standard packages
  home.packages = [
    truncate_path # Custom path truncation script
    tmux-sessionizer # Custom tmux session finder
  ];
  # Note: Standard tmux packages (tmuxinator, fzf, etc.) are in home/packages/terminals.nix

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 1000000;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    escapeTime = 0;
    baseIndex = 1;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      better-mouse-mode
      yank
      sensible
      resurrect
      continuum
      tmux-thumbs # Quick pattern-copy from terminal (prefix+Space)
      fzf-tmux-url # Quick URL opening from terminal (prefix+u)
    ];

    extraConfig = ''
      ${tmux_config}
    '';
  };
}
