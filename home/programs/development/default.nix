# Development tools and configurations
# Note: Basic git is in programs/development/git/default.nix (imported by profiles/layers/development.nix)
# Note: Sops-enhanced git is in home/profiles/capabilities/sops.nix (gated by profiles.sops.enable)
{...}: {
  imports = [
    ./direnv
  ];
}
