{username, ...}: {
  imports = [
    ../../home/profiles/platforms/nixos.nix
    ../../home/programs
  ];

  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";
}
