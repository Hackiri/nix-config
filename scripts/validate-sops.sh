#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
expected_keys="$tmp_dir/expected-keys.json"

# Evaluate only declared secret attribute names. No secret values are decrypted,
# evaluated, written to output, or included in diagnostics.
REPO_ROOT="$repo_root" nix eval --impure --json --no-update-lock-file --expr '
  let
    flake = builtins.getFlake ("path:" + builtins.getEnv "REPO_ROOT");
    configurations = flake.darwinConfigurations // flake.nixosConfigurations;
    keysForConfiguration = configuration:
      let users = configuration.config.home-manager.users or {};
      in builtins.concatLists (
        builtins.map
          (user:
            if user ? sops && user.sops ? secrets
            then builtins.attrNames user.sops.secrets
            else [])
          (builtins.attrValues users)
      );
  in builtins.attrNames (builtins.listToAttrs (
    builtins.map (name: { inherit name; value = null; })
      (builtins.concatLists (builtins.map keysForConfiguration (builtins.attrValues configurations)))
  ))
' >"$expected_keys"

python3 "$repo_root/scripts/validate-sops.py" \
  --secrets "$repo_root/secrets/secrets.yaml" \
  --policy "$repo_root/.sops.yaml" \
  --expected-keys-json "$expected_keys" \
  --logical-secret-path secrets/secrets.yaml
