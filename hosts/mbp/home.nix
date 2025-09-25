{
  config,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ../../home/shared/base.nix
    ../../home/profiles/macos.nix  # macOS-specific profile (includes development + darwin configs)
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp-specific packages here
  ];
}
