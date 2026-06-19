#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail() {
  printf 'sops-imports: %s\n' "$*" >&2
  exit 1
}

check_host() {
  local host="$1"
  local home_file="hosts/${host}/home.nix"
  local sops_file="hosts/${host}/sops.nix"

  [ -f "$sops_file" ] || fail "$sops_file is missing"

  grep -Fq './sops.nix' "$home_file" || fail "$home_file does not import ./sops.nix"
  grep -Fq '../../home/profiles/capabilities/sops.nix' "$sops_file" ||
    fail "$sops_file does not import shared SOPS capability"

  if grep -Fn '../../home/profiles/capabilities/sops.nix' "$home_file" >/tmp/sops-imports-direct.txt; then
    cat /tmp/sops-imports-direct.txt >&2
    fail "$home_file imports the shared SOPS capability directly"
  fi

  if grep -n 'profiles\.sops' "$home_file" >/tmp/sops-imports-profile-config.txt; then
    cat /tmp/sops-imports-profile-config.txt >&2
    fail "$home_file configures profiles.sops outside the host-local SOPS import"
  fi
}

check_host mbp
check_host mbp2

printf 'sops-imports: ok\n'
