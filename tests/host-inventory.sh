#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

fail() {
  printf 'host-inventory: %s\n' "$*" >&2
  exit 1
}

make_host() {
  local root="$1"
  local name="$2"
  local meta="$3"
  mkdir -p "$root/$name"
  printf '%s\n' "$meta" >"$root/$name/meta.nix"
  printf '{}\n' >"$root/$name/configuration.nix"
  printf '{}\n' >"$root/$name/home.nix"
}

eval_inventory() {
  local hosts_dir="$1"
  local body="$2"
  HOSTS_DIR="$hosts_dir" REPO_ROOT="$repo_root" nix eval --impure --raw --expr "
    let
      inventory = import (builtins.toPath (builtins.getEnv \"REPO_ROOT\" + \"/lib/host-inventory.nix\")) {
        hostsDir = builtins.toPath (builtins.getEnv \"HOSTS_DIR\");
        defaultUsername = \"default-user\";
      };
    in builtins.deepSeq inventory ($body)
  "
}

expect_invalid() {
  local label="$1"
  local meta="$2"
  local expected="$3"
  local root="$tmp_root/$label"
  local output
  mkdir -p "$root"
  make_host "$root" bad "$meta"
  if output="$(eval_inventory "$root" '"unexpected-success"' 2>&1)"; then
    fail "$label metadata unexpectedly passed validation"
  fi
  [[ $output == *"$expected"* ]] || fail "$label did not report '$expected': $output"
}

valid_root="$tmp_root/valid"
mkdir -p "$valid_root"
make_host "$valid_root" alpha '{ type = "darwin"; system = "aarch64-darwin"; device = "laptop"; }'
make_host "$valid_root" beta '{ type = "nixos"; system = "aarch64-linux"; device = "vm"; username = "beta-user"; }'
mkdir -p "$valid_root/staging"
printf '{ this = "must not be imported"; }\n' >"$valid_root/staging/meta.nix"
printf '{}\n' >"$valid_root/staging/configuration.nix"

summary="$(eval_inventory "$valid_root" '
  let names = builtins.attrNames inventory;
  in builtins.concatStringsSep ";" [
    (builtins.concatStringsSep "," names)
    inventory.alpha.username
    inventory.beta.username
    inventory.alpha.configuration
    inventory.beta.configuration
  ]
')"
[[ $summary == 'alpha,beta;default-user;beta-user;darwinConfigurations;nixosConfigurations' ]] || fail "unexpected valid inventory: $summary"

expect_invalid unknown-key '{ type = "darwin"; system = "aarch64-darwin"; device = "laptop"; extra = "no"; }' "unknown keys"
expect_invalid missing-key '{ type = "darwin"; system = "aarch64-darwin"; }' "missing required keys"
expect_invalid non-string '{ type = "darwin"; system = "aarch64-darwin"; device = 1; }' "'device' must be a string"
expect_invalid bad-type '{ type = "bsd"; system = "aarch64-darwin"; device = "laptop"; }' "type must be one of"
expect_invalid bad-system '{ type = "nixos"; system = "riscv64-linux"; device = "server"; }' "system must be one of"
expect_invalid bad-device '{ type = "nixos"; system = "x86_64-linux"; device = "tablet"; }' "device must be one of"
expect_invalid inconsistent '{ type = "darwin"; system = "x86_64-linux"; device = "desktop"; }' "is inconsistent"

invalid_name_root="$tmp_root/invalid-name"
mkdir -p "$invalid_name_root"
make_host "$invalid_name_root" evil.name '{ type = "darwin"; system = "aarch64-darwin"; device = "laptop"; }'
if output="$(eval_inventory "$invalid_name_root" '"unexpected-success"' 2>&1)"; then
  fail "invalid host directory name unexpectedly passed validation"
fi
[[ $output == *"host directory name must be a lower-case hostname label"* ]] ||
  fail "invalid host directory name did not produce a controlled diagnostic: $output"

printf 'host-inventory: ok\n'
