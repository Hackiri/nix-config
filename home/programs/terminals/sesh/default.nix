{
  config,
  lib,
  pkgs,
  ...
}: let
  sesh_codex_pane = pkgs.writeScriptBin "sesh-codex-pane" ''
    #!${pkgs.bash}/bin/bash
    set +e

    if command -v codex >/dev/null 2>&1; then
      codex
      status=$?
      printf '\n[codex exited: %s]\n' "$status"
    else
      printf 'codex was not found on PATH. Install or expose the codex CLI, then rerun this pane.\n'
    fi

    exec ${pkgs.zsh}/bin/zsh -l
  '';

  sesh_git_window = pkgs.writeScriptBin "sesh-git-window" ''
    #!${pkgs.bash}/bin/bash
    set +e

    if command -v lazygit >/dev/null 2>&1; then
      lazygit
      printf '\n[lazygit exited]\n'
    else
      printf 'lazygit was not found on PATH.\n'
    fi

    exec ${pkgs.zsh}/bin/zsh -l
  '';

  # Per-project AI dev layout:
  # - dev: nvim main pane, codex side pane, shell/test pane
  # - run/git/logs/ops: long-running process and workflow windows
  # tmux only creates the extra windows the first time the session is built,
  # so re-attaching an existing sesh session keeps any windows you renamed.
  sesh_dev_layout = pkgs.writeScriptBin "sesh-dev-layout" ''
    #!${pkgs.bash}/bin/bash
    set -u

    if [ -n "''${TMUX:-}" ]; then
      current_pane="$(tmux display-message -p '#{pane_id}')"
      current_window="$(tmux display-message -p '#{window_id}')"

      ensure_window() {
        local name="$1"
        shift || true
        tmux list-windows -F '#{window_name}' 2>/dev/null | grep -Fxq "$name" && return 0
        if [ "$#" -gt 0 ]; then
          tmux new-window -d -n "$name" -c "$PWD" "$*"
        else
          tmux new-window -d -n "$name" -c "$PWD"
        fi
      }

      if [ "$(tmux show-option -qv @sesh_dev_layout_ready)" != "1" ]; then
        tmux set-option -q @sesh_dev_layout_ready 1
        tmux rename-window dev 2>/dev/null || true

        ai_pane="$(
          tmux split-window -h -d -p 34 -c "$PWD" -P -F '#{pane_id}' \
            "${sesh_codex_pane}/bin/sesh-codex-pane"
        )"
        shell_pane="$(
          tmux split-window -v -d -p 38 -t "$ai_pane" -c "$PWD" -P -F '#{pane_id}' \
            "${pkgs.zsh}/bin/zsh -l"
        )"

        tmux select-pane -t "$current_pane" -T nvim 2>/dev/null || true
        tmux select-pane -t "$ai_pane" -T codex 2>/dev/null || true
        tmux select-pane -t "$shell_pane" -T shell 2>/dev/null || true
        tmux select-layout -t "$current_window" main-vertical 2>/dev/null || true
      fi

      ensure_window run
      ensure_window git "${sesh_git_window}/bin/sesh-git-window"
      ensure_window logs
      ensure_window ops
      tmux select-window -t dev 2>/dev/null || tmux select-window -t :^ 2>/dev/null || true
      tmux select-pane -t "$current_pane" 2>/dev/null || true
    fi

    exec nvim "$@"
  '';
in {
  config =
    lib.mkIf
    (
      (config.profiles.workspace.enable or true)
      && (config.profiles.workspace.terminals.enable or true)
    )
    {
      home.packages = [
        sesh_codex_pane
        sesh_dev_layout
        sesh_git_window
      ];

      programs.sesh = {
        enable = true;
        enableTmuxIntegration = true;
        tmuxKey = "T";
        icons = true;
        settings = {
          default_session = {
            startup_command = "sesh-dev-layout";
            preview_command = "eza --all --git --icons --color=always {}";
          };
          sort_order = [
            "config"
            "tmux"
            "zoxide"
          ];
          blacklist = ["0"];
          session = [
            {
              name = "nix-config";
              path = "~/nix-config";
              startup_command = "sesh-dev-layout";
            }
          ];
          wildcard = [
            {
              pattern = "~/Projects/*";
              startup_command = "sesh-dev-layout";
            }
          ];
        };
      };
    };
}
