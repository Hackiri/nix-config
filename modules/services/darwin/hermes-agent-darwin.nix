{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  hermesPackages = inputs.hermes-agent.packages.${system} or {};
in {
  environment.systemPackages = lib.optionals (hermesPackages ? default) [
    hermesPackages.default
  ];
}
