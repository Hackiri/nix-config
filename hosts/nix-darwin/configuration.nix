{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Import common modules
    ../../modules/common/darwin-common.nix
  ];

  # Host-specific system configuration
  system.primaryUser = "wm";

  # Host-specific user configuration
  users.users.wm.home = "/Users/wm";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
  ];

  # Host-specific services configuration

  # Home Manager is integrated via flake.nix
}
