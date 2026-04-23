{username, ...}: {
  imports = [
    ../../home/profiles/platform/nixos.nix
  ];

  home.homeDirectory = "/home/${username}";
}
