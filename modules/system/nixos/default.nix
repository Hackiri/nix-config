# NixOS system configuration
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [
    # Shared system modules
    ../shared/nix.nix
    ../shared/users.nix
    
    # Feature modules
    ../../features/fonts.nix
  ];

  # Enable features
  features.fonts.enable = true;

  # NixOS-specific user configuration
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
  };

  # Enable common services
  services.openssh.enable = true;
  
  # Enable networking
  networking.networkmanager.enable = true;

  # Security
  security.sudo.wheelNeedsPassword = false;
}
