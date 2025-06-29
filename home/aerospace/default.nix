{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.aerospace;
in
{
  options.programs.aerospace = {
    enable = mkEnableOption "AeroSpace window manager";
    
    package = mkOption {
      type = types.package;
      default = pkgs.runCommand "aerospace-dummy" {} "mkdir -p $out";
      defaultText = literalExpression "pkgs.runCommand \"aerospace-dummy\" {} \"mkdir -p $out\"";
      description = "The AeroSpace package to use. This is a dummy package since AeroSpace is installed via Homebrew.";
    };
  };

  config = mkIf cfg.enable {
    # AeroSpace is installed via Homebrew, so we just manage the config file
    home.file.".config/aerospace/aerospace.toml".source = 
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/aerospace/.config/aerospace/aerospace.toml";
    
    # Add a note to remind the user to install AeroSpace via Homebrew
    home.activation.remindAerospaceInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD echo "Remember to install AeroSpace via Homebrew if not already installed:"
      $DRY_RUN_CMD echo "brew install --cask nikitabobko/tap/aerospace"
    '';
  };
}