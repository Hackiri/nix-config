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

    # Treefmt for unified formatting
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Homebrew inputs
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-homebrew.inputs.brew-src.follows = "brew-src";
    brew-src = {
      url = "github:Homebrew/brew";
      flake = false;
    };
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
    homebrew-krun = {
      url = "github:slp/homebrew-krun";
      flake = false;
    };
  };

  outputs = inputs: let
    defaultUsername = "wm";
    builders = import ./lib/builders.nix {inherit inputs defaultUsername;};
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux"];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        preCommitCheck = import ./lib/pre-commit.nix {
          inherit inputs system;
          src = ./.;
          treefmt = config.treefmt.build.wrapper;
        };
        installPreCommitHook = import ./lib/install-pre-commit-hook.nix {
          inherit pkgs;
          inherit (preCommitCheck.config) configFile;
        };
      in {
        # Formatter configuration
        treefmt.config = import ./treefmt.nix;

        # Git pre-commit hooks checks
        checks.pre-commit-check = preCommitCheck;

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
              buildInputs =
                preCommitCheck.enabledPackages
                ++ [
                  pkgs.pre-commit
                  installPreCommitHook
                  pkgs.just
                  pkgs.nh
                ];
              shellHook = ''
                if git rev-parse --git-dir >/dev/null 2>&1; then
                  repo_root="$(git rev-parse --show-toplevel)"
                  config_link="$repo_root/.pre-commit-config.yaml"
                  if [ ! -e "$config_link" ]; then
                    ln -s "${preCommitCheck.config.configFile}" "$config_link"
                  elif [ -L "$config_link" ] && [ "$(readlink "$config_link" 2>/dev/null)" != "${preCommitCheck.config.configFile}" ]; then
                    ln -fs "${preCommitCheck.config.configFile}" "$config_link"
                  elif [ ! -L "$config_link" ]; then
                    echo "git-hooks.nix: leaving existing $config_link in place because it is not a symlink."
                  fi
                fi

                if git rev-parse --git-dir >/dev/null 2>&1; then
                  hooks_path="$(git config core.hooksPath || true)"
                  if [ -n "$hooks_path" ]; then
                    echo "git-hooks.nix: skipping hook installation because core.hooksPath is set to '$hooks_path'."
                    echo "Run 'pre-commit run --all-files' manually, or use 'install-pre-commit-hook' for a repo-specific hook."
                  fi
                fi
              '';
            };
          }
          // langShells;
      };

      flake = {
        # Auto-discovered from hosts/*/meta.nix
        inherit (builders.discoverHosts) darwinConfigurations nixosConfigurations;

        templates = {
          host = {
            path = ./templates/host;
            description = "Generic host scaffold for darwin or NixOS";
          };
          nixos-desktop = {
            path = ./templates/nixos-desktop;
            description = "NixOS desktop host scaffold with placeholder hardware config";
          };
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
