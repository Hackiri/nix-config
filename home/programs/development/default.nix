# Development tools and configurations
# Note: Basic git is in programs/development/git/default.nix (imported by features/development.nix)
# Note: Sops-enhanced git is in home/profiles/features/sops.nix (gated by profiles.sops.enable)
{...}: {
  imports = [
    ./direnv
  ];
}
