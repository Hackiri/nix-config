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
  config = {
    home.packages = [unstablePkgs.wezterm];

    xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
  };
}
