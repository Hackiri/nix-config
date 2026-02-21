{
  description = "Multi-system Nix flake (nix-darwin, NixOS, etc.)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    # Follows stable nixpkgs — only affects HM's internal lib/module evaluation
    # since useGlobalPkgs = true means actual packages come from each system's own pkgs.
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Emacs overlay for native compilation support
    # Intentionally unpinned — tracks latest for fresh emacs builds and daily MELPA updates.
    # The lock file still provides a reproducible SHA; `nix flake update emacs-overlay` pulls new builds.
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    # Secrets management
    # Tracks default branch; nixpkgs alignment via `follows` and flake.lock SHA ensure reproducibility.
    # sops-nix has no stable release branches — pinning to default branch is the upstream convention.
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Git hooks management
    # Tracks default branch; nixpkgs alignment via `follows` and flake.lock SHA ensure reproducibility.
    # git-hooks.nix has no stable release branches — pinning to default branch is the upstream convention.
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

  outputs = inputs: let
    overlay = import ./overlays;

    # Build pkgs from a specific nixpkgs source with shared overlays.
    # Darwin uses nixpkgs-25.11-darwin, NixOS uses nixos-25.11.
    mkPkgs = nixpkgsSrc: system:
      import nixpkgsSrc {
        inherit system;
        overlays = [
          inputs.emacs-overlay.overlays.default
          overlay
        ];
        config = {allowUnfree = true;};
      };

    # Select the correct nixpkgs source for a given system
    nixpkgsFor = system:
      if builtins.match ".*-darwin" system != null
      then inputs.nixpkgs-darwin
      else inputs.nixpkgs;
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux"];

      perSystem = {
        pkgs,
        system,
        self',
        ...
      }: {
        # Configure pkgs with overlays and allowUnfree
        _module.args.pkgs = mkPkgs (nixpkgsFor system) system;

        # Git pre-commit hooks checks
        checks.pre-commit-check = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            stylua.enable = true;
            shellcheck.enable = true;
            prettier.enable = true;
          };
        };

        # Custom packages as flake outputs
        packages = let
          customPkgs = import ./pkgs {inherit pkgs;};
        in {
          inherit (customPkgs) kube-packages;
        };

        # Development shells with pre-commit hooks
        devShells = let
          langShells = import ./lib/devshells.nix {inherit pkgs;};
        in
          {
            default = pkgs.mkShell {
              inherit (self'.checks.pre-commit-check) shellHook;
              buildInputs = self'.checks.pre-commit-check.enabledPackages;
            };
          }
          // langShells;
      };

      flake = let
        # Shared home-manager configuration for all system types
        mkHomeManagerConfig = {
          name,
          username,
          pkgs-unstable,
        }: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit inputs username pkgs-unstable;
              hostName = name;
            };
            users.${username} = import ./hosts/${name}/home.nix;
            sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
              {manual.json.enable = false;}
            ];
          };
        };

        # Function to create a Darwin system configuration
        mkDarwin = {
          name,
          system ? "x86_64-darwin",
          username ? "wm",
        }: let
          pkgs-unstable = mkPkgs inputs.nixpkgs-unstable system;
        in
          inputs.nix-darwin.lib.darwinSystem {
            inherit system;
            pkgs = mkPkgs inputs.nixpkgs-darwin system;
            modules = [
              ./hosts/${name}/configuration.nix
              inputs.sops-nix.darwinModules.sops
              inputs.home-manager.darwinModules.home-manager
              (mkHomeManagerConfig {inherit name username pkgs-unstable;})
              inputs.nix-homebrew.darwinModules.nix-homebrew
              {
                nix-homebrew = {
                  enable = true;
                  user = username;
                  autoMigrate = true;
                  taps = {
                    "homebrew/homebrew-core" = inputs.homebrew-core;
                    "homebrew/homebrew-cask" = inputs.homebrew-cask;
                    "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
                  };
                  mutableTaps = false;
                };
                homebrew.caskArgs = {
                  appdir = "~/Applications";
                  require_sha = true;
                };
              }
            ];
            specialArgs = {inherit inputs system username pkgs-unstable;};
          };

        # Function to create a NixOS system configuration
        mkNixOS = {
          name,
          system ? "x86_64-linux",
          username ? "wm",
        }: let
          pkgs-unstable = mkPkgs inputs.nixpkgs-unstable system;
        in
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            pkgs = mkPkgs inputs.nixpkgs system;
            modules = [
              ./hosts/${name}/configuration.nix
              inputs.sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              (mkHomeManagerConfig {inherit name username pkgs-unstable;})
            ];
            specialArgs = {inherit inputs system username pkgs-unstable;};
          };
      in {
        darwinConfigurations = {
          "mbp" = mkDarwin {
            name = "mbp";
            system = "x86_64-darwin";
            username = "wm";
          };
        };

        nixosConfigurations = {
          "desktop" = mkNixOS {
            name = "desktop";
            system = "x86_64-linux";
            username = "wm";
          };
        };

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
    };
}
