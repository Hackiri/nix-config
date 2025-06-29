{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../home/common.nix
    ../../home/darwin.nix
    ../../home/git-hooks.nix
  ];

  # User identity
  home = {
    username = "wm";
    homeDirectory = "/Users/wm";
    stateVersion = "25.05";

    # User packages
    packages = with pkgs; [
      # Add your personal packages here
    ];
  };

  # Enable some useful programs
  programs = {
    home-manager.enable = true;
  };
}
