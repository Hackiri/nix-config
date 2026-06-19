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

if git grep -nE '(\.\./)+programs' -- home/profiles >/tmp/program-imports-profile-paths.txt; then
  cat /tmp/program-imports-profile-paths.txt >&2
  fail "home/profiles still imports home/programs modules"
fi

if git grep -n 'profiles\.development' -- home/programs >/tmp/program-imports-profile-gates.txt; then
  cat /tmp/program-imports-profile-gates.txt >&2
  fail "home/programs still depends on profiles.development gates"
fi

printf 'program-imports: ok\n'
