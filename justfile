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

# Authoritative local and CI validation
check:
    nix flake check --no-update-lock-file --print-build-logs
    bash tests/semantic-config.sh
