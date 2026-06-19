{username, ...}: {
  imports = [
    ../../home/profiles/platforms/nixos.nix
    ../../home/packages/development
    ../../home/programs
  ];

  home.homeDirectory = "/home/${username}";
}
