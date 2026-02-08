# Darwin security configuration
# - macOS Application Firewall (native nix-darwin module)
# Note: TouchID for sudo (including tmux) is handled declaratively via
# security.pam.services.sudo_local in defaults.nix
_: {
  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
    allowSigned = true;
    allowSignedApp = true;
  };
}
