# System configuration for <HOST_NAME>
# Copy this to hosts/<name>/configuration.nix and edit
{
  pkgs,
  username,
  ...
}: {
  imports = [
    # Darwin: ../../modules/system/darwin
    # NixOS:  ../../modules/system/nixos
  ];

  # Darwin: set primary user
  # system.primaryUser = username;

  # User configuration
  users.users.${username}.home = "/Users/${username}";

  # Add system-level packages here
  environment.systemPackages = with pkgs; [];
}
