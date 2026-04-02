# Device metadata options — set per-host via meta.nix, queried by modules
{
  config,
  lib,
  ...
}: {
  options.device = {
    type = lib.mkOption {
      type = lib.types.enum ["desktop" "laptop" "server" "vm"];
      description = "Physical device form factor.";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Human-readable host identifier.";
    };

    isGraphical = lib.mkOption {
      type = lib.types.bool;
      default = config.device.type == "desktop" || config.device.type == "laptop";
      readOnly = true;
      description = "Whether this device runs a graphical environment (derived from type).";
    };
  };
}
