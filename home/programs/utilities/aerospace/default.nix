{
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # Note: aerospace package is installed via home/darwin.nix

    # Source aerospace config from the home-manager store
    home.file.".aerospace.toml".source = ./aerospace.toml;
  };
}
