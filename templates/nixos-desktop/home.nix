{username, ...}: {
  imports = [
    ../../home/profiles/platforms/nixos.nix
    ../../home/packages/development
  ];

  home.homeDirectory = "/home/${username}";
}
