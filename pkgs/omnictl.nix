# Custom omnictl package.
#
# nixpkgs (both nixos-26.05 and nixpkgs-unstable) is stuck on omnictl 1.7.3,
# which speaks client API version 2. Self-hosted Omni servers on v1.11.0+
# speak API version 3 and refuse older clients outright:
#   "client API version mismatch: backend API version X, client API version Y"
# Fetch the upstream release binary directly until nixpkgs catches up.
{
  pkgs,
  lib,
}: let
  version = "1.12.0";

  sha256ByPlatform = {
    aarch64-darwin = "93462dc5739bc3f7f13cf5e5196c9bf3cd6c82acbbe82b54cae93cf7961e3df5";
    x86_64-darwin = "dced4025f182d060cd295aae54fc1e3b45fd89bd9bad3d5a0d4be454d97e21d8";
  };

  assetByPlatform = {
    aarch64-darwin = "omnictl-darwin-arm64";
    x86_64-darwin = "omnictl-darwin-amd64";
  };

  system = pkgs.stdenv.hostPlatform.system;
  asset = assetByPlatform.${system} or (throw "omnictl: unsupported system ${system}");
  sha256 = sha256ByPlatform.${system};
in
  pkgs.stdenv.mkDerivation {
    pname = "omnictl";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/siderolabs/omni/releases/download/v${version}/${asset}";
      inherit sha256;
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/omnictl
      runHook postInstall
    '';

    meta = with lib; {
      description = "CLI for managing Omni, pinned past nixpkgs to match self-hosted Omni's API version";
      homepage = "https://github.com/siderolabs/omni";
      license = licenses.bsl11;
      platforms = builtins.attrNames assetByPlatform;
      mainProgram = "omnictl";
    };
  }
