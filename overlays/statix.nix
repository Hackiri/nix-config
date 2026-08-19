# Nixpkgs 26.05 ships an unreleased statix snapshot whose insta snapshot tests
# fail to build (`useless_has_attr` lint/fix assertions). Pin the last tagged
# release instead so the toolchain stays buildable.
_: _final: prev: {
  statix = prev.statix.overrideAttrs (_old: rec {
    version = "0.5.8";

    src = prev.fetchFromGitHub {
      owner = "oppiliappan";
      repo = "statix";
      rev = "v${version}";
      hash = "sha256-bMs3XMiGP6sXCqdjna4xoV6CANOIWuISSzCaL5LYY4c=";
    };

    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-Pi1q2qNLjQYr3Wla7rqrktNm0StszB2klcfzwAnF3tE=";
    };
  });
}
