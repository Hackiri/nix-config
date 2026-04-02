# System activation scripts for macOS
{
  config,
  pkgs,
  username,
  ...
}: let
  apps = pkgs.buildEnv {
    name = "system-applications";
    paths = config.environment.systemPackages;
    pathsToLink = ["/Applications"];
  };
in {
  system.activationScripts = {
    # Create macOS aliases for Nix-installed .app bundles so they appear in Spotlight/Raycast
    applications.text = pkgs.lib.mkForce ''
      echo "setting up /Applications/Nix Apps..." >&2
      rm -rf "/Applications/Nix Apps"
      mkdir -p "/Applications/Nix Apps"
      if [ -d "${apps}/Applications" ]; then
        for app in "${apps}/Applications"/*.app; do
          [ -e "$app" ] || continue
          app_name=$(basename "$app")
          ${pkgs.mkalias}/bin/mkalias "$(readlink -f "$app")" "/Applications/Nix Apps/$app_name" \
            || echo "Warning: mkalias failed for $app_name" >&2
        done
      fi
    '';

    # Show package changes on activation (additions, removals, version changes)
    postActivation.text = ''
      if [[ -e /run/current-system ]]; then
        ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig" || true
      fi
    '';

    # Ensure Screenshots directory exists (referenced in defaults/dock.nix)
    # Uses explicit path since system activation runs as root ($HOME = /var/root)
    screenshotsDir.text = ''
      mkdir -p "/Users/${username}/Screenshots"
      chown ${username} "/Users/${username}/Screenshots"
    '';
  };
}
