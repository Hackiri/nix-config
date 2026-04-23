# NixOS Desktop Host Template

Copy this directory into `hosts/<name>` for a GNOME desktop NixOS machine with
Home Manager, Hermes, PipeWire, printing, and placeholder hardware config.

## Usage

```bash
cp -r templates/nixos-desktop hosts/<name>
```

Then replace the placeholder UUIDs in `hardware-configuration.nix` with output
from `nixos-generate-config --show-hardware-config` on the target machine.
