{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    # Import shared configurations
    ../shared/base.nix
    # Import improved Darwin modules
    ../../modules/system/darwin
  ];

  # Host-specific system configuration
  system.primaryUser = username;

  # Host-specific user configuration
  users.users.${username}.home = "/Users/${username}";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
  ];

  # Host-specific services configuration

  # Home Manager is integrated via flake.nix
}
