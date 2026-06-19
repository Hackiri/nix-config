#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail() {
  printf 'program-imports: %s\n' "$*" >&2
  exit 1
}

if git grep -nE '(\.\./)+programs' -- ':(glob)home/profiles/**/*.nix' >/tmp/program-imports-profile-paths.txt; then
  cat /tmp/program-imports-profile-paths.txt >&2
  fail "home/profiles still imports home/programs modules"
fi

if git grep -n 'programRegistry' -- hosts templates README.md PROFILE_MAP.md home/profiles/README.md >/tmp/program-imports-registry.txt; then
  cat /tmp/program-imports-registry.txt >&2
  fail "programRegistry is still documented or used outside home/programs/default.nix"
fi

if git grep -nE 'config\.profiles|profiles\.[A-Za-z0-9_.-]+\.enable|profiles\.development' -- home/programs >/tmp/program-imports-profile-flags.txt; then
  cat /tmp/program-imports-profile-flags.txt >&2
  fail "home/programs modules still use profile enable flags"
fi

if git grep -nE 'profiles\.development\.(editors|shells|utilities|terminals)|profiles\.development\.enable' -- hosts templates home/profiles README.md PROFILE_MAP.md >/tmp/program-imports-stale-development-flags.txt; then
  cat /tmp/program-imports-stale-development-flags.txt >&2
  fail "development profile still exposes program enable flags"
fi

check_import() {
  local file="$1"
  local import_path="$2"

  grep -Fq "$import_path" "$file" || fail "$file does not import $import_path"
}

check_no_granular_program_imports() {
  local pathspec="$1"

  if grep -nE '\.\./\.\./home/programs/.+' "$pathspec" >/tmp/program-imports-granular.txt; then
    cat /tmp/program-imports-granular.txt >&2
    fail "$pathspec still imports individual home/programs modules"
  fi
}

check_darwin_host_imports() {
  local file="$1"

  check_import "$file" "../../home/programs"
  check_no_granular_program_imports "$file"
}

check_nixos_template_imports() {
  local file="$1"

  check_import "$file" "../../home/programs"
  check_no_granular_program_imports "$file"
}

check_darwin_host_imports hosts/mbp/home.nix
check_darwin_host_imports hosts/mbp2/home.nix
check_darwin_host_imports templates/host/home.nix
check_nixos_template_imports templates/nixos-desktop/home.nix

printf 'program-imports: ok\n'
