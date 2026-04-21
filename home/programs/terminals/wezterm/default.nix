{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.profiles.development.terminals.enable or true) {
    xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
  };
}
