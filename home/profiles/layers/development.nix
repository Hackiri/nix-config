# Development layer - shared development workspace composition.
# Inherits the foundation and adds the development package role.
# Note: For sops-encrypted git credentials, import a host-local sops.nix that
#       imports capabilities/sops.nix and sets profiles.sops.enable = true.
_: {
  imports = [
    ./foundation.nix
    ../../packages/development
  ];
}
