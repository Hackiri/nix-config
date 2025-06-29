{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.sketchybar;
in {
  options.programs.sketchybar = {
    enable = mkEnableOption "SketchyBar status bar";

    package = mkOption {
      type = types.package;
      default = pkgs.sketchybar;
      defaultText = literalExpression "pkgs.sketchybar";
      description = "The SketchyBar package to use.";
    };
  };

  config = mkIf cfg.enable {
    # Install SketchyBar via Nix
    home.packages = [ cfg.package ];
    home.file = {
      ".config/sketchybar/sketchybarrc".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/sketchybar/.config/sketchybar/sketchybarrc";

      ".config/sketchybar/colors.sh".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/sketchybar/.config/sketchybar/colors.sh";

      # Link all plugin files recursively
      ".config/sketchybar/plugins".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/sketchybar/.config/sketchybar/plugins";
    };

    # Add a note to remind the user to start SketchyBar
    home.activation.remindSketchybarStart = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD echo "SketchyBar is now installed via Nix. To start it, run:"
      $DRY_RUN_CMD echo "sketchybar"
    '';
    
    # Add sketchybar to PATH
    home.sessionPath = [ "${cfg.package}/bin" ];
  };
}
