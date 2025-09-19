# Common Home Manager config for all systems
{
  config,
  pkgs,
  ...
}: {
  # Use the development profile which includes all the tools
  imports = [
    ./profiles/development.nix
  ];
}
