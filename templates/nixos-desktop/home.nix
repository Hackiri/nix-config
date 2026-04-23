{username, ...}: {
  imports = [
    ../../home/profiles/platforms/nixos.nix
  ];

  home.homeDirectory = "/home/${username}";
}
