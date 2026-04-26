# Shared Nix daemon settings applied on all platforms
{
  lib,
  pkgs,
  ...
}: let
  commonSettings = {
    download-buffer-size = 268435456;
    auto-optimise-store = false; # Disabled: race condition (NixOS/nix#7273); run `nix-store --optimise` manually
    experimental-features = "nix-command flakes";
    extra-experimental-features = "parallel-eval";
    eval-cores = 0;
    lazy-trees = true;
  };
  toNixConf = lib.concatStringsSep "\n" (lib.mapAttrsToList (
      k: v: "${k} = ${
        if builtins.isBool v
        then lib.boolToString v
        else toString v
      }"
    )
    commonSettings);
in
  lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      nix.settings = commonSettings;
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      environment.etc."nix/nix.custom.conf".text = toNixConf;
    })
  ]
