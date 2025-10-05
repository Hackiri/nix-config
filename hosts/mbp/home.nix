{
  config,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ../../home/profiles/darwin.nix # Darwin-specific profile (includes desktop -> development -> minimal chain)
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp-specific packages here
  ];
}
