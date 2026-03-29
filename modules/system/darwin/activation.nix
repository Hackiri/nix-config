# System activation scripts for macOS
{
  config,
  pkgs,
  ...
}: {
  # Create macOS aliases for Nix-installed .app bundles so they appear in Spotlight/Raycast
  system.activationScripts.applications.text = let
    apps = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = ["/Applications"];
    };
  in
    pkgs.lib.mkForce ''
      echo "setting up /Applications/Nix Apps..." >&2
      rm -rf "/Applications/Nix Apps"
      mkdir -p "/Applications/Nix Apps"
      find ${apps}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';

  # Ensure Screenshots directory exists (referenced in defaults/dock.nix)
  system.activationScripts.screenshotsDir.text = ''
    mkdir -p "$HOME/Screenshots"
  '';
}
