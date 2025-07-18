{
  description = "Multi-system Nix flake (nix-darwin, NixOS, etc.)";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Emacs overlay for native compilation support
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    # Homebrew inputs
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    home-manager,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    emacs-overlay,
    ...
  }: let
    # Define system types for convenience
    supportedSystems = ["x86_64-darwin" "aarch64-darwin"];

    # Helper function to generate an attrset for each supported system
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Import the overlay from the overlays directory
    overlay = import ./overlays;

    # Configure nixpkgs with overlays
    nixpkgsConfig = {
      overlays = [
        overlay
        # Add emacs-overlay for native compilation support
        inputs.emacs-overlay.overlays.default
      ];
      config = {allowUnfree = true;};
    };

    # Create a pkgs for each system with our overlays
    pkgsForSystem = system:
      import nixpkgs {
        inherit system;
        overlays = [
          overlay
          inputs.emacs-overlay.overlays.default
        ];
        config = {allowUnfree = true;};
      };

    # Function to create a Darwin system configuration
    mkDarwin = {
      name,
      system ? "x86_64-darwin",
      username ? "wm",
    }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        # Use our custom nixpkgs with overlays
        pkgs = pkgsForSystem system;
        modules = [
          # Base system configuration
          ./hosts/${name}/configuration.nix

          # Home Manager integration
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs username;};
              users.${username} = import ./hosts/${name}/home.nix;
            };
          }

          # Homebrew integration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = username;
              autoMigrate = true;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
              mutableTaps = true; # Allow existing taps to be managed
            };

            # Configure Homebrew through the standard module
            homebrew.caskArgs = {
              appdir = "~/Applications";
              require_sha = true;
            };
          }
        ];
        specialArgs = {inherit inputs system username;};
      };
  in {
    # Define your systems here
    darwinConfigurations = {
      "nix-darwin" = mkDarwin {
        name = "nix-darwin";
        username = "wm";
      };
    };

    # Make custom packages available as flake outputs
    packages = forAllSystems (system: let
      pkgs = pkgsForSystem system;
      # Import packages with the correct pkgs for this system
      customPkgs = import ./pkgs {inherit pkgs;};
    in {
      # Use a let binding to avoid the warning
      dev-tools = let
        devTools = customPkgs.dev-tools;
      in
        devTools.dev-tools;

      # Use inherit for attributes with the same name
      inherit (customPkgs) devshell kube-packages;
    });

    # Make custom packages available as apps
    apps = forAllSystems (system: let
      pkgs = pkgsForSystem system;
      customPkgs = import ./pkgs {inherit pkgs;};
    in {
      # Export dev-tools as a runnable app
      dev-tools = {
        type = "app";
        program = "${customPkgs.dev-tools.dev-tools}/bin/dev-tools";
      };
      # Export devshell as a runnable app
      devshell = {
        type = "app";
        program = "${customPkgs.devshell}/bin/devshell";
      };
    });
  };
}
