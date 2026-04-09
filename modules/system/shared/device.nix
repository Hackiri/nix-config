# Device metadata options — set per-host via meta.nix, queried by modules
{
  config,
  lib,
  pkgs,
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

    isAppleSilicon = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isDarwin;
      readOnly = true;
      description = "Whether this device is an Apple Silicon Mac (derived from platform).";
    };

    isIntel = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.hostPlatform.isx86_64;
      readOnly = true;
      description = "Whether this device has an Intel/x86_64 CPU (derived from platform).";
    };
  };
}
