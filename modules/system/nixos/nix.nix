# NixOS-specific Nix configuration
_: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    download-buffer-size = 268435456;
  };
}
