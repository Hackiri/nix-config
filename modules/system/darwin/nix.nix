# Darwin-specific Nix configuration
# Determinate Nix manages its own daemon, settings, GC, and optimisation,
# so we disable nix-darwin's built-in Nix management and use nix.custom.conf
# for any extra settings.
_: {
  nix.enable = false;

  environment.etc."nix/nix.custom.conf".text = ''
    download-buffer-size = 268435456
  '';
}
