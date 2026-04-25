{
  pkgs,
  configFile,
}:
pkgs.writeShellApplication {
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

    sed 's/^            //' >"$hook_path" <<'EOF'
            #!${pkgs.bash}/bin/bash
            # File generated for nix-config
            # Managed by install-pre-commit-hook for nix-config
            INSTALL_PYTHON=""
            ARGS=(hook-impl --config=${configFile} --hook-type=pre-commit)

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
}
