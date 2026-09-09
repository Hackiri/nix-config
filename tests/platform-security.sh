#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

fail() {
  printf 'platform-security: %s\n' "$*" >&2
  exit 1
}

# shellcheck disable=SC2016
result="$(
  nix eval --raw --no-update-lock-file .#darwinConfigurations.mbp2 --apply '
    host:
    let
      home = host.config.home-manager.users.wm;
      sshDefaults = home.programs.ssh.settings."*".data;
      activationNames = builtins.attrNames home.home.activation;
      emacsSource = home.home.file.".config/emacs".source;
      casks = host.config.homebrew.casks;
      librewolfEntries = builtins.filter (entry: entry.name == "librewolf") casks;
      librewolfHasNoHook = builtins.length librewolfEntries == 1
        && (builtins.head librewolfEntries).postinstall == null;
    in
    if builtins.any (name: builtins.hasAttr name sshDefaults) [ "KexAlgorithms" "Ciphers" "MACs" ] then
      throw "SSH algorithm defaults are overridden"
    else if sshDefaults.HashKnownHosts != true || sshDefaults.ForwardAgent != false then
      throw "SSH host/agent hardening changed"
    else if sshDefaults.ServerAliveInterval != 60 || sshDefaults.ServerAliveCountMax != 3 then
      throw "SSH keepalive hardening changed"
    else if sshDefaults.StrictHostKeyChecking != "ask" || sshDefaults.ConnectTimeout != "30" then
      throw "SSH verification or timeout hardening changed"
    else if host.config.homebrew.onActivation.cleanup != "check" then
      throw "Homebrew cleanup is not non-destructive check mode"
    else if builtins.elem "installDoomEmacs" activationNames || builtins.elem "syncDoomPackages" activationNames then
      throw "Doom installation or sync still runs during activation"
    else if emacsSource.outputHash != "sha256-Clu4VvP7RK5kRsDTVNQCEMj9OcNQqlFyXdAZw5reGbw=" then
      throw "Doom source does not have the reviewed fixed-output hash"
    else if emacsSource.url != "https://github.com/doomemacs/doomemacs.git"
      || emacsSource.rev != "bd38d60b0179dea62cae63ea2cccf376ef65f11f"
      || emacsSource.fetchSubmodules != true then
      throw "Doom source does not have the reviewed GitHub revision and submodule policy"
    else if home.home.sessionVariables.DOOMLOCALDIR != "${home.home.homeDirectory}/.local/share/doom" then
      throw "Doom mutable state is not redirected outside the immutable source"
    else if !librewolfHasNoHook then
      throw "LibreWolf still has a post-install hook"
    else
      "ok"
  '
)"

[[ $result == "ok" ]] || fail "unexpected evaluation result: $result"

emacs_module=home/programs/editors/emacs/default.nix
homebrew_module=modules/services/darwin/homebrew.nix

grep -q 'rev = "bd38d60b0179dea62cae63ea2cccf376ef65f11f";' "$emacs_module" ||
  fail "Doom revision pin is missing"
grep -q 'hash = "sha256-' "$emacs_module" || fail "Doom fixed-output hash is missing"
! grep -Eq 'git clone|git ls-remote|syncDoomPackages' "$emacs_module" ||
  fail "activation-time Doom network/package operation remains"
! grep -q 'com.apple.quarantine' "$homebrew_module" ||
  fail "LibreWolf quarantine stripping remains"
grep -q 'MAS installs are mutable and non-reproducible' "$homebrew_module" ||
  fail "MAS mutability documentation is missing"

printf 'platform-security: ok\n'
