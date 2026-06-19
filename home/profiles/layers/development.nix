# Development layer - shared development workspace foundation.
# Inherits from layers/foundation.nix; program modules come from home/programs/default.nix.
#
# Program selection is import-driven in home/programs/default.nix.
# Note: For sops-encrypted git credentials, import a host-local sops.nix that
#       imports capabilities/sops.nix and sets profiles.sops.enable = true.
_: {
  imports = [
    # Base: Foundation layer (home defaults and core package bundles)
    ./foundation.nix
  ];
}
