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

# 4. Edit home.nix — uncomment the right platform profile
#    Darwin: ../../home/profiles/platforms/darwin.nix
#    NixOS:  ../../home/profiles/platforms/nixos.nix
#    Then import one terminal module:
#    ../../home/programs/terminals/kitty
#    ../../home/programs/terminals/alacritty
#    ../../home/programs/terminals/ghostty
#    ../../home/programs/terminals/wezterm
# 5. Build and test
darwin-rebuild build --flake .#<name>   # Darwin
nixos-rebuild build --flake .#<name>    # NixOS
```

Program modules are selected through `home/programs/default.nix`.

```nix
let
  programRegistry = import ../../home/programs;
in {
  imports =
    [
      ../../home/profiles/platforms/darwin.nix
      ../../home/packages/development
    ]
    ++ programRegistry.suites.workstation.darwin;
}
```

Use `programRegistry.suites.workstation.nixos` for NixOS hosts.

## Available Profiles

See `home/profiles/README.md` and `PROFILE_MAP.md` for the full profile hierarchy.
