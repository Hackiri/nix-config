# Font configuration module
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.features.fonts = {
    enable = lib.mkEnableOption "font configuration";

    extraFonts = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional fonts to install";
    };
  };

  config = lib.mkIf config.features.fonts.enable {
    fonts = {
      # Install fonts through Nix packages
      packages = with pkgs;
        [
          # Nerd Fonts
          nerd-fonts.jetbrains-mono
          nerd-fonts.fira-code
          nerd-fonts.blex-mono
          nerd-fonts.hack

          # System fonts
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-emoji
        ]
        ++ config.features.fonts.extraFonts;
    };
  };
}
