# Auto-detect .envrc creation on cd
# Offers to create .envrc pointing at ~/nix-config devShells
# when project marker files are detected
_: {
  programs.zsh.initContent = ''
    # Auto-detect devShells and offer to create .envrc
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
        printf '\nNo .envrc found. Create .envrc for %s? [y/n]: ' "''${detected[1]}"
        read -r answer
        if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
          echo "use flake ~/nix-config#''${detected[1]}" > .envrc
          echo "Created .envrc — run 'direnv allow' to activate"
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
        local shell
        for shell in "''${selected[@]}"; do
          echo "use flake ~/nix-config#$shell" >> .envrc
        done
        echo "Created .envrc — run 'direnv allow' to activate"
      fi
    }

    # Register as chpwd hook
    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd _direnv_auto_detect
  '';
}
