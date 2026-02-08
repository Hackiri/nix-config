# This file defines overlays that add custom packages to nixpkgs
final: prev: let
  # Import all packages from the pkgs directory
  customPkgs = import ../pkgs {pkgs = prev;};

  # Import emacs overlay
  emacsOverlay = import ./emacs.nix;
in
  {
    inherit (customPkgs) kube-packages;

    # Override nodejs to skip tests (network tests fail in sandbox)
    nodejs = prev.nodejs.overrideAttrs (_: {
      doCheck = false;
    });

    # Use pythonPackagesExtensions to apply to ALL Python interpreters
    # This affects even Python environments created via python.override
    pythonPackagesExtensions =
      (prev.pythonPackagesExtensions or [])
      ++ [
        (_: pySuper: {
          azure-core = pySuper.azure-core.overridePythonAttrs (_: {
            doCheck = false;
          });
          # Skip twisted tests - they hang indefinitely on macOS due to network-related tests
          # See: https://github.com/NixOS/nixpkgs/issues/twisted-darwin-tests
          twisted = pySuper.twisted.overridePythonAttrs (_: {
            doCheck = false;
          });
        })
      ];
  }
  // (emacsOverlay final prev)
# Merge emacs overlay

