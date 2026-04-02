# Override nodejs to skip tests (network tests fail in sandbox)
_: _final: prev: {
  nodejs = prev.nodejs.overrideAttrs (_: {
    doCheck = false;
  });
}
