{
  config,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ../../home/shared/base.nix
    ../../home/common.nix
    ../../home/darwin.nix
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp-specific packages here
  ];
}
