# Auto-discovers and composes all overlay modules in this directory.
# Each .nix file (except default.nix) is a standard overlay: final: prev: { ... }
final: prev: let
  dir = builtins.readDir ./.;
  overlayFiles =
    builtins.filter
    (name: name != "default.nix" && builtins.match ".*\\.nix" name != null)
    (builtins.attrNames dir);
  overlays = map (name: import (./. + "/${name}")) overlayFiles;
in
  (prev.lib.composeManyExtensions overlays) final prev
