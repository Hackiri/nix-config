# NixOS-specific Nix configuration
# Shared settings (download-buffer-size, auto-optimise-store) are in ../shared/nix-settings.nix
_: {
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
