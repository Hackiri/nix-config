#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail() {
  printf 'capability-imports: %s\n' "$*" >&2
  exit 1
}

if git grep -nE 'profiles\.(redis|agentDev|sops)\b|profiles\.kubernetes\.(enable|includeLocalDev)\b' -- \
  home/profiles/capabilities hosts templates README.md PROFILE_MAP.md home/profiles/README.md >/tmp/capability-imports-profile-options.txt; then
  cat /tmp/capability-imports-profile-options.txt >&2
  fail "capabilities still expose profile options other than profiles.kubernetes.toolSet"
fi

if git grep -nE 'mkEnableOption|mkIf cfg\.enable|cfg\.enable' -- home/profiles/capabilities >/tmp/capability-imports-enable-gates.txt; then
  cat /tmp/capability-imports-enable-gates.txt >&2
  fail "capabilities still use enable gates"
fi

grep -Fq '../../home/profiles/capabilities/kubernetes.nix' hosts/mbp/home.nix ||
  fail "hosts/mbp/home.nix does not import Kubernetes capability"
grep -Fq '../../home/profiles/capabilities/kubernetes.nix' hosts/mbp2/home.nix ||
  fail "hosts/mbp2/home.nix does not import Kubernetes capability"

grep -Fq 'profiles.kubernetes.toolSet = "complete";' hosts/mbp/home.nix ||
  fail "hosts/mbp/home.nix does not set Kubernetes toolSet"
grep -Fq 'profiles.kubernetes.toolSet = "complete";' hosts/mbp2/home.nix ||
  fail "hosts/mbp2/home.nix does not set Kubernetes toolSet"

if grep -Fq '../../home/profiles/capabilities/agent-dev.nix' hosts/mbp/home.nix; then
  fail "hosts/mbp/home.nix imports inactive agent-dev capability"
fi

if grep -Fq '../../home/profiles/capabilities/redis.nix' hosts/mbp2/home.nix; then
  fail "hosts/mbp2/home.nix imports inactive Redis capability"
fi

nix eval --raw .#darwinConfigurations.mbp.config.system.build.toplevel.drvPath >/dev/null
nix eval --raw .#darwinConfigurations.mbp2.config.system.build.toplevel.drvPath >/dev/null

printf 'capability-imports: ok\n'
