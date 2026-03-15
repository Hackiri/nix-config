# Darwin networking configuration
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
}
