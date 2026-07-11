# Nixpkgs 26.05 gives Bitwarden only xcbuild's xcrun output, while node-gyp
# invokes xcodebuild directly when rebuilding native npm dependencies.
_: _final: prev: {
  bitwarden-cli = prev.bitwarden-cli.overrideAttrs (old: {
    nativeBuildInputs =
      (old.nativeBuildInputs or [])
      ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
        prev.xcodebuild
      ];
  });
}
