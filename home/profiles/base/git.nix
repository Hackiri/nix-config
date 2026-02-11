# Git configuration with sops-integrated hooks (LEGACY)
#
# NOTE: This file is superseded by features/sops.nix which consolidates all
#       sops configuration behind a single feature flag (profiles.sops.enable).
#       Kept for reference only — new setups should use features/sops.nix instead.
{...}: {
  imports = [
    # Git configuration with sops-integrated hooks
    ../../programs/development/git/git-hooks.nix
  ];
}
