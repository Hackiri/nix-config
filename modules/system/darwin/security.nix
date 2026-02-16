# Darwin security configuration
# - macOS Application Firewall (native nix-darwin module)
# Note: TouchID for sudo (including tmux) is handled declaratively via
# security.pam.services.sudo_local in preferences.nix
_: {
  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
    allowSigned = true;
    allowSignedApp = true;
  };

  # Disable macOS built-in Apache httpd (HTTP-6640/6643)
  system.activationScripts.postActivation.text = ''
    /bin/launchctl disable system/org.apache.httpd 2>/dev/null || true
  '';
}
