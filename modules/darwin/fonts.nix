{
  config,
  lib,
  pkgs,
  ...
}: {
  fonts = {
    # Install fonts through Nix packages
    packages = with pkgs; [
      # Noto fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      # Nerd fonts
      (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "IBMPlexMono"];})
    ];
  };
}
