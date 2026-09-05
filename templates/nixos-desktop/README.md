# NixOS Desktop Host Template

Copy this directory into `hosts/<name>` for a GNOME desktop NixOS machine with
Home Manager, PipeWire, printing, and placeholder hardware config.
The explicit NixOS workstation role also enables OpenSSH and Podman.

## Usage

```bash
cp -r templates/nixos-desktop hosts/<name>
```

Then replace the placeholder UUIDs in `hardware-configuration.nix` with output
from `nixos-generate-config --show-hardware-config` on the target machine.
