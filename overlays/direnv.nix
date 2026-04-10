# Override direnv to skip tests (aliases test hangs in sandbox on macOS)
_: _final: prev: {
  direnv = prev.direnv.overrideAttrs (_: {
    doCheck = false;
  });
}
