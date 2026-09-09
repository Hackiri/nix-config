#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

fail() {
  printf 'agent-dev: %s\n' "$*" >&2
  exit 1
}

module="home/profiles/capabilities/agent-dev.nix"
grep -q 'git}/bin/git rev-parse --verify --end-of-options' "$module" || fail "base ref is not verified fail-closed with the pinned Git"
grep -q 'mapfile -d "" -t changed_files' "$module" || fail "changed paths are not collected as a NUL-delimited array"
grep -q 'nix eval --raw --no-update-lock-file' "$module" || fail "host evaluation does not use the pure flake interface"
if grep -q 'nix eval --impure' "$module"; then
  fail "host evaluation exposes inherited environment values"
fi

build_agent_package() {
  local package_name="$1"
  PACKAGE_NAME="$package_name" nix build --no-link --print-out-paths --impure --expr '
    let
      flake = builtins.getFlake (toString ./.);
      pkgs = import flake.inputs.nixpkgs.outPath { system = builtins.currentSystem; };
      module = import ./home/profiles/capabilities/agent-dev.nix {
        config.programs = {
          bash.enable = false;
          zsh.enable = false;
        };
        hostName = "mbp2";
        hostInventory = flake.hostInventory;
        inherit (pkgs) lib;
        inherit pkgs;
      };
      packages = module.config.home.packages;
      matches = builtins.filter (package: (package.name or "") == builtins.getEnv "PACKAGE_NAME") packages;
    in
      assert builtins.length matches == 1;
      builtins.head matches
  '
}

agent_guard_out="$(build_agent_package agent-guard)"
agent_eval_out="$(build_agent_package agent-eval-host)"

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

git -C "$tmp_root" init -q
git -C "$tmp_root" config user.name test
git -C "$tmp_root" config user.email test@example.invalid
git -C "$tmp_root" config commit.gpgsign false
printf '{}\n' >"$tmp_root/baseline.nix"
git -C "$tmp_root" add baseline.nix
git -C "$tmp_root" commit -qm baseline

if "$agent_guard_out/bin/agent-guard" --definitely-not-a-ref >"$tmp_root/out" 2>"$tmp_root/err"; then
  fail "invalid base ref unexpectedly passed"
fi
grep -q 'invalid base ref' "$tmp_root/err" || fail "invalid base ref lacks a controlled diagnostic"
if grep -q 'Traceback' "$tmp_root/err"; then
  fail "invalid base ref emitted a traceback"
fi

printf '{}\n' >"$tmp_root/--option.nix"
printf '{}\n' >"$tmp_root/line
break.nix"
(
  cd "$tmp_root"
  "$agent_guard_out/bin/agent-guard" HEAD >/dev/null
) || fail "option-like or newline-containing paths were not handled safely"

rm -f "$tmp_root/--option.nix" "$tmp_root/line
break.nix"
mkdir -p "$tmp_root/home"
printf '{}\n' >"$tmp_root/home/deleted.nix"
git -C "$tmp_root" add home/deleted.nix
git -C "$tmp_root" commit -qm add-deletion-fixture
rm "$tmp_root/home/deleted.nix"
if (
  cd "$tmp_root"
  "$agent_guard_out/bin/agent-guard" HEAD >"$tmp_root/out" 2>"$tmp_root/err"
); then
  fail "deleted host-impacting path unexpectedly passed in a non-flake fixture"
fi
grep -q 'evaluating configured hosts' "$tmp_root/out" || fail "deleted paths do not trigger host evaluation"

git -C "$tmp_root" add -u
git -C "$tmp_root" commit -qm remove-deletion-fixture
mkdir -p "$tmp_root/secrets" "$tmp_root/docs"
printf '{}\n' >"$tmp_root/secrets/key.yaml"
git -C "$tmp_root" add secrets/key.yaml
git -C "$tmp_root" commit -qm add-secret-path-fixture
mv "$tmp_root/secrets/key.yaml" "$tmp_root/docs/key.yaml"
if (
  cd "$tmp_root"
  "$agent_guard_out/bin/agent-guard" HEAD >"$tmp_root/out" 2>"$tmp_root/err"
); then
  fail "rename from a secret-sensitive path unexpectedly passed"
fi
grep -q 'secret-sensitive path changed' "$tmp_root/err" || fail "rename source path bypassed secret blocking"

cp "$tmp_root/.git/index" "$tmp_root/.git/index.good"
printf 'invalid-index\n' >"$tmp_root/.git/index"
if discovery_output="$({
  cd "$tmp_root"
  "$agent_guard_out/bin/agent-guard" HEAD
} 2>&1)"; then
  fail "changed-file discovery failure unexpectedly passed"
