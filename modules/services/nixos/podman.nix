# NixOS Podman configuration with Docker compatibility
{username, ...}: {
  # Podman with Docker compatibility
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Create docker alias
    dockerSocket.enable = true; # Emulate Docker socket
    defaultNetwork.settings.dns_enabled = true;
  };

  # Add user to the podman group
  users.users.${username}.extraGroups = ["podman"];
}
