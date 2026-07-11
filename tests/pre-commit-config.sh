#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
flake_ref="git+file://${repo_root}"
system="$(nix eval --impure --raw --expr builtins.currentSystem)"
expected_config="$(
  nix eval --raw --no-update-lock-file \
    "${flake_ref}#checks.${system}.pre-commit-check.config.configFile"
)"
tmp_root="$(mktemp -d)"

cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT

fail() {
  printf 'pre-commit-config: %s\n' "$*" >&2
  exit 1
}

make_repo() {
  local path="$1"
  mkdir -p "$path"
  git -C "$path" init --quiet
}

run_dev_shell() {
  local path="$1"
  (
    cd "$path"
    nix develop "$flake_ref" --no-update-lock-file --command true
  )
}

dangling_repo="$tmp_root/dangling"
make_repo "$dangling_repo"
ln -s /nix/store/nix-fleet-phase-1-missing-config \
  "$dangling_repo/.pre-commit-config.yaml"
run_dev_shell "$dangling_repo"

[[ -L "$dangling_repo/.pre-commit-config.yaml" ]] ||
  fail "dangling case did not leave a symlink"
actual_target="$(readlink "$dangling_repo/.pre-commit-config.yaml")"
[[ $actual_target == "$expected_config" ]] ||
  fail "expected $expected_config, got $actual_target"
[[ -e "$dangling_repo/.pre-commit-config.yaml" ]] ||
  fail "replacement symlink target does not exist"

regular_repo="$tmp_root/regular"
make_repo "$regular_repo"
printf 'repos: []\n' >"$regular_repo/.pre-commit-config.yaml"
run_dev_shell "$regular_repo"

[[ ! -L "$regular_repo/.pre-commit-config.yaml" ]] ||
  fail "regular config was replaced by a symlink"
[[ "$(cat "$regular_repo/.pre-commit-config.yaml")" == "repos: []" ]] ||
  fail "regular config content changed"

printf 'pre-commit-config: ok\n'
