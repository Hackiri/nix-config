# Shared Nix configuration for all systems
_: {
  # Nix configuration
  nix = {
    # Disable nix-darwin's Nix management when using Determinate Nix
    # Determinate Nix manages its own daemon and conflicts with nix-darwin's native management
    # Note: With nix.enable = false, nix-darwin won't manage Nix settings, GC, or optimisation
    # You can configure these directly in /etc/nix/nix.conf if needed
    enable = false;

    # The following settings are disabled when nix.enable = false
    # Determinate Nix manages these through its own configuration
    # settings = {
    #   experimental-features = ["nix-command" "flakes" "ca-derivations"];
    #   warn-dirty = "false";
    #   max-jobs = "auto";
    #   cores = 0;
    #   sandbox = true;
    #   keep-outputs = true;
    #   keep-derivations = true;
    #   substituters = [
    #     "https://cache.nixos.org"
    #     "https://nix-community.cachix.org"
    #   ];
    #   trusted-public-keys = [
    #     "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    #   ];
    # };

    # GC and optimisation are managed by Determinate Nix
    # gc.automatic = false;
    # optimise.automatic = false;
  };

  # Enable nix-index for command-not-found functionality
  programs.nix-index.enable = true;

  # Note: nixpkgs.config.allowUnfree is handled in flake.nix
}
