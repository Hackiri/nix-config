{
  pkgs,
  username,
  ...
}: {
  imports = [
    # Darwin modules
    ../../modules/system/darwin
    ../../modules/system/darwin/roles/workstation.nix
  ];

  # Host-specific system configuration
  system.primaryUser = username;
  system.stateVersion = 6;

  # Host-specific user configuration
  users.users.${username}.home = "/Users/${username}";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
  ];

  # Host-specific services configuration

  # Home Manager is integrated via flake.nix
}
