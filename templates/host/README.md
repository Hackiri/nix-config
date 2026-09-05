# Host Template

Scaffold for adding a new host to this nix-config.

## Usage

```bash
# 1. Copy template to hosts/
cp -r templates/host hosts/<name>

# 2. Edit meta.nix
#    Set type/system/device for the host
#
# 3. Edit configuration.nix — uncomment the right platform import
#    Darwin: ../../modules/system/darwin
#    NixOS:  ../../modules/system/nixos
#    Keep or remove the explicit workstation role imports to select Homebrew
#    (Darwin) or OpenSSH/Podman (NixOS).

# 4. Edit home.nix — choose the right platform profile, add any optional
#    capabilities you need, and keep ../../home/programs
#    imported for centrally managed program modules.
# 5. Build and test
darwin-rebuild build --flake .#<name>   # Darwin
nixos-rebuild build --flake .#<name>    # NixOS
```

`home/programs/default.nix` selects program categories. Select individual
programs in the corresponding category's `default.nix`.

```nix
{
  imports =
    [
      ../../home/profiles/platforms/darwin.nix
      ../../home/programs
    ];
}
```

## Available Profiles

See `home/profiles/README.md` and `PROFILE_MAP.md` for the full profile hierarchy.
