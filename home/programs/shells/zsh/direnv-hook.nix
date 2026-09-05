# Auto-detect .envrc creation on cd
# Detects project marker files and offers to create a composed development shell.
# The generated flake imports the authoritative package sets from lib/devshells.nix.
{
  config,
  pkgs,
  ...
}: let
  nixConfigPath = "${config.home.homeDirectory}/nix-config";
  devshellsPath = "${nixConfigPath}/lib/devshells.nix";
  devshellsPathJson = builtins.toJSON devshellsPath;
in {
  config = {
    programs.zsh.initContent = ''
      _direnv_cache_base() {
        print -r -- "''${XDG_CACHE_HOME:-$HOME/.cache}/direnv-flakes"
      }

      # A full path hash avoids collisions such as /work/a_b and /work/a/b.
      _direnv_cache_dir() {
        local path_hash
        path_hash="$(printf '%s' "$PWD" | ${pkgs.coreutils}/bin/sha256sum)"
        path_hash="''${path_hash%% *}"
        print -r -- "$(_direnv_cache_base)/$path_hash"
      }

      # Only files carrying our marker (or the exact legacy one-line shape) are owned.
      _direnv_envrc_is_managed() {
        [[ ! -e .envrc ]] && return 0
        [[ -f .envrc ]] || return 1

        local first_line
        IFS= read -r first_line < .envrc
        [[ "$first_line" == "# Managed by nix-config direnv auto-shell" ]] && return 0

        local content line_count
        content="$(<.envrc)"
        line_count="$(grep -c '^' .envrc 2>/dev/null)"
        [[ "$line_count" == 1 && "$content" == "use flake $(_direnv_cache_base)/"* ]]
      }

      # Generate a flake that composes the root language definitions.
      _direnv_gen_flake() {
        local cache_dir="$1"
        shift
        local shell_list=""
        local shell
        for shell in "$@"; do
          case "$shell" in
            node|python|rust|go|ruby|php) ;;
            *)
              print -u2 -- "Unknown development shell: $shell"
              return 1
              ;;
          esac
          shell_list+=" \"$shell\""
        done

        mkdir -p "$cache_dir"
        local tmp_flake="$cache_dir/.flake.nix.tmp.$$"
        cat > "$tmp_flake" << FLAKE_EOF
      {
        description = "Development environment composed from nix-config";

        inputs = {
          nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
          nixConfig = {
            url = "path:${nixConfigPath}/lib";
            flake = false;
          };
        };

        outputs = {nixpkgs, nixConfig, ...}: let
          systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
          forAllSystems = nixpkgs.lib.genAttrs systems;
        in {
          devShells = forAllSystems (system: let
            pkgs = nixpkgs.legacyPackages.\''${system};
          in {
            default = import (nixConfig + "/devshells.nix") {
              inherit pkgs;
              shellNames = [$shell_list ];
            };
          });
        };
      }
      FLAKE_EOF
        mv "$tmp_flake" "$cache_dir/flake.nix"
      }

      # Add local generated state to the repository's worktree-safe exclude file.
      _direnv_git_exclude() {
        local exclude_file
        exclude_file="$(git rev-parse --git-path info/exclude 2>/dev/null)" || return 0
        if [[ -f "$exclude_file" ]]; then
          grep -qxF '.envrc' "$exclude_file" 2>/dev/null || echo '.envrc' >> "$exclude_file"
          grep -qxF '.direnv' "$exclude_file" 2>/dev/null || echo '.direnv' >> "$exclude_file"
        fi
      }

      # Refresh owned files, but never replace a hand-written .envrc.
      _direnv_setup() {
        local cache_dir="$1"
        _direnv_envrc_is_managed || {
          print -u2 -- "Refusing to overwrite hand-written $PWD/.envrc"
          return 1
        }
        local tmp_envrc=".envrc.tmp.$$"
        cat > "$tmp_envrc" << ENVRC_EOF
      # Managed by nix-config direnv auto-shell
      watch_file ${devshellsPathJson}
      use flake "$cache_dir"
      ENVRC_EOF

        local changed=0
        if [[ ! -f .envrc ]] || ! ${pkgs.diffutils}/bin/cmp -s "$tmp_envrc" .envrc; then
          mv "$tmp_envrc" .envrc
          changed=1
        else
          rm "$tmp_envrc"
        fi

        _direnv_git_exclude
        (( changed )) && direnv allow
      }

      # Auto-detect devShells and offer to create or refresh managed files.
      _direnv_auto_detect() {
        [[ "$PWD" == "$HOME" ]] && return
        [[ "$PWD" == "$HOME/nix-config" ]] && return
        _direnv_envrc_is_managed || return

        local -a detected=()
        [[ -f Cargo.toml ]] && detected+=(rust)
        [[ -f package.json ]] && detected+=(node)
        [[ -f go.mod ]] && detected+=(go)
        [[ -f pyproject.toml || -f requirements.txt || -f setup.py ]] && detected+=(python)
        [[ -f Gemfile ]] && detected+=(ruby)
        [[ -f composer.json ]] && detected+=(php)

        (( ''${#detected[@]} == 0 )) && return

        local cache_dir="$(_direnv_cache_dir)"

        # Existing generated files are refreshed without prompting. The selected
        # shells are recovered from the generated flake when possible; otherwise
        # current project markers are authoritative for the migration.
        if [[ -f .envrc ]]; then
          local -a selected=("''${detected[@]}")
          local existing_shells
          existing_shells="$(grep -E '^[[:space:]]*shellNames = \[' "$cache_dir/flake.nix" 2>/dev/null | sed -E 's/.*\[(.*)\].*/\1/' | tr -d '\"')"
          if [[ -n "$existing_shells" ]]; then
            selected=(''${=existing_shells})
          fi
          _direnv_gen_flake "$cache_dir" "''${selected[@]}"
          _direnv_setup "$cache_dir"
          return
        fi

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

      autoload -Uz add-zsh-hook
      add-zsh-hook chpwd _direnv_auto_detect
    '';
  };
}
