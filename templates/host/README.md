# Host Template

Scaffold for adding a new host to this nix-config.

## Usage

```bash
# 1. Copy template to hosts/
cp -r templates/host hosts/<name>

# 2. Edit configuration.nix — uncomment the right platform import
#    Darwin: ../../modules/system/darwin
#    NixOS:  ../../modules/system/nixos

# 3. Edit home.nix — uncomment the right platform profile
#    Darwin: ../../home/profiles/platform/darwin.nix
#    NixOS:  ../../home/profiles/platform/nixos.nix

# 4. Register the host in lib/builders.nix (or flake.nix)
#    Darwin: builders.mkDarwin { name = "<name>"; system = "aarch64-darwin"; }
#    NixOS:  builders.mkNixOS  { name = "<name>"; system = "x86_64-linux"; }

# 5. Build and test
darwin-rebuild build --flake .#<name>   # Darwin
nixos-rebuild build --flake .#<name>    # NixOS
```

## Available Profiles

See `home/profiles/README.md` and `PROFILE_MAP.md` for the full profile hierarchy.
