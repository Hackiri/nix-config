{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  homeDir = config.home.homeDirectory;
  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
    config.allowDeprecatedx86_64Darwin = true;
  };

  kitty_tmux = pkgs.writeScriptBin "kitty-tmux" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    exec ${pkgs.zsh}/bin/zsh -lc 'tmux attach 2>/dev/null || tmux'
  '';

  kitty_sesh = pkgs.writeScriptBin "kitty-sesh" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    exec ${pkgs.zsh}/bin/zsh -lc '
      selected="$(
        sesh list --icons |
          fzf --no-sort --ansi --border-label " sesh " --prompt "⚡  " \
            --header "enter connect  ^a all  ^t tmux  ^g configs  ^x zoxide  ^f find" \
            --bind "ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)" \
            --bind "ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)" \
            --bind "ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)" \
            --bind "ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)" \
            --bind "ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)" \
            --preview "sesh preview {}"
      )"
      [ -n "$selected" ] && exec sesh connect "$selected"
    '
  '';

  kitty_codex = pkgs.writeScriptBin "kitty-codex" ''
    #!${pkgs.bash}/bin/bash
    set +e

    codex_bin="$(command -v codex 2>/dev/null || true)"
    [ -n "$codex_bin" ] || [ ! -x /opt/homebrew/bin/codex ] || codex_bin=/opt/homebrew/bin/codex
    [ -n "$codex_bin" ] || [ ! -x /usr/local/bin/codex ] || codex_bin=/usr/local/bin/codex

    if [ -n "$codex_bin" ]; then
      "$codex_bin"
      status=$?
      printf '\n[codex exited: %s]\n' "$status"
    else
      printf 'codex was not found on PATH or in common Homebrew locations.\n'
    fi

    exec ${pkgs.zsh}/bin/zsh -l
  '';
