# Auto-discovers and composes all overlay modules in this directory.
# Each .nix file (except default.nix) is: { inputs }: final: prev: { ... }
{inputs}: final: prev: let
  dir = builtins.readDir ./.;
  overlayFiles = builtins.filter (
    name: name != "default.nix" && builtins.match ".*\\.nix" name != null
  ) (builtins.attrNames dir);
  overlays = map (name: import (./. + "/${name}") {inherit inputs;}) overlayFiles;

  # Upstream NousResearch/hermes-agent@4440d77 updated package-lock.json
  # without updating nix/lib.nix. Keep this override narrow so it can be
  # removed once upstream replaces the stale npmDepsHash.
  affectedHermesRev = "4440d77bf32d6267775be5eba2189e1ebde0b5b5";
  staleHermesNpmDepsHash = "sha256-m9cjbjzi4SaFCjODfdrawS5e+1ag+MpRn528/upSNqo=";
  fixedHermesNpmDepsHash = "sha256-kbjJksq7limRIYqP3DwI+GNgCXkG96tXcsQqmuEedxo=";
  pkgsWithHermesNpmHashFix = prev.extend (fixedFinal: fixedPrev: {
    fetchNpmDeps = args: let
      hash = args.hash or null;
      hermesRev = inputs.hermes-agent.rev or null;
    in
      fixedPrev.fetchNpmDeps (
        args
        // fixedFinal.lib.optionalAttrs (hermesRev == affectedHermesRev && hash == staleHermesNpmDepsHash) {
          hash = fixedHermesNpmDepsHash;
        }
      );
  });
  hermesPkgs = pkgsWithHermesNpmHashFix.extend inputs.hermes-agent.overlays.default;
in
  (prev.lib.composeManyExtensions overlays) final prev
  // {
    inherit (hermesPkgs) hermes-agent;
  }
