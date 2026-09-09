#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail() {
  printf 'determinate-darwin: %s\n' "$*" >&2
  exit 1
}

# Keep the expression literal so Nix, not the shell, interprets it.
# shellcheck disable=SC2016
result="$(
  nix eval --raw --no-update-lock-file .#darwinConfigurations.mbp2 --apply '
    host:
    let
      config = host.config;
    in
    if config.determinateNix.enable != true then
      throw "Determinate Nix is not enabled for mbp2"
    else if config.determinateNix.customSettings.download-buffer-size != 268435456 then
      throw "Determinate Nix download-buffer-size changed"
    else if config.nix-homebrew.enable != true then
      throw "nix-homebrew is not enabled for mbp2"
    else if config.nix-homebrew.user != "wm" then
      throw "nix-homebrew user changed"
    else
      "ok"
  '
)"

[[ $result == "ok" ]] || fail "unexpected evaluation result: $result"
printf 'determinate-darwin: ok\n'
