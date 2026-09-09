#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

python3 <<'PY'
from pathlib import Path
import re

root = Path("home/programs/default.nix").read_text()
imports = re.findall(r"^\s+(\./[^\s#]+)$", root, re.M)
expected = [
    "./theme", "./security", "./shells", "./development",
    "./editors", "./terminals", "./utilities",
]
assert imports == expected, (imports, expected)

category_expectations = {
    "home/programs/security/default.nix": {"./ssh.nix"},
    "home/programs/shells/default.nix": {"./zsh/aliases.nix", "./bash", "./zsh", "./starship"},
    "home/programs/development/default.nix": {"./git", "./direnv"},
    "home/programs/editors/default.nix": {"./neovim", "./emacs", "./neovide"},
    "home/programs/terminals/default.nix": {"./kitty", "./sesh", "./tmux"},
    "home/programs/utilities/default.nix": {"./btop", "./claude", "./yazi", "./aerospace"},
}
for path, expected_set in category_expectations.items():
    text = Path(path).read_text()
    actual = set(re.findall(r"^\s+(\./[^\s#]+)$", text, re.M))
    assert actual == expected_set, (path, actual, expected_set)

terminals = Path("home/programs/terminals/default.nix").read_text()
for disabled in ("./alacritty", "./ghostty", "./wezterm"):
    assert not re.search(rf"^\s+{re.escape(disabled)}$", terminals, re.M), disabled

layer = Path("home/profiles/layers/development.nix").read_text()
for required in ("./foundation.nix", "../../packages/development"):
    assert re.search(rf"^\s+{re.escape(required)}$", layer, re.M), required
assert "../../programs/development" not in layer

hook = Path("home/programs/shells/zsh/direnv-hook.nix").read_text()
devshells = Path("lib/devshells.nix").read_text()
assert "_devshell_pkgs" not in hook
assert "lib/devshells.nix" in hook
assert "python314Packages.pyyaml" in devshells
assert "python314Packages.pyyaml" not in hook
assert "sha256sum" in hook
assert "git rev-parse --git-path info/exclude" in hook

sops = Path("home/profiles/capabilities/sops.nix").read_text()
assert "core.hooksPath =" not in sops
assert "init.templateDir" in sops
assert "install-sops-git-hooks" in sops
assert ".config/git/template/hooks/post-checkout" in sops
assert "post-checkout.local" in sops and "post-merge.local" in sops

docs = "\n".join(
    Path(path).read_text()
    for path in ("README.md", "templates/host/README.md", "home/profiles/README.md", "PROFILE_MAP.md")
)
assert "add or remove programs by editing `home/programs/default.nix`" not in docs
assert "Program modules are selected by editing `home/programs/default.nix`" not in docs
assert "category `default.nix` files select individual" in docs
root_readme = Path("README.md").read_text()
assert "doom sync" in root_readme
assert "a rebuild is not offline" in root_readme
PY

for file in \
  home/programs/default.nix \
  home/programs/development/default.nix \
  home/programs/terminals/default.nix \
  home/programs/utilities/default.nix \
  home/profiles/layers/development.nix \
  home/programs/shells/zsh/direnv-hook.nix \
  home/profiles/capabilities/sops.nix \
  lib/devshells.nix; do
  nix-instantiate --parse "$file" >/dev/null
done

fixture="$(mktemp -d)"
init_script="$(mktemp)"
trap 'rm -rf "$fixture" "$init_script"' EXIT
coreutils_prefix="$fixture/coreutils"
mkdir -p "$coreutils_prefix/bin"
ln -s "$(command -v sha256sum)" "$coreutils_prefix/bin/sha256sum"
diffutils_prefix="/usr"

COREUTILS_PREFIX="$coreutils_prefix" DIFFUTILS_PREFIX="$diffutils_prefix" \
  nix eval --impure --raw \
  --expr 'let
    coreutils = builtins.getEnv "COREUTILS_PREFIX";
    diffutils = builtins.getEnv "DIFFUTILS_PREFIX";
    module = import ./home/programs/shells/zsh/direnv-hook.nix {
      config.home.homeDirectory = toString ./..;
      pkgs = {
        inherit coreutils diffutils;
      };
    };
  in module.config.programs.zsh.initContent' >"$init_script"

INIT_SCRIPT="$init_script" FIXTURE="$fixture" zsh <<'ZSH'
set -e
export XDG_CACHE_HOME="$FIXTURE/cache"
source "$INIT_SCRIPT"
direnv() { :; }

mkdir -p "$FIXTURE/a_b" "$FIXTURE/a/b"
cd "$FIXTURE/a_b"
first="$(_direnv_cache_dir)"
cd "$FIXTURE/a/b"
second="$(_direnv_cache_dir)"
[[ "$first" != "$second" ]]
first_key="${first:t}"
[[ "$first_key" =~ '^[0-9a-f]{64}$' ]]

