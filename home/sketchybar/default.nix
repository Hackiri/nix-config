{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.sketchybar;
in
{
  options.programs.sketchybar = {
    enable = mkEnableOption "SketchyBar status bar";
    
    package = mkOption {
      type = types.package;
      default = pkgs.runCommand "sketchybar-dummy" {} "mkdir -p $out";
      defaultText = literalExpression "pkgs.runCommand \"sketchybar-dummy\" {} \"mkdir -p $out\"";
      description = "The SketchyBar package to use. This is a dummy package since SketchyBar is installed via Homebrew.";
    };
  };

  config = mkIf cfg.enable {
    # SketchyBar is installed via Homebrew, so we just manage the config files
    home.file = {
      ".config/sketchybar/sketchybarrc".source = 
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/sketchybar/.config/sketchybar/sketchybarrc";
      
      ".config/sketchybar/colors.sh".source = 
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/sketchybar/.config/sketchybar/colors.sh";
      
      # Link all plugin files recursively
      ".config/sketchybar/plugins".source = 
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/sketchybar/.config/sketchybar/plugins";
    };
    
    # Add a note to remind the user to install SketchyBar via Homebrew
    home.activation.remindSketchybarInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD echo "Remember to install SketchyBar via Homebrew if not already installed:"
      $DRY_RUN_CMD echo "brew tap FelixKratz/formulae"
      $DRY_RUN_CMD echo "brew install sketchybar"
    '';
  };
}