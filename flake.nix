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

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        preCommitCheck = import ./lib/pre-commit.nix {
          inherit inputs system;
          src = ./.;
        };
        installPreCommitHook = pkgs.writeShellApplication {
          name = "install-pre-commit-hook";
          runtimeInputs = [pkgs.git pkgs.pre-commit];
          text = ''
            set -euo pipefail

            marker="# Managed by install-pre-commit-hook for nix-config"
            force_shared=0

            if [[ "''${1:-}" == "--force-shared" ]]; then
              force_shared=1
              shift
            fi

            if [[ $# -ne 0 ]]; then
              echo "usage: install-pre-commit-hook [--force-shared]" >&2
              exit 2
            fi

            git rev-parse --git-dir >/dev/null 2>&1

            repo_root="$(git rev-parse --show-toplevel)"
            common_dir="$(git rev-parse --path-format=absolute --git-common-dir)"
            hook_dir="$(git rev-parse --path-format=absolute --git-path hooks)"
            hook_path="$hook_dir/pre-commit"
            legacy_path="$hook_dir/pre-commit.legacy"

            case "$hook_dir" in
              "$repo_root"/*|"$common_dir"/*)
                ;;
              *)
                if [[ "$force_shared" -ne 1 ]]; then
                  echo "Refusing to install a repo-specific pre-commit hook into shared hooksPath: $hook_dir" >&2
                  echo "Use a repo-local hooksPath first, or rerun with --force-shared if that is intentional." >&2
                  exit 1
                fi
                ;;
            esac

            mkdir -p "$hook_dir"

            if [[ -e "$hook_path" ]] && ! grep -Fq "$marker" "$hook_path"; then
              if [[ -e "$legacy_path" ]]; then
                echo "Refusing to overwrite $hook_path because $legacy_path already exists." >&2
                exit 1
              fi
              mv "$hook_path" "$legacy_path"
            fi

            cat >"$hook_path" <<'EOF'
            #!${pkgs.bash}/bin/bash
            # File generated for nix-config
            # Managed by install-pre-commit-hook for nix-config
            INSTALL_PYTHON=""
            ARGS=(hook-impl --config=${preCommitCheck.config.configFile} --hook-type=pre-commit)

            HERE="$(cd "$(dirname "$0")" && pwd)"
            ARGS+=(--hook-dir "$HERE" -- "$@")

            ${pkgs.pre-commit}/bin/pre-commit "''${ARGS[@]}"
            status=$?

            if [ "$status" -ne 0 ]; then
              exit "$status"
            fi

            if [ -x "$HERE/pre-commit.legacy" ]; then
              exec "$HERE/pre-commit.legacy" "$@"
            fi
            EOF

            chmod +x "$hook_path"

            echo "Installed pre-commit hook at $hook_path"
            if [[ -e "$legacy_path" ]]; then
              echo "Preserved previous hook at $legacy_path"
            fi
          '';
        };
      in {
        formatter = pkgs.alejandra;

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
              buildInputs = preCommitCheck.enabledPackages ++ [pkgs.pre-commit installPreCommitHook];
              shellHook = ''
                if git rev-parse --git-dir >/dev/null 2>&1; then
                  repo_root="$(git rev-parse --show-toplevel)"
                  if [ ! -L "$repo_root/.pre-commit-config.yaml" ] || [ "$(readlink "$repo_root/.pre-commit-config.yaml" 2>/dev/null)" != "${preCommitCheck.config.configFile}" ]; then
                    ln -fs "${preCommitCheck.config.configFile}" "$repo_root/.pre-commit-config.yaml"
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
