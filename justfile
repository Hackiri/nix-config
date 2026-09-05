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
    nix flake check path:. --no-update-lock-file --print-build-logs

# Cross-system evaluation gate; deliberately evaluates but never builds
check-all-systems:
    nix flake check path:. --all-systems --no-build --no-update-lock-file

# Authoritative local and CI validation (run once on Linux in CI)
check:
    nix develop path:. --no-update-lock-file --command just _check

# Implementation of the canonical gate, always entered through the flake dev shell.
_check:
    just check-native
    just check-all-systems
    python3 tests/test-ci-validation.py
    python3 tests/test-sops-structure.py
    bash scripts/validate-sops.sh
    bash scripts/validate-template-flakes.sh
    bash tests/host-inventory.sh
    bash tests/host-layout.sh
    bash tests/platform-security.sh
    bash tests/determinate-darwin.sh
    bash tests/agent-dev.sh
    bash tests/home-layout.sh
    bash tests/semantic-config.sh
    bash tests/pre-commit-config.sh
