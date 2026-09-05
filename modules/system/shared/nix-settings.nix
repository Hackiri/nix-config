# Nix daemon settings for platforms managed by NixOS.
{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
  nix.settings.download-buffer-size = 268435456;
}
