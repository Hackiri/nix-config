{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.hermes-agent;
  inherit (pkgs.stdenv.hostPlatform) system;
  hermesPackages = inputs.hermes-agent.packages.${system} or {};
  packageAvailable = hermesPackages ? default;
in {
  options.services.hermes-agent.enable = lib.mkEnableOption "Hermes Agent";

  config = lib.mkIf cfg.enable {
    warnings = lib.optionals (!packageAvailable) [
      "services.hermes-agent.enable is true but hermes-agent has no package for ${system} — nothing will be installed"
    ];

    environment.systemPackages = lib.optionals packageAvailable [
      hermesPackages.default
    ];
  };
}
