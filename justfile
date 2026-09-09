# justfile for nix-config

# List available tasks
default:
    @just --list

# Lint all Nix files (unique action combining multiple tools)
lint:
    deadnix .
    statix check .

# Scaffold a new host from template (unique multi-step or template action)
host name:
    nix flake new -t .#host hosts/{{name}}

# Native flake build/check gate (used directly by non-Linux CI runners)
check-native:
    nix flake check . --no-update-lock-file --print-build-logs

# Cross-system evaluation gate; deliberately evaluates but never builds
check-all-systems:
    nix flake check . --all-systems --no-build --no-update-lock-file

# Authoritative local and CI validation (run once on Linux in CI)
check:
    nix develop . --no-update-lock-file --command just _check

# Implementation of the canonical gate, always entered through the flake dev shell.
_check:
    #!/usr/bin/env bash
    set -euo pipefail

    # Some test scripts are deliberately kept out of git. Run them when they are
    # present in the working tree, and report a skip elsewhere (for example in CI)
    # instead of failing on a missing file.
    optional() {
      local runner="$1" script="$2"
      if [ -f "$script" ]; then
        "$runner" "$script"
      else
        echo "skip (not tracked in git, not present): $script"
      fi
    }

    just check-native
    just check-all-systems
    optional python3 tests/test-ci-validation.py
    optional python3 tests/test-sops-structure.py
    bash scripts/validate-sops.sh
    bash scripts/validate-template-flakes.sh
    optional bash tests/host-inventory.sh
    optional bash tests/host-layout.sh
    optional bash tests/platform-security.sh
    optional bash tests/determinate-darwin.sh
    optional bash tests/agent-dev.sh
    optional bash tests/home-layout.sh
    bash tests/semantic-config.sh
    bash tests/pre-commit-config.sh
