# Shared Nix configuration for all systems
_: {
  nix = {
    # Disable nix-darwin's Nix management when using Determinate Nix
    # Determinate Nix manages its own daemon, settings, GC, and optimisation
    enable = false;
  };

  # Enable nix-index for command-not-found functionality
  programs.nix-index.enable = true;
}
