# Secrets profile - SOPS utilities (LEGACY)
#
# NOTE: This file is superseded by features/sops.nix which consolidates all
#       sops configuration (hooks, secrets, aliases, launchd) behind a single
#       feature flag (profiles.sops.enable).
#       Kept for reference only — new setups should use features/sops.nix instead.
{...}: {
  imports = [
    # SOPS utilities and aliases (not included in default utilities)
    ../../programs/utilities/sops-nix/sops.nix
  ];
}
