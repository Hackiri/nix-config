{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.programs.aerospace;
in {
  options.my.programs.aerospace = {
    enable = mkEnableOption "AeroSpace window manager";

    package = mkOption {
      type = types.package;
      default = pkgs.aerospace;
      defaultText = literalExpression "pkgs.aerospace";
      description = "The AeroSpace package to use.";
    };
  };

  config = mkIf cfg.enable {
    # Install AeroSpace via Nix
    home = {
      packages = [cfg.package];

      file = {
        ".config/aerospace/aerospace.toml" = lib.mkForce {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/aerospace/.config/aerospace/aerospace.toml";
        };
      };

      activation.remindAerospaceStart = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD echo "AeroSpace is now installed via Nix. To start it, run:"
        $DRY_RUN_CMD echo "aerospace start"
      '';

      # Add aerospace to PATH
      sessionPath = ["${cfg.package}/bin"];
    };

    programs.aerospace = {
      enable = true;
      inherit (cfg) package;
      userSettings = lib.mkForce {
        after-startup-command = [
          "exec-and-forget echo 'AeroSpace config is managed by Nix'"
        ];
      };
    };
  };
}
