# Darwin-specific Nix configuration. The Determinate module disables
# nix-darwin's built-in Nix management and writes custom Nix settings.
_: {
  determinateNix = {
    enable = true;
    customSettings.download-buffer-size = 268435456;
  };
}
