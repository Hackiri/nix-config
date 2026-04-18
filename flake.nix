{
  description = "Multi-system Nix flake (nix-darwin, NixOS, etc.)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
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

    # Hermes Agent NixOS service module
    hermes-agent.url = "github:NousResearch/hermes-agent";
    hermes-agent.inputs.nixpkgs.follows = "nixpkgs";

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
    homebrew-aerospace = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    homebrew-felixkratz = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
  };

  outputs = inputs: let
    defaultUsername = "wm";
    builders = import ./lib/builders.nix {inherit inputs defaultUsername;};
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux"];

      perSystem = {
        pkgs,
        system,
        self',
        ...
      }: {
        # Git pre-commit hooks checks
        checks.pre-commit-check = import ./lib/pre-commit.nix {
          inherit inputs system;
          src = ./.;
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

      flake = {
        # Auto-discovered from hosts/*/meta.nix
        inherit (builders.discoverHosts) darwinConfigurations nixosConfigurations;

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
