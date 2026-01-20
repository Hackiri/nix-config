# This file defines overlays that add custom packages to nixpkgs
final: prev: let
  # Import all packages from the pkgs directory
  customPkgs = import ../pkgs {pkgs = prev;};

  # Import emacs overlay
  emacsOverlay = import ./emacs.nix;
in
  {
    # Add all custom packages to the 'custom' namespace
    custom = customPkgs;

    # Use inherit syntax to avoid warnings
    inherit (customPkgs) dev-tools devshell kube-packages;

    # Override nodejs to skip tests (network tests fail in sandbox)
    nodejs = prev.nodejs.overrideAttrs (oldAttrs: {
      doCheck = false;
    });

    # Use pythonPackagesExtensions to apply to ALL Python interpreters
    # This affects even Python environments created via python.override
    pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [
      (pySelf: pySuper: {
        azure-core = pySuper.azure-core.overridePythonAttrs (old: {
          doCheck = false;
        });
        # Skip twisted tests - they hang indefinitely on macOS due to network-related tests
        # See: https://github.com/NixOS/nixpkgs/issues/twisted-darwin-tests
        twisted = pySuper.twisted.overridePythonAttrs (old: {
          doCheck = false;
        });
      })
    ];
  }
  // (emacsOverlay final prev)
# Merge emacs overlay

