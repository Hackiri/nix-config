# Darwin workstation capabilities selected explicitly by a host.
{inputs, ...}: {
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ../../../services/darwin/homebrew.nix
  ];

  services.homebrew.enable = true;
}