project="$FIXTURE/project"
mkdir -p "$project"
cd "$project"
print -r -- 'export HAND_WRITTEN=1' > .envrc
before="$(<.envrc)"
if _direnv_setup "$(_direnv_cache_dir)" 2>/dev/null; then
  print -u2 'hand-written .envrc was accepted as managed'
  exit 1
fi
[[ "$(<.envrc)" == "$before" ]]

rm .envrc
cache_dir="$(_direnv_cache_dir)"
_direnv_gen_flake "$cache_dir" python
_direnv_setup "$cache_dir"
grep -qxF '# Managed by nix-config direnv auto-shell' .envrc
grep -q 'shellNames = \[ "python" \];' "$cache_dir/flake.nix"
grep -q 'url = "path:.*/nix-config/lib";' "$cache_dir/flake.nix"
grep -q 'nixConfig + "/devshells.nix"' "$cache_dir/flake.nix"
nix flake lock "$cache_dir" >/dev/null
nix develop "$cache_dir" --no-update-lock-file --command true
print -r -- '# stale sentinel' >> "$cache_dir/flake.nix"
_direnv_gen_flake "$cache_dir" python
! grep -q 'stale sentinel' "$cache_dir/flake.nix"
if _direnv_gen_flake "$cache_dir" 'python"; builtins.abort "injected"; #'; then
  print -u2 'unknown shell name was accepted'
  exit 1
fi

rm -rf "$cache_dir"
print -r -- "use flake $(_direnv_cache_base)/legacy_path" > .envrc
print -r -- '[project]' > pyproject.toml
_direnv_auto_detect
grep -qxF '# Managed by nix-config direnv auto-shell' .envrc
[[ -f "$(_direnv_cache_dir)/flake.nix" ]]

repo="$FIXTURE/repo"
worktree="$FIXTURE/worktree"
mkdir -p "$repo"
cd "$repo"
git init -q
git config user.name test
git config user.email test@example.invalid
git config commit.gpgsign false
: > tracked
git add tracked
git commit -qm initial
git -c core.hooksPath=/dev/null worktree add -q -b test-worktree "$worktree"
cd "$worktree"
_direnv_git_exclude
exclude_file="$(git rev-parse --git-path info/exclude)"
grep -qxF '.envrc' "$exclude_file"
grep -qxF '.direnv' "$exclude_file"
ZSH

# Keep the Nix expression literal; the inner interpolation belongs to Nix.
# shellcheck disable=SC2016
installer_out="$(nix build --impure --no-link --print-out-paths --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = flake.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
    module = import ./home/profiles/capabilities/sops.nix {
      config = {
        home.homeDirectory = "/tmp/home-layout-test";
        programs.zsh.enable = false;
        programs.bash.enable = false;
        sops.secrets = {
          git-userName.path = "/tmp/missing-name";
          git-userEmail.path = "/tmp/missing-email";
          git-signingKey-test.path = "/tmp/missing-key";
        };
      };
      hostName = "test";
      lib = pkgs.lib // { hm.dag.entryAfter = _: value: value; };
      inherit pkgs;
    };
  in builtins.elemAt module.config.home.packages 0
')"

hook_repo="$fixture/hook-repo"
mkdir -p "$hook_repo"
git -C "$hook_repo" init -q
git -C "$hook_repo" config core.hooksPath .git/hooks
mkdir -p "$hook_repo/.git/hooks"
# `git init` copies this user's init.templateDir hooks in with the Nix store's
# read-only mode, so drop the copy before writing the fixture's own hook.
rm -f "$hook_repo/.git/hooks/post-checkout" "$hook_repo/.git/hooks/post-merge"
# Keep $GIT_DIR literal for the generated hook to expand at runtime.
# shellcheck disable=SC2016
printf '#!/bin/sh\nprintf local-checkout >"$GIT_DIR/local-ran"\n' >"$hook_repo/.git/hooks/post-checkout"
chmod +x "$hook_repo/.git/hooks/post-checkout"
(
  cd "$hook_repo"
  "$installer_out/bin/install-sops-git-hooks" >/dev/null
  test -x .git/hooks/post-checkout.local
  grep -Fq '# Managed by nix-config sops git hooks' .git/hooks/post-checkout
  GIT_DIR="$hook_repo/.git" .git/hooks/post-checkout old new 1 >/dev/null
  test "$(cat .git/local-ran)" = local-checkout
  "$installer_out/bin/install-sops-git-hooks" >/dev/null
  test -x .git/hooks/post-checkout.local
)

shared_hooks="$fixture/shared-hooks"
if git -C "$hook_repo" -c core.hooksPath="$shared_hooks" \
  "$installer_out/bin/install-sops-git-hooks" >/dev/null 2>&1; then
  echo "shared core.hooksPath was accepted" >&2
  exit 1
fi
test ! -e "$shared_hooks"

echo "home layout regression tests: PASS"
