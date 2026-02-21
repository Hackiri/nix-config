# Darwin networking configuration
# Addresses: NAME-4404 (DNS), NAME-4028 (/etc/hosts)
_: {
  networking = {
    # Backup DNS resolvers (Cloudflare + Quad9)
    dns = ["1.1.1.1" "9.9.9.9"];

    # Common macOS network service names. Update this list if your hardware
    # has different interface names (check: networksetup -listallnetworkservices).
    knownNetworkServices = [
      "Wi-Fi"
      "USB 10/100/1000 LAN 2"
      "Thunderbolt Bridge"
      "iPad USB"
      "iPhone USB"
    ];
  };

  # Append hostname to /etc/hosts after networking activation restores it (NAME-4028)
  # nix-darwin lacks a stable networking.hosts option (GH #1035)
  system.activationScripts.postActivation.text = ''
    hn=$(/usr/sbin/scutil --get LocalHostName 2>/dev/null || hostname -s)
    if ! /usr/bin/grep -q "$hn" /etc/hosts; then
      printf '127.0.0.1\t%s\n::1\t\t%s\n' "$hn" "$hn" >> /etc/hosts
    fi
  '';
}
