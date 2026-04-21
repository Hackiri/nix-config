{
  inputs,
  pkgs,
  ...
}: let
  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
    config.allowDeprecatedx86_64Darwin = true;
  };
in {
  programs.kitty = {
    enable = true;
    package = unstablePkgs.kitty;

    font = {
      name = "SauceCodePro Nerd Font";
      size = 15;
    };

    settings = {
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
      hide_window_decorations = "titlebar-only";
      macos_titlebar_color = "background";
      confirm_os_window_close = 0;

      # ── Shell ─────────────────────────────────────────────────────────
      shell = "zsh --login";

      # ── macOS ─────────────────────────────────────────────────────────
      macos_option_as_alt = "right";
      macos_quit_when_last_window_closed = true;

      # ── Cursor ────────────────────────────────────────────────────────
      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      cursor_stop_blinking_after = "0";

      # ── Scrollback ────────────────────────────────────────────────────
      scrollback_lines = 10000;

      # ── Tab bar ───────────────────────────────────────────────────────
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
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
      "cmd+shift+t" = "new_tab";
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
    };
  };
}
