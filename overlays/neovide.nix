# Override neovide with the version from nixpkgs-unstable
{inputs}: _final: prev: {
  inherit
    (import inputs.nixpkgs-unstable {
      inherit (prev.stdenv.hostPlatform) system;
      config.allowUnfree = true;
      config.allowDeprecatedx86_64Darwin = true;
    })
    neovide
    ;
}
