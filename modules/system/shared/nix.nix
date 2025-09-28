# Shared Nix configuration for all systems
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Nix configuration
  nix = {
    enable = true;
    settings = {
      # Core Nix features
      experimental-features = ["nix-command" "flakes" "ca-derivations"];
      warn-dirty = "false";
      
      # Performance optimizations
      max-jobs = "auto";           # Use all available CPU cores for builds
      cores = 0;                   # Use all available cores per job
      sandbox = true;              # Enable sandboxed builds for security
      
      # Build optimization
      keep-outputs = true;         # Keep build outputs for GC roots
      keep-derivations = true;     # Keep derivations for debugging
      
      # Binary cache configuration
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    # Garbage collection settings
    gc =
      {
        automatic = true;
        options = "--delete-older-than 30d"; # Keep generations for 30 days
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        # Darwin-specific GC interval
        interval = {
          Weekday = 0;
          Hour = 3;
          Minute = 0;
        }; # Run GC weekly on Sundays at 3am
      };
    # Use optimise instead of auto-optimise-store
    optimise = {
      automatic = true;
    };
  };

  # Enable nix-index for command-not-found functionality
  programs.nix-index.enable = true;
  
  # Note: nixpkgs.config.allowUnfree is handled in flake.nix
}
