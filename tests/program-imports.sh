#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail() {
  printf 'program-imports: %s\n' "$*" >&2
  exit 1
}

registry_darwin_count="$(nix eval --impure --expr 'let r = import ./home/programs; in builtins.length r.suites.workstation.darwin')"
registry_nixos_count="$(nix eval --impure --expr 'let r = import ./home/programs; in builtins.length r.suites.workstation.nixos')"

[ "$registry_darwin_count" = "18" ] || fail "darwin program suite size changed: expected 18, got $registry_darwin_count"
[ "$registry_nixos_count" = "17" ] || fail "nixos program suite size changed: expected 17, got $registry_nixos_count"

if git grep -nE '(\.\./)+programs' -- ':(glob)home/profiles/**/*.nix' >/tmp/program-imports-profile-paths.txt; then
  cat /tmp/program-imports-profile-paths.txt >&2
  fail "home/profiles still imports home/programs modules"
fi

check_import() {
  local file="$1"
  local import_path="$2"

  git grep -q "$import_path" -- "$file" || fail "$file does not import $import_path"
}

check_no_granular_program_imports() {
  local pathspec="$1"

  if git grep -nE '\.\./\.\./home/programs/.+' -- "$pathspec" >/tmp/program-imports-granular.txt; then
    cat /tmp/program-imports-granular.txt >&2
    fail "$pathspec still imports individual home/programs modules"
  fi
}

check_darwin_host_imports() {
  local file="$1"

  check_import "$file" "programRegistry = import ../../home/programs;"
  check_import "$file" "programRegistry.suites.workstation.darwin"
  check_no_granular_program_imports "$file"
}

check_nixos_template_imports() {
  local file="$1"

  check_import "$file" "programRegistry = import ../../home/programs;"
  check_import "$file" "programRegistry.suites.workstation.nixos"
  check_no_granular_program_imports "$file"
}

check_darwin_host_imports hosts/mbp/home.nix
check_darwin_host_imports hosts/mbp2/home.nix
check_nixos_template_imports templates/nixos-desktop/home.nix

printf 'program-imports: ok\n'
