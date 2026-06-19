#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail() {
  printf 'package-imports: %s\n' "$*" >&2
  exit 1
}

if git grep -n 'profiles\.development\.packages' -- home hosts templates README.md PROFILE_MAP.md >/tmp/package-imports-profile-packages.txt; then
  cat /tmp/package-imports-profile-packages.txt >&2
  fail "profiles.development.packages is still documented or used"
fi

if git grep -n '../../packages/development' -- home/profiles/layers/development.nix >/tmp/package-imports-layer-import.txt; then
  cat /tmp/package-imports-layer-import.txt >&2
  fail "development profile still imports the development package aggregate"
fi

git grep -q '../../home/packages/development' -- hosts/mbp/home.nix || fail "hosts/mbp/home.nix does not import development packages directly"
git grep -q '../../home/packages/development' -- hosts/mbp2/home.nix || fail "hosts/mbp2/home.nix does not import development packages directly"

mbp_count="$(nix eval .#darwinConfigurations.mbp.config.home-manager.users.wm.home.packages --apply builtins.length)"
mbp2_count="$(nix eval .#darwinConfigurations.mbp2.config.home-manager.users.wm.home.packages --apply builtins.length)"

[ "$mbp_count" = "188" ] || fail "mbp package count changed: expected 188, got $mbp_count"
[ "$mbp2_count" = "196" ] || fail "mbp2 package count changed: expected 196, got $mbp2_count"

nix eval --raw .#darwinConfigurations.mbp.config.system.build.toplevel.drvPath >/dev/null
nix eval --raw .#darwinConfigurations.mbp2.config.system.build.toplevel.drvPath >/dev/null

printf 'package-imports: ok\n'
