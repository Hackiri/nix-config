# Starship prompt — palette injected from centralized theme module
{
  config,
  lib,
  pkgs,
  ...
}: let
  base = builtins.fromTOML (builtins.readFile ./starship.toml);
  # Filter out semantic aliases (background, foreground, etc.) that starship doesn't understand
  starshipColors =
    builtins.removeAttrs config.theme.colors
    ["background" "foreground" "accent" "border-active" "border-inactive"];
in {
  config =
    lib.mkIf (
      (config.profiles.development.enable or true)
      && (config.profiles.development.shells.enable or true)
    ) {
      programs.starship = {
        enable = true;
        package = pkgs.starship;
        settings =
          base
          // {
            palette = config.theme.name;
            palettes.${config.theme.name} = starshipColors;
          };
      };
    };
}
