{
  config,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ../../../home/common.nix
    ../../../home/darwin.nix
  ];

  # User identity
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
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
