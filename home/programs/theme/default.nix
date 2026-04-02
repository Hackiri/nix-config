# Centralized theme module — select a palette, reference colors across configs
{
  config,
  lib,
  ...
}: let
  palettes = import ../../../lib/theme.nix;
in {
  options.theme = {
    name = lib.mkOption {
      type = lib.types.enum (builtins.attrNames palettes);
      default = "eldritch";
      description = "Active color palette name.";
    };

    colors = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      description = "Resolved color values for the active palette.";
    };
  };

  config.theme.colors = palettes.${config.theme.name};
}
