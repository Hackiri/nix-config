# Home Manager entrypoint for the evaluation-only NixOS host.
#
# Only the NixOS platform profile is imported. home/programs is exercised by
# the Darwin host, so it is left out here to keep this host a check of the
# Linux-specific profile and package bundle.
{username, ...}: {
  imports = [
    ../../home/profiles/platforms/nixos.nix
  ];

  home = {
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };
}
