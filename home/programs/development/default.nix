# Development tools and configurations
# Note: Basic git is in programs/development/git/default.nix (selected through home/programs/default.nix and host workstation suites)
# Note: Sops-enhanced git is in home/profiles/capabilities/sops.nix (gated by profiles.sops.enable)
{...}: {
  imports = [
    ./direnv
  ];
}
