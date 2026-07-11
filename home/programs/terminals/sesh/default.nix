{pkgs, ...}: let
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
in {
  config = {
    home.packages = [
      sesh_dev_layout
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
