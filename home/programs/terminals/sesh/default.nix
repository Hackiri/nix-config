{pkgs, ...}: let
  sesh_codex_app = pkgs.writeScriptBin "sesh-codex-app" ''
    #!${pkgs.bash}/bin/bash
    set +e

    codex_bin="$(command -v codex 2>/dev/null || true)"
    [ -n "$codex_bin" ] || [ ! -x /opt/homebrew/bin/codex ] || codex_bin=/opt/homebrew/bin/codex
    [ -n "$codex_bin" ] || [ ! -x /usr/local/bin/codex ] || codex_bin=/usr/local/bin/codex

    if [ -n "$codex_bin" ]; then
      "$codex_bin" "$@"
      status=$?
      printf '\n[codex exited: %s]\n' "$status"
    else
      printf 'codex was not found on PATH. Install it with Homebrew or npm, then rerun this app.\n'
      printf 'Expected commands include: codex, /opt/homebrew/bin/codex, /usr/local/bin/codex\n'
    fi

    exec ${pkgs.zsh}/bin/zsh -l
  '';

  # Per-project dev launcher. Keep startup focused on one app; Codex, shells,
  # git, and ops workflows are launched explicitly through tmux popups/sessions.
  sesh_dev_layout = pkgs.writeScriptBin "sesh-dev-layout" ''
    #!${pkgs.bash}/bin/bash
    set -u

    if [ -n "''${TMUX:-}" ]; then
      tmux rename-window dev 2>/dev/null || true
    fi

    exec nvim "$@"
  '';

  # Explicit multi-window layout for projects that should keep several apps
  # alive in one tmux session. The default sesh startup remains single-app.
  sesh_dev_multi_layout = pkgs.writeScriptBin "sesh-dev-multi-layout" ''
    #!${pkgs.bash}/bin/bash
    set -u

    if [ -n "''${TMUX:-}" ]; then
      current_pane="$(tmux display-message -p '#{pane_id}')"

      ensure_window() {
        local name="$1"
        shift

        tmux list-windows -F '#{window_name}' 2>/dev/null | grep -Fxq "$name" && return 0
        tmux new-window -d -n "$name" -c "$PWD" "$@"
      }

      tmux rename-window dev 2>/dev/null || true
      ensure_window codex "${sesh_codex_app}/bin/sesh-codex-app"
      ensure_window shell "${pkgs.zsh}/bin/zsh" -l
      ensure_window run "${pkgs.zsh}/bin/zsh" -l
      tmux select-window -t dev 2>/dev/null || true
      tmux select-pane -t "$current_pane" 2>/dev/null || true
    fi

    exec nvim "$@"
  '';
in {
  config = {
    home.packages = [
      sesh_codex_app
      sesh_dev_layout
      sesh_dev_multi_layout
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
