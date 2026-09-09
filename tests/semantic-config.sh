#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
flake_ref="path:${repo_root}"

fail() {
  printf 'semantic-config: %s\n' "$*" >&2
  exit 1
}

# Nix interpolation must stay literal inside the --expr expression.
# shellcheck disable=SC2016
result="$(
  FLAKE_REF="$flake_ref" nix eval --impure --raw --expr '
    let
      flake = builtins.getFlake (builtins.getEnv "FLAKE_REF");
      inventory = flake.hostInventory;
      hosts = builtins.attrValues inventory;
      darwinHosts = builtins.filter (host: host.type == "darwin") hosts;
      nixosHosts = builtins.filter (host: host.type == "nixos") hosts;
      expectedDarwinNames = map (host: host.name) darwinHosts;
      expectedNixosNames = map (host: host.name) nixosHosts;
      actualDarwinNames = builtins.attrNames flake.darwinConfigurations;
      actualNixosNames = builtins.attrNames flake.nixosConfigurations;
      expectedRevision = flake.rev or flake.dirtyRev or null;
      checkHost = spec:
        let
          configurations = flake.${spec.configuration};
          host = configurations.${spec.name};
          home = host.config.home-manager.users.${spec.username};
          drvPath = builtins.unsafeDiscardStringContext host.config.system.build.toplevel.drvPath;
        in
        if host.pkgs.stdenv.hostPlatform.system != spec.system then
          throw "${spec.name}: expected ${spec.system}, got ${host.pkgs.stdenv.hostPlatform.system}"
        else if host.config.device.type != spec.device then
          throw "${spec.name}: expected device ${spec.device}, got ${host.config.device.type}"
        else if host.config.device.hostname != spec.name then
          throw "${spec.name}: device hostname does not match inventory name"
        else if home.home.username != spec.username then
          throw "${spec.name}: Home Manager username does not match inventory"
        else if !(builtins.isString home.home.stateVersion) then
          throw "${spec.name}: Home Manager stateVersion must be host-specific and string-valued"
        else if host.config.system.configurationRevision != expectedRevision then
          throw "${spec.name}: configurationRevision does not match flake revision"
        else
          builtins.seq drvPath true;
    in
    if actualDarwinNames != expectedDarwinNames then
      throw "Darwin configuration names do not match the shared host inventory"
    else if actualNixosNames != expectedNixosNames then
      throw "NixOS configuration names do not match the shared host inventory"
    else if builtins.all checkHost hosts then
      "ok"
    else
      throw "semantic host validation failed"
  '
)"

[[ $result == "ok" ]] || fail "unexpected evaluation result: $result"
printf 'semantic-config: ok\n'
