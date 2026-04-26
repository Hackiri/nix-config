{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
    config.allowDeprecatedx86_64Darwin = true;
  };
in {
  config =
    lib.mkIf
    (
      (config.profiles.development.enable or true)
      && (config.profiles.development.terminals.enable or true)
      && (config.profiles.development.terminals.default or "kitty") == "wezterm"
    )
    {
      home.packages = [unstablePkgs.wezterm];

      xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
    };
}
