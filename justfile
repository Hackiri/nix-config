# justfile for nix-config

# List available tasks
default:
    @just --list

# Format all files
fmt:
    nix fmt

# Lint all Nix files
lint:
    deadnix .
    statix check .

# Update flake.lock
update:
    nix flake update

# Build the system configuration (NixOS)
build host='':
    nh os build . {{ if host == "" { "" } else { "--hostname " + host } }}

# Switch to the system configuration (NixOS)
switch host='':
    nh os switch . {{ if host == "" { "" } else { "--hostname " + host } }}

# Build darwin configuration
darwin-build host='':
    nh darwin build . {{ if host == "" { "" } else { "--hostname " + host } }}

# Switch to darwin configuration
darwin-switch host='':
    nh darwin switch . {{ if host == "" { "" } else { "--hostname " + host } }}

# Scaffold a new host from template
host name:
    nix flake new -t .#host hosts/{{name}}
