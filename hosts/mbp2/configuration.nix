{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../modules/system/darwin

    # Host services
    ../../modules/services/darwin/hermes-agent-package.nix
  ];

  # Host-specific system configuration
  system.primaryUser = username;
  services.hermes-agent.enable = true;

  # Host-specific user configuration
  users.users.${username}.home = "/Users/${username}";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
  ];
}
