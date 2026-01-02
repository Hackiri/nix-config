{
  lib,
  pkgs,
  ...
}: {
  programs.alacritty.enable = true;

  xdg.configFile."alacritty/alacritty.toml" = {
    source = ./alacritty.toml;
  };

  # Add macOS font smoothing setting
  home.file.".config/alacritty/macos.yml".text = ''
    font:
      use_thin_strokes: false
  '';

  # Add macOS specific application symlink
  home.activation = {
    copyAlacrittyMacOSApp = let
      apps = pkgs.buildEnv {
        name = "my-apps";
        paths = [pkgs.alacritty];
        pathsToLink = "/Applications";
      };
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        baseDir="$HOME/Applications/Home Manager Apps"
        mkdir -p "$baseDir"
        for app in ${apps}/Applications/*; do
          target="$baseDir/$(basename "$app")"
          # Check if the target exists and is writable before attempting to remove it
          if [ -e "$target" ] && [ -w "$target" ]; then
            $DRY_RUN_CMD rm -rf "$target"
          elif [ -e "$target" ]; then
            echo "Warning: Cannot remove $target (permission denied). Skipping..."
            continue
          fi
          # Only copy if the source app exists
          if [ -e "$app" ]; then
            $DRY_RUN_CMD cp -rL "$app" "$target" || echo "Warning: Failed to copy $app to $target"
          fi
        done

        # Set macOS font smoothing if defaults command exists
        if command -v defaults >/dev/null 2>&1; then
          defaults write org.alacritty AppleFontSmoothing -int 0
        elif [ -x /usr/bin/defaults ]; then
          /usr/bin/defaults write org.alacritty AppleFontSmoothing -int 0
        else
          echo "Warning: 'defaults' command not found, skipping font smoothing setting"
        fi
      '';
  };
}
