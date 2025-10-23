# Git configuration with optional sops-integrated hooks
# This file imports git-hooks.nix which requires sops secrets to be configured.
#
# To use WITHOUT sops (basic Git only):
#   Comment out this import in features/development.nix and import
#   ../../programs/development/git/default.nix directly instead.
#
# To use WITH sops hooks (recommended):
#   1. Keep this import in features/development.nix
#   2. Also import base/secrets.nix for sops utilities
#   3. Set up age key and secrets as described in base/secrets.nix
{...}: {
  imports = [
    # Git configuration with sops-integrated hooks
    ../../programs/development/git/git-hooks.nix
  ];
}
