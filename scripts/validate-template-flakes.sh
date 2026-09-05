#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
templates=(node python ai-python rust go)
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

fail() {
  printf 'template-flakes: %s\n' "$*" >&2
  exit 1
}

for template in "${templates[@]}"; do
  source_dir="$repo_root/templates/$template"
  work_dir="$tmp_root/$template"
  [[ -f "$source_dir/flake.nix" ]] || fail "$template is missing flake.nix"
  [[ ! -e "$source_dir/flake.lock" ]] ||
    fail "$template has an unexpected repository lock; this validator intentionally generates temporary locks"

  mkdir -p "$work_dir"
  cp -R "$source_dir/." "$work_dir/"

  # Policy: reusable templates intentionally have no committed lock. Generate a
  # lock only in this disposable copy, then evaluate every declared system
  # without building. This catches standalone input/output errors while proving
  # validation never writes a lock into templates/ in the repository.
  printf 'template-flakes: validating %s\n' "$template"
  if ! nix flake lock "$work_dir"; then
    fail "$template could not generate a temporary lock"
  fi
  if ! nix flake check --all-systems --no-build --no-update-lock-file "$work_dir"; then
    fail "$template failed standalone all-systems evaluation"
  fi
  [[ ! -e "$source_dir/flake.lock" ]] ||
    fail "$template validation wrote flake.lock into the repository"
done

printf 'template-flakes: all %d standalone templates are valid\n' "${#templates[@]}"
