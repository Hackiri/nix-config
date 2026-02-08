# NixOS system configuration
{
  lib,
  username,
  ...
}: {
  imports = [
    # Shared system modules
    ../shared/nix.nix
    ../shared/users.nix

    # NixOS-specific modules
    ./nix.nix
    ./podman.nix
    ./security.nix

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
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Ensure ~/.local/bin is in PATH
  environment.sessionVariables = {
    PATH = ["$HOME/.local/bin"];
  };
}
