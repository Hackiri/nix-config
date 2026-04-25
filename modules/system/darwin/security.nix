# Darwin security configuration
# - macOS Application Firewall (native nix-darwin module)
# Note: TouchID for sudo (including tmux) is handled declaratively via
# security.pam.services.sudo_local in preferences.nix
# Note: Apache httpd is disabled in modules/system/darwin/activation.nix.
_: {
  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
    allowSigned = true;
    allowSignedApp = true;
  };
}
