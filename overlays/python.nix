# Disable flaky Python package tests
_final: prev: {
  pythonPackagesExtensions =
    (prev.pythonPackagesExtensions or [])
    ++ [
      (_: pySuper: {
        azure-core = pySuper.azure-core.overridePythonAttrs (_: {
          doCheck = false;
        });
        # Skip twisted tests - they hang indefinitely on macOS due to network-related tests
        twisted = pySuper.twisted.overridePythonAttrs (_: {
          doCheck = false;
        });
      })
    ];
}
