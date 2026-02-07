{
  description = "Multi-system Nix flake (nix-darwin, NixOS, etc.)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # Emacs overlay for native compilation support
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    # Secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Git hooks management
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

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

  outputs = inputs:
    with inputs; let
      # Define system types for convenience
      supportedSystems = ["x86_64-darwin" "aarch64-darwin" "x86_64-linux"];

      # Helper function to generate an attrset for each supported system
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Import the overlay from the overlays directory
      overlay = import ./overlays;

      # Create a pkgs for each system with our overlays
      pkgsForSystem = system:
        import nixpkgs {
          inherit system;
          overlays = [
            inputs.emacs-overlay.overlays.default
            overlay # Our overlay comes last to override emacs-overlay's emacs-git
          ];
          config = {allowUnfree = true;};
        };

      # Shared home-manager configuration for all system types
      mkHomeManagerConfig = {
        name,
        username,
      }: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = {inherit inputs username;};
          users.${username} = import ./hosts/${name}/home.nix;
          sharedModules = [
            sops-nix.homeManagerModules.sops
            # Disable manual JSON generation to avoid builtins.toFile warning
            # See: https://github.com/nix-community/home-manager/issues/7935
            {manual.json.enable = false;}
          ];
        };
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

            # Secrets management
            sops-nix.darwinModules.sops

            # Home Manager integration
            home-manager.darwinModules.home-manager
            (mkHomeManagerConfig {inherit name username;})

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

      # Function to create a NixOS system configuration
      mkNixOS = {
        name,
        system ? "x86_64-linux",
        username ? "wm",
      }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          # Use our custom nixpkgs with overlays
          pkgs = pkgsForSystem system;
          modules = [
            # Base system configuration
            ./hosts/${name}/configuration.nix

            # Secrets management
            sops-nix.nixosModules.sops

            # Home Manager integration
            home-manager.nixosModules.home-manager
            (mkHomeManagerConfig {inherit name username;})
          ];
          specialArgs = {inherit inputs system username;};
        };
    in {
      # Define your systems here
      darwinConfigurations = {
        "mbp" = mkDarwin {
          name = "mbp";
          system = "x86_64-darwin";
          username = "wm";
        };
      };

      # Define your NixOS systems here
      nixosConfigurations = {
        # Example NixOS desktop configuration
        "desktop" = mkNixOS {
          name = "desktop";
          system = "x86_64-linux";
          username = "wm";
        };
        # Additional NixOS configurations can be added here
        # "server" = mkNixOS {
        #   name = "server";
        #   system = "x86_64-linux";
        #   username = "wm";
        # };
      };

      # Git pre-commit hooks checks
      checks = forAllSystems (system: {
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # Nix formatters and linters
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;

            # Lua formatter
            stylua.enable = true;
          };
        };
      });

      # Make custom packages available as flake outputs
      packages = forAllSystems (system: let
        pkgs = pkgsForSystem system;
        # Import packages with the correct pkgs for this system
        customPkgs = import ./pkgs {inherit pkgs;};
      in {
        # Export custom packages directly
        inherit (customPkgs) dev-tools kube-packages;
        # Export the devshell script as the main devshell package
        devshell = customPkgs.devshell.script;
      });

      # Development shells with pre-commit hooks
      devShells = forAllSystems (system: let
        pkgs = pkgsForSystem system;
        langShells = import ./lib/devshells.nix {inherit pkgs;};
      in
        {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
          };
        }
        // langShells);

      # Make custom packages available as apps
      apps = forAllSystems (system: let
        pkgs = pkgsForSystem system;
        customPkgs = import ./pkgs {inherit pkgs;};
      in {
        # Export dev-tools as a runnable app
        dev-tools = {
          type = "app";
          program = "${customPkgs.dev-tools}/bin/dev-tools";
          meta = {
            description = "Development tools helper script";
            mainProgram = "dev-tools";
          };
        };
        # Export devshell as a runnable app
        devshell = {
          type = "app";
          program = "${customPkgs.devshell.script}/bin/devshell";
          meta = {
            description = "Development shell environment";
            mainProgram = "devshell";
          };
        };
      });

      # Project templates for quick project bootstrapping
      templates = {
        node = {
          path = ./templates/node;
          description = "Node.js project with devShell and direnv";
        };
        python = {
          path = ./templates/python;
          description = "Python project with devShell and direnv";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust project with devShell and direnv";
        };
        go = {
          path = ./templates/go;
          description = "Go project with devShell and direnv";
        };
      };
    };
}
