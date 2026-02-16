# Auto-detect .envrc creation on cd
# Detects project marker files and offers to create flake.nix + .envrc
# with the appropriate devShell packages
_: {
  programs.zsh.initContent = ''
        # Package lists for each devShell (mirrors lib/devshells.nix)
        typeset -A _devshell_pkgs
        _devshell_pkgs=(
          node '          nodejs
                  yarn
                  pnpm
                  bun
                  nodePackages.typescript
                  nodePackages.prettier'
          python '          python313
                  uv
                  python313Packages.pip
                  python313Packages.ruff
                  python313Packages.mypy
                  python313Packages.pytest'
          rust '          rustc
                  cargo
                  rustfmt
                  clippy
                  rust-analyzer'
          go '          go
                  gopls
                  golangci-lint
                  delve'
          ruby '          ruby_3_4'
          php '          php84
                  php84Packages.composer'
        )

        _direnv_gen_flake() {
          local -a shells=("$@")
          local pkgs_combined=""
          local hooks_combined=""

          local shell
          for shell in "''${shells[@]}"; do
            pkgs_combined+="''${_devshell_pkgs[$shell]}
        "
          done

          cat > flake.nix << 'FLAKE_EOF'
    {
      description = "Development environment";

      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      };

      outputs = {nixpkgs, ...}: let
        systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
        forAllSystems = nixpkgs.lib.genAttrs systems;
      in {
        devShells = forAllSystems (system: let
          pkgs = nixpkgs.legacyPackages.''${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
    FLAKE_EOF

          # Append packages
          echo "$pkgs_combined" >> flake.nix

          cat >> flake.nix << 'FLAKE_EOF'
            ];
          };
        });
      };
    }
    FLAKE_EOF
        }

        # Auto-detect devShells and offer to create .envrc + flake.nix
        _direnv_auto_detect() {
          # Skip conditions
          [[ -f .envrc ]] && return
          [[ "$PWD" == "$HOME" ]] && return
          [[ "$PWD" == "$HOME/nix-config" ]] && return

          # Detect project markers
          local -a detected=()
          [[ -f Cargo.toml ]] && detected+=(rust)
          [[ -f package.json ]] && detected+=(node)
          [[ -f go.mod ]] && detected+=(go)
          [[ -f pyproject.toml || -f requirements.txt || -f setup.py ]] && detected+=(python)
          [[ -f Gemfile ]] && detected+=(ruby)
          [[ -f composer.json ]] && detected+=(php)

          (( ''${#detected[@]} == 0 )) && return

          # Single language: simple y/n prompt
          if (( ''${#detected[@]} == 1 )); then
            local answer
            printf '\nNo .envrc found. Create devShell for %s? [y/n]: ' "''${detected[1]}"
            read -r answer
            if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
              _direnv_gen_flake "''${detected[1]}"
              echo "use flake" > .envrc
              # git add so Nix can see the flake
              if git rev-parse --is-inside-work-tree &>/dev/null; then
                git add flake.nix .envrc 2>/dev/null
              fi
              echo "Created flake.nix + .envrc — run 'direnv allow' to activate"
            fi
            return
          fi

          # Multiple languages: numbered selection
          printf '\nNo .envrc found. Detected devShells:\n'
          local i
          for i in {1..''${#detected[@]}}; do
            printf '  %d) %s\n' "$i" "''${detected[$i]}"
          done
          printf "Select shells (e.g. 1,3 or 'all' or 'skip'): "

          local answer
          read -r answer

          [[ -z "$answer" || "$answer" == "skip" ]] && return

          local -a selected=()
          if [[ "$answer" == "all" ]]; then
            selected=("''${detected[@]}")
          else
            local -a nums=(''${(s:,:)answer})
            local n
            for n in "''${nums[@]}"; do
              n="''${n// /}"
              if (( n >= 1 && n <= ''${#detected[@]} )); then
                selected+=("''${detected[$n]}")
              fi
            done
          fi

          if (( ''${#selected[@]} > 0 )); then
            _direnv_gen_flake "''${selected[@]}"
            echo "use flake" > .envrc
            # git add so Nix can see the flake
            if git rev-parse --is-inside-work-tree &>/dev/null; then
              git add flake.nix .envrc 2>/dev/null
            fi
            echo "Created flake.nix + .envrc — run 'direnv allow' to activate"
          fi
        }

        # Register as chpwd hook
        autoload -Uz add-zsh-hook
        add-zsh-hook chpwd _direnv_auto_detect
  '';
}
