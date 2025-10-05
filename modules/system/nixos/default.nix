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

    # Optional feature modules
    ../../optional-features/fonts.nix
  ];

  # Enable features
  features.fonts.enable = true;

  # Disable command-not-found to avoid conflicts with nix-index (from shared/nix.nix)
  programs.command-not-found.enable = lib.mkForce false;

  # NixOS-specific user configuration
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
  };

  # Enable common services
  services.openssh.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Security configuration
  security = {
    sudo = {
      wheelNeedsPassword = false;
      execWheelOnly = true;  # Only allow wheel group to use sudo
    };
  };
}
