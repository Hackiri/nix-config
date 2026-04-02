# Starship prompt — palette injected from centralized theme module
{
  config,
  pkgs,
  ...
}: let
  base = builtins.fromTOML (builtins.readFile ./starship.toml);
  # Filter out semantic aliases (background, foreground, etc.) that starship doesn't understand
  starshipColors =
    builtins.removeAttrs config.theme.colors
    ["background" "foreground" "accent" "border-active" "border-inactive"];
in {
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
}
