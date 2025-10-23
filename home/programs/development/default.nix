# Development tools and configurations
# Note: Git configuration is in base/git.nix (imported via features/development.nix)
# This ensures no conflicts and makes Git truly optional.
{...}: {
  imports = [
    ./direnv
  ];
}
