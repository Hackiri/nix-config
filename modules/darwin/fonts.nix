{
  config,
  lib,
  pkgs,
  ...
}: {
  fonts = {
    # Install fonts through Nix packages
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.blex-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.hack
    ];
  };
}
