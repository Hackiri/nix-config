# Auto-detect .envrc creation on cd
# Detects project marker files and offers to create flake.nix + .envrc
# Flake is generated in ~/.cache/direnv-flakes/ to keep project git clean
_: {
  programs.zsh.initContent = ''
        # Package lists for each devShell (mirrors lib/devshells.nix)
        typeset -A _devshell_pkgs
        _devshell_pkgs=(
          node '      nodejs
                yarn
                pnpm
                bun
                nodePackages.typescript
                nodePackages.prettier'
          python '      python313
                uv
                python313Packages.pip
                python313Packages.ruff
                python313Packages.mypy
                python313Packages.pytest'
          rust '      rustc
                cargo
                rustfmt
                clippy
                rust-analyzer'
          go '      go
                gopls
                golangci-lint
                delve'
          ruby '      ruby_3_4'
          php '      php84
                php84Packages.composer'
        )

        # Generate flake.nix in a cache directory outside the project
        _direnv_gen_flake() {
          local cache_dir="$1"
          shift
          local -a shells=("$@")
          local pkgs_combined=""

          local shell
          for shell in "''${shells[@]}"; do
            pkgs_combined+="''${_devshell_pkgs[$shell]}
    "
          done

          mkdir -p "$cache_dir"

          cat > "$cache_dir/flake.nix" << 'FLAKE_EOF'
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

          echo "$pkgs_combined" >> "$cache_dir/flake.nix"

          cat >> "$cache_dir/flake.nix" << 'FLAKE_EOF'
            ];
          };
        });
      };
    }
    FLAKE_EOF
        }

        # Add .envrc to .git/info/exclude so it never shows in git status
        _direnv_git_exclude() {
          local exclude_file=".git/info/exclude"
          if [[ -d .git && -f "$exclude_file" ]]; then
            grep -qxF '.envrc' "$exclude_file" 2>/dev/null || echo '.envrc' >> "$exclude_file"
            grep -qxF '.direnv' "$exclude_file" 2>/dev/null || echo '.direnv' >> "$exclude_file"
          fi
        }

        # Setup: create .envrc pointing at cache dir, exclude from git, allow direnv
        _direnv_setup() {
          local cache_dir="$1"
          echo "use flake $cache_dir" > .envrc
          _direnv_git_exclude
          direnv allow
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

          # Cache dir based on project path
          local cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/direnv-flakes/$(pwd | sed 's|/|_|g')"

          # Single language: simple y/n prompt
          if (( ''${#detected[@]} == 1 )); then
            local answer
            printf '\nNo .envrc found. Create devShell for %s? [y/n]: ' "''${detected[1]}"
            read -r answer
            if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
              _direnv_gen_flake "$cache_dir" "''${detected[1]}"
              _direnv_setup "$cache_dir"
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
            _direnv_gen_flake "$cache_dir" "''${selected[@]}"
            _direnv_setup "$cache_dir"
          fi
        }

        # Register as chpwd hook
        autoload -Uz add-zsh-hook
        add-zsh-hook chpwd _direnv_auto_detect
  '';
}
