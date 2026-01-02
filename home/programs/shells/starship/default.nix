{pkgs, ...}: {
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };
}
