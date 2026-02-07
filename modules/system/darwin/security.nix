# Darwin security configuration
# - macOS Application Firewall
# - pam_reattach for TouchID in tmux
{pkgs, ...}: {
  system.activationScripts = {
    # Security: Enable macOS Application Firewall
    firewall.text = ''
      echo "Configuring macOS Firewall..." >&2
      /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on || echo "Warning: Failed to enable firewall" >&2
      /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on || echo "Warning: Failed to enable stealth mode" >&2
      /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on || echo "Warning: Failed to enable firewall logging" >&2
    '';

    postActivation.text = ''
      # Add pam_reattach to enable TouchID for tmux sessions
      echo "Configuring pam_reattach for TouchID in tmux..." >&2
      sudo mkdir -p /usr/local/lib/pam
      sudo cp ${pkgs.pam-reattach}/lib/pam/pam_reattach.so /usr/local/lib/pam/ || echo "Warning: Failed to copy pam_reattach.so" >&2

      if ! grep -q "pam_reattach.so" /etc/pam.d/sudo; then
        sudo sed -i "" '2i\
      auth    optional    pam_reattach.so
      ' /etc/pam.d/sudo || echo "Warning: Failed to configure pam_reattach in /etc/pam.d/sudo" >&2
      fi
    '';
  };
}
