local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- General
config.font = wezterm.font_with_fallback({
  { family = "JetBrains Mono" },
  { family = "JetBrainsMono Nerd Font Mono", scale = 1.2 },
})
config.line_height = 1.2
config.font_size = 15
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.85
config.macos_window_background_blur = 64
config.window_padding = {
  left = 4,
  right = 2,
  top = 6,
  bottom = 0,
}
config.window_close_confirmation = "NeverPrompt"
config.native_macos_fullscreen_mode = true

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Cursor
config.default_cursor_style = "BlinkingBlock"

-- Scrollback
config.scrollback_lines = 10000

-- Eldritch color scheme
config.colors = {
  background = "#0D1116",
  foreground = "#ebfafa",
  cursor_bg = "#37f499",
  cursor_fg = "#0D1116",
  cursor_border = "#37f499",
  selection_bg = "#bf4f8e",
  selection_fg = "#ebfafa",
  ansi = {
    "#21222c", -- black
    "#f9515d", -- red
    "#37f499", -- green
    "#e9f941", -- yellow
    "#9071f4", -- blue
    "#f265b5", -- magenta
    "#04d1f9", -- cyan
    "#ebfafa", -- white
  },
  brights = {
    "#7081d0", -- bright black
    "#f16c75", -- bright red
    "#69f8b3", -- bright green
    "#f1fc79", -- bright yellow
    "#a48cf2", -- bright blue
    "#fd92ce", -- bright magenta
    "#66e4fd", -- bright cyan
    "#ffffff", -- bright white
  },
  tab_bar = {
    background = "#0D1116",
    active_tab = {
      bg_color = "#37f499",
      fg_color = "#0D1116",
    },
    inactive_tab = {
      bg_color = "#21222c",
      fg_color = "#ebfafa",
    },
    inactive_tab_hover = {
      bg_color = "#7081d0",
      fg_color = "#ebfafa",
    },
    new_tab = {
      bg_color = "#21222c",
      fg_color = "#ebfafa",
    },
    new_tab_hover = {
      bg_color = "#37f499",
      fg_color = "#0D1116",
    },
  },
}

-- Inactive pane dimming (like ghostty unfocused-split-opacity)
config.inactive_pane_hsb = {
  brightness = 0.7,
}

-- macOS: right Option as Alt for terminal sequences
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

-- Keys
local act = wezterm.action

config.disable_default_key_bindings = true

config.keys = {
  -- Tab management
  { key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "t", mods = "SUPER|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "w", mods = "SUPER|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "[", mods = "SUPER", action = act.ActivateTabRelative(-1) },
  { key = "[", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "]", mods = "SUPER", action = act.ActivateTabRelative(1) },
  { key = "]", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(1) },
  { key = "1", mods = "SUPER", action = act.ActivateTab(0) },
  { key = "2", mods = "SUPER", action = act.ActivateTab(1) },
  { key = "3", mods = "SUPER", action = act.ActivateTab(2) },
  { key = "4", mods = "SUPER", action = act.ActivateTab(3) },
  { key = "5", mods = "SUPER", action = act.ActivateTab(4) },
  { key = "6", mods = "SUPER", action = act.ActivateTab(5) },
  { key = "7", mods = "SUPER", action = act.ActivateTab(6) },
  { key = "8", mods = "SUPER", action = act.ActivateTab(7) },
  { key = "9", mods = "SUPER", action = act.ActivateTab(8) },

  -- Split management
  { key = "d", mods = "SUPER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "SUPER|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "LeftArrow", mods = "SUPER|ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "SUPER|ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "SUPER|ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "SUPER|ALT", action = act.ActivatePaneDirection("Down") },
  { key = "x", mods = "SUPER|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },

  -- Pane resizing
  { key = "LeftArrow", mods = "SUPER|CTRL", action = act.AdjustPaneSize({ "Left", 10 }) },
  { key = "RightArrow", mods = "SUPER|CTRL", action = act.AdjustPaneSize({ "Right", 10 }) },
  { key = "UpArrow", mods = "SUPER|CTRL", action = act.AdjustPaneSize({ "Up", 10 }) },
  { key = "DownArrow", mods = "SUPER|CTRL", action = act.AdjustPaneSize({ "Down", 10 }) },
  { key = "=", mods = "SUPER|SHIFT", action = act.PaneSelect({ mode = "SwapWithActive" }) },

  -- macOS essentials
  { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
  { key = "f", mods = "SUPER", action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "k", mods = "SUPER", action = act.ClearScrollback("ScrollbackOnly") },
  { key = "r", mods = "SUPER", action = act.ReloadConfiguration },
  { key = "q", mods = "SUPER", action = act.QuitApplication },
  { key = "0", mods = "SUPER", action = act.ResetFontSize },
  { key = "=", mods = "SUPER", action = act.IncreaseFontSize },
  { key = "-", mods = "SUPER", action = act.DecreaseFontSize },
  { key = "Enter", mods = "SUPER", action = act.ToggleFullScreen },

  -- Window management
  { key = "n", mods = "SUPER", action = act.SpawnWindow },
}

return config
