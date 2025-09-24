{
  config,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ../../home/shared/base.nix
    ../../home/profiles/macos.nix  # Use macOS-specific profile instead of common.nix + darwin.nix
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp-specific packages here
  ];
}
