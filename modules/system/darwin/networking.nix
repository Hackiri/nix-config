# Darwin networking configuration
# Addresses: NETW-2705 (hostname), NAME-4404 (DNS), NAME-4028 (/etc/hosts)
_: {
  networking = {
    hostName = "mbp";
    localHostName = "mbp";
    computerName = "WM's MacBook Pro";

    # Backup DNS resolvers (Cloudflare + Quad9)
    dns = ["1.1.1.1" "9.9.9.9"];

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
    if ! /usr/bin/grep -q 'mbp' /etc/hosts; then
      printf '127.0.0.1\tmbp\n::1\t\tmbp\n' >> /etc/hosts
    fi
  '';
}
