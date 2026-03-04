# Darwin-specific Nix configuration
# Determinate Nix manages its own daemon, settings, GC, and optimisation,
# so we disable nix-darwin's built-in Nix management. Shared settings are
# applied via ../shared/nix-settings.nix using nix.custom.conf.
_: {
  nix.enable = false;
}
