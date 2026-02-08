# Darwin security configuration
# - macOS Application Firewall
# Note: TouchID for sudo (including tmux) is handled declaratively via
# security.pam.services.sudo_local.touchIdAuth in defaults.nix
_: {
  system.activationScripts = {
    # Security: Enable macOS Application Firewall
    firewall.text = ''
      echo "Configuring macOS Firewall..." >&2
      /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on || echo "Warning: Failed to enable firewall" >&2
      /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on || echo "Warning: Failed to enable stealth mode" >&2
      /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on || echo "Warning: Failed to enable firewall logging" >&2
    '';
  };
}