fi
mv "$tmp_root/.git/index.good" "$tmp_root/.git/index"
grep -q 'changed-file discovery failed' <<<"$discovery_output" || fail "discovery failure lacks a controlled diagnostic"

eval_root="$tmp_root/repo?dir=alternate"
mkdir -p "$eval_root/home"
printf '%s\n' \
  '{' \
  '  outputs = { self }: {' \
  '    darwinConfigurations.mbp2.config.system.build.toplevel.drvPath =' \
  '      import ./untracked-safe;' \
  '    nixosConfigurations.nixos-eval.config.system.build.toplevel.drvPath =' \
  '      import ./untracked-safe;' \
  '  };' \
  '}' >"$eval_root/flake.nix"
printf '.env\n' >"$eval_root/.gitignore"
printf 'baseline\n' >"$eval_root/home/readme.md"
git -C "$eval_root" init -q
git -C "$eval_root" config user.name test
git -C "$eval_root" config user.email test@example.invalid
git -C "$eval_root" config commit.gpgsign false
git -C "$eval_root" add .gitignore flake.nix home/readme.md
git -C "$eval_root" commit -qm baseline
printf '%s\n' \
  'let' \
  '  inherited = builtins.getEnv "AGENT_SECRET_SENTINEL";' \
  '  ignored = if builtins.pathExists ./.env then builtins.readFile ./.env else "";' \
  'in' \
  '  if inherited == "" && ignored == ""' \
  '  then "/nix/store/00000000000000000000000000000000-safe.drv"' \
  '  else throw (inherited + ignored)' >"$eval_root/untracked-safe"
printf 'DO-NOT-DISCLOSE\n' >"$eval_root/.env"
printf 'changed\n' >>"$eval_root/home/readme.md"
if ! eval_output="$(
  cd "$eval_root"
  PATH=/nonexistent AGENT_SECRET_SENTINEL=DO-NOT-DISCLOSE "$agent_guard_out/bin/agent-guard" HEAD 2>&1
)"; then
  fail "pure host evaluation failed with a hostile PATH or URL-metacharacter repository path"
fi
if grep -q 'DO-NOT-DISCLOSE' <<<"$eval_output"; then
  fail "host evaluation disclosed an inherited or ignored secret value"
fi

symlink_root="$tmp_root/symlink-repo"
mkdir -p "$symlink_root/home" "$symlink_root/ignored"
printf '%s\n' \
  '{' \
  '  outputs = { self }: {' \
  '    darwinConfigurations.mbp2.config.system.build.toplevel.drvPath = import ./home/imported;' \
  '  };' \
  '}' >"$symlink_root/flake.nix"
printf '"/nix/store/00000000000000000000000000000000-safe.drv"\n' >"$symlink_root/home/imported"
printf 'ignored/\n' >"$symlink_root/.gitignore"
git -C "$symlink_root" init -q
git -C "$symlink_root" config user.name test
git -C "$symlink_root" config user.email test@example.invalid
git -C "$symlink_root" config commit.gpgsign false
git -C "$symlink_root" add .gitignore flake.nix home/imported
git -C "$symlink_root" commit -qm baseline
printf 'DO-NOT-DISCLOSE\n' >"$symlink_root/ignored/imported"
rm -rf "${symlink_root:?}/home"
ln -s ignored "$symlink_root/home"
if symlink_output="$(
  cd "$symlink_root"
  "$agent_guard_out/bin/agent-guard" HEAD 2>&1
)"; then
  fail "symlinked evaluation-source ancestor unexpectedly passed"
fi
if grep -q 'DO-NOT-DISCLOSE' <<<"$symlink_output"; then
  fail "evaluation-source copying disclosed a file behind a symlinked ancestor"
fi
grep -q 'evaluation-source copy failed' <<<"$symlink_output" || fail "symlinked ancestor lacks a controlled diagnostic"

drv_path="$(PATH=/nonexistent "$agent_eval_out/bin/agent-eval-host" mbp2)"
[[ $drv_path == /nix/store/*.drv ]] || fail "known host did not evaluate to a derivation"
if "$agent_eval_out/bin/agent-eval-host" evil.name >"$tmp_root/out" 2>"$tmp_root/err"; then
  fail "unknown host unexpectedly evaluated"
fi
grep -q 'unknown host' "$tmp_root/err" || fail "unknown host lacks a controlled diagnostic"

printf 'agent-dev: ok\n'