in {
  config =
    lib.mkIf
    (
      (config.profiles.development.enable or true)
      && (config.profiles.development.terminals.enable or true)
      && (config.profiles.development.terminals.default or "kitty") == "kitty"
    )
    {
      home.packages = [
        kitty_tmux
        kitty_sesh
        kitty_codex
      ];

      # Ensure Kitty can create its per-user remote-control socket.
      home.file.".local/state/kitty/.keep".text = "";

      programs.kitty = {
        enable = true;
        package = unstablePkgs.kitty;

        font = {
          name = "SauceCodePro Nerd Font";
          size = 15;
        };

        settings = {
          # ── Shell integration ─────────────────────────────────────────────
          shell_integration = "enabled";

          # ── Background ────────────────────────────────────────────────────
          background_opacity = "0.85";
          background_blur = 64;

          # ── Eldritch color theme ──────────────────────────────────────────
          background = "#0D1116";
          foreground = "#ebfafa";
          cursor = "#37f499";
          cursor_text_color = "#0D1116";
          selection_background = "#bf4f8e";
          selection_foreground = "#ebfafa";

          # black
          color0 = "#21222c";
          color8 = "#7081d0";
          # red
          color1 = "#f9515d";
          color9 = "#f16c75";
          # green
          color2 = "#37f499";
          color10 = "#69f8b3";
          # yellow
          color3 = "#e9f941";
          color11 = "#f1fc79";
          # blue
          color4 = "#9071f4";
          color12 = "#a48cf2";
          # magenta
          color5 = "#f265b5";
          color13 = "#fd92ce";
          # cyan
          color6 = "#04d1f9";
          color14 = "#66e4fd";
          # white
          color7 = "#ebfafa";
          color15 = "#ffffff";

          # ── Window ────────────────────────────────────────────────────────
          # top right bottom left (mirrors ghostty: y=6,0 x=4,2)
          window_padding_width = "6 2 0 4";
          window_margin_width = 0;
          single_window_margin_width = 0;
          window_border_width = "1pt";
          draw_minimal_borders = true;
          active_border_color = "#37f499";
          inactive_border_color = "#21222c";
          inactive_text_alpha = "0.82";
          hide_window_decorations = "titlebar-only";
          macos_titlebar_color = "background";
          confirm_os_window_close = 0;

          # ── Layouts ───────────────────────────────────────────────────────
          # Keep tmux as the primary pane manager, but allow native Kitty layouts
          # for outer workflow tabs and occasional non-tmux tasks.
          enabled_layouts = "splits,stack,tall,fat,grid,horizontal,vertical";

          # ── Shell ─────────────────────────────────────────────────────────
          shell = "zsh --login";

          # ── macOS ─────────────────────────────────────────────────────────
          macos_option_as_alt = "right";
          macos_quit_when_last_window_closed = true;

          # ── Cursor ────────────────────────────────────────────────────────
          cursor_shape = "block";
          cursor_blink_interval = "0.5";
          cursor_stop_blinking_after = "0";
          cursor_trail = 3;
          cursor_trail_decay = "0.1 0.4";

          # ── Scrollback ────────────────────────────────────────────────────
          scrollback_lines = 10000;

          # ── URL handling ──────────────────────────────────────────────────
          url_style = "curly";
          open_url_with = "default";
          url_prefixes = "file ftp ftps gemini git gopher http https irc ircs kitty mailto news sftp ssh";
          detect_urls = true;
          allow_hyperlinks = true;

          # ── Remote control ────────────────────────────────────────────────
          # Per-user socket for scripting. Avoid the upstream shared /tmp/kitty.
          allow_remote_control = "socket-only";
          listen_on = "unix:${homeDir}/.local/state/kitty/control.sock";

          # ── Tab bar ───────────────────────────────────────────────────────
          tab_bar_edge = "bottom";
          tab_bar_margin_width = "1.0";
          tab_bar_margin_height = "1.0 0.5";
          tab_bar_style = "powerline";
          tab_powerline_style = "slanted";
          tab_title_template = "{index}: {title}";
          active_tab_title_template = "[{index}: {title}]";
          tab_fade = "0.25 0.5 0.75 1";
          tab_bar_background = "#0D1116";
          active_tab_background = "#37f499";
          active_tab_foreground = "#0D1116";
          inactive_tab_background = "#21222c";
          inactive_tab_foreground = "#ebfafa";

          # ── Performance ───────────────────────────────────────────────────
          repaint_delay = 10;
          input_delay = 3;
          sync_to_monitor = true;
        };

        keybindings = {
          # Tab management
          "cmd+t" = "new_tab";
          "cmd+shift+w" = "close_tab";
          "cmd+shift+[" = "previous_tab";
          "cmd+shift+]" = "next_tab";
          "cmd+1" = "goto_tab 1";
          "cmd+2" = "goto_tab 2";
          "cmd+3" = "goto_tab 3";
          "cmd+4" = "goto_tab 4";
          "cmd+5" = "goto_tab 5";
          "cmd+6" = "goto_tab 6";
          "cmd+7" = "goto_tab 7";
          "cmd+8" = "goto_tab 8";
          "cmd+9" = "goto_tab 9";

          # Tmux/sesh workflow launchers
          "cmd+shift+t" = "launch --type=tab --cwd=current ${kitty_tmux}/bin/kitty-tmux";
          "cmd+shift+s" = "launch --type=tab --cwd=current ${kitty_sesh}/bin/kitty-sesh";
          "cmd+shift+c" = "launch --type=tab --cwd=current ${kitty_codex}/bin/kitty-codex";

          # Split/window management
          "cmd+shift+d" = "launch --location=vsplit";
          "cmd+alt+down" = "launch --location=hsplit";
          "cmd+alt+left" = "neighboring_window left";
          "cmd+alt+right" = "neighboring_window right";
          "cmd+alt+up" = "neighboring_window top";
          "cmd+shift+x" = "close_window";

          # Resize splits
          "cmd+ctrl+left" = "resize_window narrower 10";
          "cmd+ctrl+right" = "resize_window wider 10";
          "cmd+ctrl+up" = "resize_window taller 10";
          "cmd+ctrl+down" = "resize_window shorter 10";

          # New OS window
          "cmd+n" = "new_os_window";

          # URL and config helpers
          "cmd+shift+u" = "open_url_with_hints";
          "cmd+alt+r" = "load_config_file";
        };
      };
    };
}
