# NixOS workstation capabilities selected explicitly by a host.
_: {
  imports = [
    ../../../services/nixos/openssh.nix
    ../../../services/nixos/podman.nix
  ];
}
