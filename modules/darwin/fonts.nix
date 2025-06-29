{
  config,
  lib,
  pkgs,
  ...
}: {
  fonts = {
    # Enable font management
    fontDir.enable = true;
    
    # Install fonts through Nix packages
    fonts = with pkgs; [
      # Noto fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      
      # Additional fonts can be added here
    ];
  };
}
